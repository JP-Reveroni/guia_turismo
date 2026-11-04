/// MODEL = molde de dados.
/// Representa UM resultado da busca de endereço na API Nominatim.
class ResultadoBuscaModel {
  final double latitude;
  final double longitude;
  final String nomeCompleto; // texto bonito do endereço encontrado

  ResultadoBuscaModel({
    required this.latitude,
    required this.longitude,
    required this.nomeCompleto,
  });

  /// Converte o JSON da API em objeto Dart.
  /// ATENÇÃO: o Nominatim devolve lat/lon como TEXTO ("-23.56"), não como número,
  /// por isso está double.parse.
  factory ResultadoBuscaModel.fromJson(Map<String, dynamic> json) {
    return ResultadoBuscaModel(
      latitude: double.parse(json['lat'].toString()),
      longitude: double.parse(json['lon'].toString()),
      nomeCompleto: json['display_name']?.toString() ?? '',
    );
  }
}
