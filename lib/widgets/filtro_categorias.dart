import 'package:flutter/material.dart';
import 'package:guia_turismo/controllers/lugares_controller.dart';
import 'package:provider/provider.dart';

/// FILTROS (funcionalidade extra): uma fileira de "chips" que filtra os
/// lugares por categoria (ou só os favoritos). Aparece no mapa e na lista.
/// O estado do filtro fica no LugaresController, por isso mapa e lista
/// sempre mostram o mesmo filtro.
class FiltroCategorias extends StatelessWidget {
  const FiltroCategorias({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LugaresController>(
      builder: (context, lugares, child) {
        return SizedBox(
          height: 48,
          // Lista que rola para o lado, caso tenha muitas categorias
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            children: [
              // Chip "Favoritos": liga/desliga o filtro de favoritos
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  avatar: const Icon(Icons.favorite, size: 16, color: Colors.red),
                  label: const Text('Favoritos'),
                  selected: lugares.apenasFavoritos,
                  onSelected: (_) => lugares.alternarApenasFavoritos(),
                ),
              ),
              // Chip "Todas": tira o filtro de categoria
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: const Text('Todas'),
                  selected: lugares.categoriaSelecionada == null,
                  onSelected: (_) => lugares.selecionarCategoria(null),
                ),
              ),
              // Um chip para cada categoria que existe nos lugares cadastrados
              for (final categoria in lugares.categorias)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(categoria),
                    selected: lugares.categoriaSelecionada == categoria,
                    onSelected: (_) => lugares.selecionarCategoria(categoria),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
