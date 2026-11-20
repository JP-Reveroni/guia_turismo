import 'package:flutter/material.dart';
import 'package:guia_turismo/controllers/favoritos_controller.dart';
import 'package:guia_turismo/controllers/geocoding_controller.dart';
import 'package:guia_turismo/controllers/gps_controller.dart';
import 'package:guia_turismo/controllers/lugares_controller.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:guia_turismo/widgets/botao_favorito.dart';
import 'package:guia_turismo/widgets/detalhes_lugar.dart';
import 'package:guia_turismo/widgets/filtro_categorias.dart';
import 'package:guia_turismo/widgets/foto_lugar.dart';
import 'package:provider/provider.dart';

class LugaresScreen extends StatefulWidget {
  const LugaresScreen({super.key});

  @override
  State<LugaresScreen> createState() => _LugaresScreenState();
}

class _LugaresScreenState extends State<LugaresScreen> {
  //Cadastro no forms
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  //Campo onde o usuário digita o endereço ou CEP para buscar a latitude/longitude
  final _enderecoController = TextEditingController();
  //Campo opcional: link (URL) da foto do lugar
  final _fotoController = TextEditingController();
  int _categoriaId = 1;

  @override
  void initState() {
    super.initState();
    //Ao abrir a lista, pede o GPS (se ainda não tiver) para mostrar a DISTÂNCIA de cada lugar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final gps = context.read<GpsController>();
      if (gps.atual == null) gps.buscarLocal();
    });
  }

  @override
  void dispose() {
    //Libera os campos de texto da memória
    _nomeController.dispose();
    _descricaoController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _enderecoController.dispose();
    _fotoController.dispose();
    super.dispose();
  }

//Busca o endereço/CEP digitado na API Nominatim e preenche latitude e longitude
Future<void> _buscarCoordenadas() async {
  //read = pega o controller sem "escutar" (usado dentro de funções, não no build)
  final geoController = context.read<GeocodingController>();
  final resultado = await geoController.buscar(_enderecoController.text);
  //Se encontrou, coloca os valores nos campos de latitude e longitude do formulário
  if (resultado != null) {
    _latitudeController.text = resultado.latitude.toString();
    _longitudeController.text = resultado.longitude.toString();
  }
}

