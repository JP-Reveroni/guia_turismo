import 'package:flutter/material.dart';
import 'package:guia_turismo/controllers/favoritos_controller.dart';
import 'package:provider/provider.dart';

/// Coração de FAVORITO. Cheio e vermelho = favorito; vazio = não favorito.
/// Usado na lista de lugares e no painel de detalhes do mapa.
class BotaoFavorito extends StatelessWidget {
  final int idLugar;

  const BotaoFavorito({super.key, required this.idLugar});

  @override
  Widget build(BuildContext context) {
    // Consumer: o coração muda sozinho quando o FavoritosController avisa
    return Consumer<FavoritosController>(
      builder: (context, favoritos, child) {
        final favorito = favoritos.ehFavorito(idLugar);
        return IconButton(
          tooltip: favorito ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
          onPressed: () => favoritos.alternar(idLugar),
          icon: Icon(
            favorito ? Icons.favorite : Icons.favorite_border,
            color: favorito ? Colors.red : null,
          ),
        );
      },
    );
  }
}
