import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// SERVICE do login por E-MAIL e SENHA na API do professor.
/// (O login com Google está em google_auth_service.dart)
class AuthService {
  final String url = 'https://guia.liliaborges.com.br/login';
  
  Future<Map> autenticar(String email, String senha) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({"email": email, "senha": senha}),
          )
          // Sem internet o app não fica esperando para sempre
          .timeout(const Duration(seconds: 15));
      final dados = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return (dados['data'] as Map?) ?? {};
      } else {
        debugPrint(dados.toString());
        return {};
      }
    } catch(e) {
      rethrow;
    }
  } 
}
