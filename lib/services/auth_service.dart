import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String url = 'https://guia.liliaborges.com.br/login';
  
  Future<Map> autenticar(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "senha": senha}),
      );
      final dados = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return dados['data'];
      } else {
        debugPrint(dados.toString());
        return {};
      }
    } catch(e) {
      rethrow;
    }
  } 
}