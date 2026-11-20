// import 'package:secure_shared_preferences/secure_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*class SessionService {
  Future<void> salvarToken(String token) async {
    final prefs = await SecureSharedPref.getInstance();
    await prefs.putString('token', token, isEncrypted: true);
  }

  Future<String?> pegarToken() async {
    final prefs = await SecureSharedPref.getInstance();
    return prefs.getString('token', isEncrypted: true);
  }

  Future<void> logout() async {
    final prefs = await SecureSharedPref.getInstance();
    await prefs.clearAll();
  }
}*/

/*
  Questões de Login
  Este service guarda no aparelho (SharedPreferences) o login feito na API
  (e-mail/senha). O login do Google NÃO passa por aqui: quem guarda a sessão
  dele é o próprio Firebase.
*/
class SessionService {
  static String nome = '';
  static String email = '';
  //Future é para métodos asincronos, <String> significa que ele vai tentar trazer uma string
  Future<String> pegarNome() async {
    final prefs = await SharedPreferences.getInstance();
    nome = prefs.getString('nome') ?? '';
    return nome;
  }

  Future<String> pegarEmail() async {
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
    return email;
  }

  Future<void> salvarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> pegarToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Logout da API: apaga token e dados do usuário guardados no aparelho.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('nome');
    await prefs.remove('email');
    nome = '';
    email = '';
  }

  Future<void> salvarUsuario(Map user) async {
    final prefs = await SharedPreferences.getInstance();
    // "?? ''" evita erro caso a API não envie algum dos campos
    await prefs.setString('email', (user['email'] ?? '').toString());
    await prefs.setString('nome', (user['nome'] ?? '').toString());
  }
}
