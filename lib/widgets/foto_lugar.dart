import 'package:flutter/material.dart';

/// WIDGET REUTILIZÁVEL: mostra a foto de um lugar.
/// Usado na lista, no pin do mapa e no painel de detalhes.
/// Se o lugar não tem foto (ou a imagem não carrega), mostra um ícone no lugar,
/// assim a tela nunca quebra por causa de uma imagem.
class FotoLugar extends StatelessWidget {
  final String? url;
  final double tamanho; // largura (e altura, se [altura] não for informada)
  final double? altura;

  const FotoLugar({super.key, required this.url, this.tamanho = 48, this.altura});

  @override
  Widget build(BuildContext context) {
    // Ícone usado quando não há foto ou quando ela falha
    final alt = altura ?? tamanho;
    final icone = Container(
      width: tamanho,
      height: alt,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(Icons.place, size: (tamanho < alt ? tamanho : alt) * 0.5),
    );

    if (url == null || url!.isEmpty) return icone;

    return Image.network(
      url!,
      width: tamanho,
      height: alt,
      fit: BoxFit.cover, // corta a imagem para preencher o quadrado
      // Enquanto baixa a imagem, mostra o ícone
      loadingBuilder: (context, child, progresso) =>
          progresso == null ? child : icone,
      // Se der erro (link quebrado, sem internet), mostra o ícone
      errorBuilder: (context, erro, pilha) => icone,
    );
  }
}
