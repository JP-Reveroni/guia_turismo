class LugaresModel {
  final int id;
  final String nome;
  final String? categoria;
  final double latitude;
  final double longitude;
  final String? descricao;
  final int categoriaId;


  LugaresModel({
    required this.id,
    required this.nome,
    this.categoria = '',
    required this.latitude,
    required this.longitude,
    this.descricao = '',
    required this.categoriaId
  });

  //Converter dados json (da api) para Map
  factory LugaresModel.fromJson(Map json) {
    return LugaresModel(
      id: json['id'],
      nome: json['nome'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      descricao: json['descricao'],
      categoria: json['categoria']['nome'] ?? json['categoria']['nome'],
      categoriaId: json['categoriaId']
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
      'categoriaId': categoriaId
    };
  }
}
