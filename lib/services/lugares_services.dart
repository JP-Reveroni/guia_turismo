import 'package:guia_turismo/models/lugares_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LugaresServices {
  //Endpoint = endereço da API
  String endpoint = "https://guia.liliaborges.com.br/lugares";
  int pagina = 1; //Carregar a primeira página
  int limite = 20; //Carregar limite de itens

  Future<List<LugaresModel>> buscarLugares() async {
    try {
      //Tentativa de carregar os dados da API
      final response = await http.get(
        Uri.parse('$endpoint?pagina=$pagina&limite=$limite'),
      );
      //Se der certo
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'];
        return data.map((item) => LugaresModel.fromJson(item)).toList();
        //Se não der certo
      } else {
        throw Exception('Erro na requisição: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
  //Tenta carregar o metodo cadastrar lugar, de maneira assincrona, e só pode fazer isso se o Token não for vazio
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
      //Map = Filtro por "chave" <Tipo da chave, tipo do valor>, Map<String, dynamic> = Filtro do tipo String que pode ter seu valor de qualquer tipo
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