void abrirForm() {
  //Sempre que abrir o forms, o campo está limpo
  _nomeController.clear();
  _descricaoController.clear();
  _latitudeController.clear();
  _longitudeController.clear();
  _enderecoController.clear();
  _fotoController.clear();
  //Zera o resultado/erro da busca anterior
  context.read<GeocodingController>().limpar();
  _categoriaId = 1;
  showDialog(context: context,
  builder: (context) {
    return AlertDialog(
      title: Text("Cadastro de Lugares"),
      //Evita erro de overflow quando o teclado abre
      content: SingleChildScrollView( 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                label: Text("Nome")
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(
                label: Text("Descrição")
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<int>(
              initialValue: _categoriaId,
              decoration: InputDecoration(
                label: Text("Categoria")
              ),
              items: [
                DropdownMenuItem(value: 1, child: Text("Praias")),
                DropdownMenuItem(value: 2, child: Text("Points")),
                DropdownMenuItem(value: 3, child: Text("Ilhas")),
                DropdownMenuItem(value: 4, child: Text("Gastronomia")),
                DropdownMenuItem(value: 5, child: Text("Dicas")),
              ],
              //Salva o valor do dropdown
              onChanged: (valor) => _categoriaId = valor!,
            ),
            SizedBox(height: 20),
            //Busca de endereço/CEP (Nominatim) -> preenche latitude e longitude
            TextField(
              controller: _enderecoController,
              textInputAction: TextInputAction.search,
              //Apertar "buscar" no teclado também faz a busca
              onSubmitted: (_) => _buscarCoordenadas(),
              decoration: InputDecoration(
                label: Text("Endereço ou CEP"),
                hintText: "Ex: Av. Paulista, São Paulo ou 01310-100",
                //Consumer escuta o GeocodingController: troca a lupa por um loading durante a busca
                suffixIcon: Consumer<GeocodingController>(
                  builder: (context, geo, child) => geo.carregando
                      ? Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          onPressed: _buscarCoordenadas,
                          icon: Icon(Icons.search),
                          tooltip: "Buscar coordenadas",
                        ),
                ),
              ),
            ),
            //Mensagem abaixo do campo: erro (vermelho) ou o endereço que foi encontrado
            Consumer<GeocodingController>(
              builder: (context, geo, child) {
                if (geo.erro.isNotEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(geo.erro, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  );
                }
                if (geo.resultado != null) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text("Encontrado: ${geo.resultado!.nomeCompleto}", style: TextStyle(fontSize: 12)),
                  );
                }
                return SizedBox.shrink(); //Nada para mostrar
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: _fotoController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                label: Text("URL da foto (opcional)"),
                hintText: "https://...",
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _latitudeController,
              decoration: InputDecoration(
                label: Text("Latitude")
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _longitudeController,
              decoration: InputDecoration(
                label: Text("Longitude")
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
        TextButton(onPressed: () => _salvarDados(context), child: Text("Salvar"))
      ],
    );
  });
}

Future<void> _salvarDados(BuildContext contextDialog) async {
  final novoLugar = LugaresModel(
    id: 0, //O Id é gerado pelo api
    nome: _nomeController.text,
    descricao: _descricaoController.text,
    //Converte virgula para ponto
    latitude: double.tryParse(_latitudeController.text.replaceAll(',', '.')) ?? 0,
    longitude: double.tryParse(_longitudeController.text.replaceAll(',', '.')) ?? 0,
    categoriaId: _categoriaId,
    fotoUrl: _fotoController.text.trim(),
  );
  final controleLugares = context.read<LugaresController>();
  final mensagem = await controleLugares.cadastrarLugar(novoLugar);
  if (!contextDialog.mounted) return;
  ScaffoldMessenger.of(contextDialog).showSnackBar(SnackBar(content: Text(mensagem)));
  if (controleLugares.cadastroOk) {
    //Fecha o modal qnd conclui
    Navigator.pop(contextDialog); 
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LugaresController>(builder: (context, lugaresController, child) {
        if (lugaresController.carregando){
          return Center(child: CircularProgressIndicator());
        }
        if (lugaresController.erro != ''){
          return Center(child: Text(lugaresController.erro));
        }
        if (lugaresController.lugares.isEmpty){
          return Center(child: Text("Nenhum lugar encontrado"));
        }
        //Monta a lista de lugares (já aplicando os filtros escolhidos)
        //watch = redesenha a lista quando os favoritos ou o GPS mudam
        final favoritos = context.watch<FavoritosController>();
        final gps = context.watch<GpsController>();
        final lugares = lugaresController.lugaresFiltrados(favoritos.ids);

        return Column(
          children: [
            //Chips de filtro (categorias e favoritos)
            FiltroCategorias(),
            Expanded(
              child: lugares.isEmpty
                  ? Center(child: Text("Nenhum lugar com esses filtros"))
                  : ListView.builder(
                      itemCount: lugares.length,
                      itemBuilder: (context, index) {
                        final lugar = lugares[index];
                        //Distância até o usuário (null se o GPS ainda não respondeu)
                        final distancia = gps.distanciaAte(lugar);
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(12)
                          ),
                          elevation: 4,
                          child: ListTile(
                            //Toque no item abre o painel de detalhes (foto, como chegar...)
                            onTap: () => mostrarDetalhesLugar(context, lugar),
                            title: Text(lugar.nome),
                            subtitle: Text(
                              [
                                if ((lugar.categoria ?? '').isNotEmpty) lugar.categoria!,
                                ?distancia,
                              ].join(' • '),
                            ),
                            //Foto que fica no inicio da linha
                            leading: ClipOval(
                              child: FotoLugar(url: lugar.fotoUrl, tamanho: 40),
                            ),
                            //Coração de favorito que fica no final da linha
                            trailing: BotaoFavorito(idLugar: lugar.id),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),

      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirForm(),
        child: Icon(Icons.add_location_alt),
      ),

    );
  }
}