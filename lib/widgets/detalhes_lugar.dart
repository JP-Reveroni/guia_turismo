import 'package:flutter/material.dart';
import 'package:guia_turismo/controllers/gps_controller.dart';
import 'package:guia_turismo/controllers/lugares_controller.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:guia_turismo/widgets/botao_favorito.dart';
import 'package:guia_turismo/widgets/foto_lugar.dart';
import 'package:provider/provider.dart';

/// Abre o painel que sobe de baixo com os detalhes do lugar.
/// Usado ao tocar em um pin do mapa ou em um item da lista.
void mostrarDetalhesLugar(BuildContext context, LugaresModel lugar) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // deixa o painel crescer se o conteúdo for grande
    builder: (context) => DetalhesLugar(lugar: lugar),
  );
}

/// Conteúdo do painel: foto, nome, categoria, distância, descrição,
/// botão de favorito e botão "Como chegar".
class DetalhesLugar extends StatelessWidget {
  final LugaresModel lugar;

  const DetalhesLugar({super.key, required this.lugar});

  @override
  Widget build(BuildContext context) {
    // Distância até o usuário (null se o GPS ainda não respondeu)
    final distancia = context.watch<GpsController>().distanciaAte(lugar);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min, // ocupa só o espaço necessário
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto grande do lugar (ocupa toda a largura)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: double.infinity,
                height: 180,
                child: LayoutBuilder(
                  builder: (context, caixa) =>
                      FotoLugar(url: lugar.fotoUrl, tamanho: caixa.maxWidth, altura: 180),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(lugar.nome,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                BotaoFavorito(idLugar: lugar.id),
              ],
            ),
            if ((lugar.categoria ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Chip(label: Text(lugar.categoria!)),
            ],
            if (distancia != null) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.directions_walk, size: 18),
                const SizedBox(width: 4),
                Text('A $distancia de você'),
              ]),
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
            const SizedBox(height: 16),
            // BOTÃO "COMO CHEGAR": abre o Google Maps com a rota até o lugar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.directions),
                label: const Text('Como chegar'),
                onPressed: () async {
                  final abriu = await context.read<LugaresController>().comoChegar(lugar);
                  // Depois de um await, confere se a tela ainda existe
                  if (!abriu && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Não foi possível abrir o mapa.')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
