import 'package:guia_turismo/models/lugares_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LugaresServices {
  String endpoint = "https://guia.liliaborges.com.br/lugares";
  int pagina = 1;
  int limite = 10;

  Future<List<LugaresModel>> buscarLugares() async {
    try {
      final response = await http.get(
        Uri.parse('$endpoint?pagina=$pagina&limite=$limite'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'];
        return data.map((item) => LugaresModel.fromJson(item)).toList();
      } else {
        throw Exception('Erro na requisição: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
 
  Future<String> cadastrarLugar(LugaresModel dados, token) async {
    try {
      if (token.isEmpty){
        return "Não autorizado";
      }
      final resposta = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(dados.toJson()),
      );
      Map<String, dynamic> mensagem = jsonDecode(resposta.body);
      if (resposta.statusCode != 201) {
        throw Exception(mensagem['message'] ?? 'Erro ao cadastrar');
      }
      return mensagem['message'] ?? 'Lugar cadastrado!';
    } catch (erro) {
      rethrow;
    }
 }
}
