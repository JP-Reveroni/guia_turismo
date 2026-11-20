import 'package:flutter/material.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:guia_turismo/widgets/foto_lugar.dart';

/// PIN do mapa: uma bolinha com a FOTO do lugar e uma setinha apontando para o ponto.
/// A borda fica amarela se o lugar é favorito e vermelha se não é.
/// Tamanho total: 48 de largura x 64 de altura (precisa bater com o Marker do mapa).
class PinLugar extends StatelessWidget {
  final LugaresModel lugar;
  final bool favorito;
  final VoidCallback onTap;

  const PinLugar({
    super.key,
    required this.lugar,
    required this.favorito,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cor = favorito ? Colors.amber : Colors.red;
    // GestureDetector deixa o pin "clicável"
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: cor, width: 3),
              boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black38)],
            ),
            // ClipOval recorta a foto quadrada em formato de círculo
            child: ClipOval(child: FotoLugar(url: lugar.fotoUrl, tamanho: 38)),
          ),
          // Setinha para baixo: a ponta dela fica em cima da coordenada
          Icon(Icons.arrow_drop_down, color: cor, size: 20),
        ],
      ),
    );
  }
}
