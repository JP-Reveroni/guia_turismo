class LugaresModel {
  final int id;
  final String nome;
  final String? categoria;
  final num latitude;
  final num longitude;
  final String? descricao;
  final int categoriaId;
  //Endereço (URL) da foto do estabelecimento. Vazio = sem foto (o app mostra um ícone no lugar)
  final String? fotoUrl;


  LugaresModel({
    required this.id,
    required this.nome,
    this.categoria = '',
    required this.latitude,
    required this.longitude,
    this.descricao = '',
    required this.categoriaId,
    this.fotoUrl = '',
  });

  //Converter dados json (da api) para Map
  //Cada campo é lido com cuidado: se a API mandar algo faltando ou diferente, o app não trava
  factory LugaresModel.fromJson(Map json) {
    //A categoria pode vir como objeto {"nome": "Praias"}, como texto, ou nem vir
    final categoriaJson = json['categoria'];
    final String? nomeCategoria = categoriaJson is Map
        ? categoriaJson['nome']?.toString()
        : categoriaJson?.toString();

    return LugaresModel(
      id: _paraInt(json['id']),
      nome: (json['nome'] ?? 'Sem nome').toString(),
      latitude: _paraNum(json['latitude']),
      longitude: _paraNum(json['longitude']),
      descricao: json['descricao']?.toString(),
      categoria: nomeCategoria,
      categoriaId: _paraInt(json['categoriaId']),
      fotoUrl: _lerFoto(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'latitude': latitude,
      'longitude': longitude,
      'categoria': categoria,
      'descricao': descricao,
      'categoriaId': categoriaId,
      //A foto só é enviada se foi preenchida
      if ((fotoUrl ?? '').isNotEmpty) 'foto': fotoUrl,
    };
  }

  //Procura a foto em alguns nomes de campo possíveis (a API pode usar qualquer um deles)
  static String _lerFoto(Map json) {
    for (final chave in ['foto', 'fotoUrl', 'foto_url', 'imagem', 'imagemUrl', 'imagem_url', 'urlFoto', 'image']) {
      final valor = json[chave]?.toString() ?? '';
      if (valor.startsWith('http')) return valor;
    }
    return '';
  }

  //Converte "12", 12 ou 12.0 para int (0 se não der)
  static int _paraInt(dynamic valor) =>
      valor is num ? valor.toInt() : int.tryParse(valor?.toString() ?? '') ?? 0;

  //Converte "-23.5", -23.5 ou -23 para num (0 se não der)
  static num _paraNum(dynamic valor) =>
      valor is num ? valor : num.tryParse(valor?.toString() ?? '') ?? 0;
}
