import 'package:flutter/material.dart';
// flutter_map = widget de mapa (usa os "tiles" = pedacinhos de imagem do OpenStreetMap)
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:guia_turismo/controller/gps_controller.dart';
import 'package:guia_turismo/controller/lugares_controller.dart';
import 'package:guia_turismo/models/lugares_model.dart';

/// Tela do mapa: mostra um PIN (marcador) para cada lugar cadastrado
/// e um ponto azul com a localização atual do usuário.
class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  // MapController = "controle remoto" do mapa: permite mover a câmera,
  // dar zoom etc. pelo código (usado nos botões flutuantes).
  final MapController _mapController = MapController();

  // Centro padrão (meio do Brasil) caso não tenhamos GPS nem lugares
  static const LatLng _centroPadrao = LatLng(-14.235, -51.925);

  @override
  void initState() {
    super.initState();
    // Ao abrir a tela, pede a localização do usuário.
    // addPostFrameCallback espera o primeiro desenho da tela terminar
    // (assim o mapa já existe quando formos movê-lo).
    WidgetsBinding.instance.addPostFrameCallback((_) => _irParaMinhaLocalizacao());
  }

  @override
  void dispose() {
    // Libera o MapController da memória quando a tela é fechada
    _mapController.dispose();
    super.dispose();
  }

  /// Busca o GPS e, se encontrou, leva a câmera do mapa até o usuário.
  Future<void> _irParaMinhaLocalizacao() async {
    final gps = context.read<GpsController>();
    await gps.buscarLocal();
    // Depois de um await a tela pode já ter sido fechada: sempre conferir "mounted"
    if (!mounted) return;

    if (gps.atual != null) {
      _mapController.move(gps.atual!, 15.0); // move(centro, zoom)
    } else if (gps.erro.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(gps.erro)));
    }
  }

  /// Ajusta a câmera para enquadrar TODOS os lugares cadastrados.
  void _verTodosOsLugares(List<LugaresModel> lugares) {
    final pontos = _pontosValidos(lugares);
    if (pontos.isEmpty) return;

    if (pontos.length == 1) {
      // Com um só ponto não existe "área" para enquadrar, então só centraliza
      _mapController.move(pontos.first, 15.0);
    } else {
      // CameraFit.coordinates calcula centro e zoom para caber todos os pontos
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: pontos,
          padding: const EdgeInsets.all(48), // margem para os pins não colarem na borda
        ),
      );
    }
  }

  /// Ignora lugares sem coordenada válida.
  /// (No cadastro, se o usuário não preenche lat/long, o app salva 0 e 0.)
  bool _temCoordenada(LugaresModel lugar) {
    final lat = lugar.latitude.toDouble();
    final lng = lugar.longitude.toDouble();
    final zerado = lat == 0 && lng == 0;
    final foraDoLimite = lat < -90 || lat > 90 || lng < -180 || lng > 180;
    return !zerado && !foraDoLimite;
  }

  List<LatLng> _pontosValidos(List<LugaresModel> lugares) => lugares
      .where(_temCoordenada)
      .map((l) => LatLng(l.latitude.toDouble(), l.longitude.toDouble()))
      .toList();

  /// Painel que sobe de baixo quando o usuário toca em um pin.
  void _mostrarDetalhes(LugaresModel lugar) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // ocupa só o espaço necessário
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lugar.nome, style: Theme.of(context).textTheme.titleLarge),
              if ((lugar.categoria ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Chip(label: Text(lugar.categoria!)),
              ],
              if ((lugar.descricao ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(lugar.descricao!),
              ],
              const SizedBox(height: 8),
              Text(
                'Lat: ${lugar.latitude}  |  Long: ${lugar.longitude}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Consumer2 escuta DOIS controllers ao mesmo tempo:
    // quando os lugares ou o GPS mudam, o mapa é redesenhado.
    return Consumer2<LugaresController, GpsController>(
      builder: (context, lugaresController, gps, child) {
        final lugares = lugaresController.lugares.where(_temCoordenada).toList();

        return Scaffold(
          body: Stack(
            // Stack = widgets empilhados: o mapa embaixo e o aviso/loading por cima
            children: [
              FlutterMap(
                mapController: _mapController, // liga o "controle remoto" ao mapa
                options: MapOptions(
                  // Onde o mapa começa: GPS > primeiro lugar cadastrado > centro do Brasil
                  initialCenter: gps.atual ??
                      (lugares.isNotEmpty
                          ? LatLng(
                              lugares.first.latitude.toDouble(),
                              lugares.first.longitude.toDouble(),
                            )
                          : _centroPadrao),
                  // zoom: quanto maior, mais perto (4 = país, 15 = bairro)
                  initialZoom: (gps.atual != null || lugares.isNotEmpty) ? 15.0 : 4.0,
                ),
                // children = camadas do mapa, desenhadas na ordem (uma sobre a outra)
                children: [
                  // CAMADA 1: o desenho do mapa em si, baixado do OpenStreetMap
                  TileLayer(
                    // {z}/{x}/{y} = zoom e posição de cada pedacinho (tile) da imagem
                    urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    // Identifica o app para o OpenStreetMap (exigência dos termos de uso)
                    userAgentPackageName: "br.com.guiaturismo.maps",
                  ),

                  // CAMADA 2: os pins dos lugares cadastrados
                  MarkerLayer(
                    markers: lugares
                        .map(
                          (lugar) => Marker(
                            // A ponta do pin deve ficar em cima da coordenada:
                            // topCenter faz o pin ser desenhado ACIMA do ponto
                            alignment: Alignment.topCenter,
                            width: 40,
                            height: 40,
                            rotate: true, // o pin não gira se o mapa for rotacionado
                            point: LatLng(
                              lugar.latitude.toDouble(),
                              lugar.longitude.toDouble(),
                            ),
                            // GestureDetector deixa o ícone "clicável"
                            child: GestureDetector(
                              onTap: () => _mostrarDetalhes(lugar),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  // CAMADA 3: a localização do usuário (só aparece se o GPS funcionou)
                  if (gps.atual != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          alignment: Alignment.center,
                          width: 28,
                          height: 28,
                          point: gps.atual!,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 28,
                          ),
                        ),
                      ],
                    ),

                  // Créditos do OpenStreetMap (obrigatório pela licença dos dados)
                  RichAttributionWidget(
                    attributions: [TextSourceAttribution('OpenStreetMap contributors')],
                  ),
                ],
              ),

              // Barrinha de loading no topo enquanto busca GPS ou lugares
              if (gps.carregando || lugaresController.carregando)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(),
                ),

              // Aviso se a lista de lugares não carregou
              if (lugaresController.erro.isNotEmpty)
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(lugaresController.erro),
                    ),
                  ),
                ),
            ],
          ),

          // Dois botões flutuantes: ver todos os lugares / ir para minha posição
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'verTodos', // heroTag precisa ser único quando há 2 botões
                tooltip: 'Ver todos os lugares',
                onPressed: () => _verTodosOsLugares(lugaresController.lugares),
                child: const Icon(Icons.zoom_out_map),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'minhaLocalizacao',
                tooltip: 'Minha localização',
                onPressed: _irParaMinhaLocalizacao,
                child: const Icon(Icons.person_pin_circle_rounded),
              ),
            ],
          ),
        );
      },
    );
  }
}
