import 'package:firebase_auth/firebase_auth.dart';
// google_sign_in = abre a janela "Escolha uma conta Google" no celular
import 'package:google_sign_in/google_sign_in.dart';
// kIsWeb = true quando o app está rodando no navegador (Chrome, por exemplo)
import 'package:flutter/foundation.dart' show kIsWeb;

/// SERVICE de LOGIN COM GOOGLE.
/// Aqui fica tudo que "fala com o mundo externo": Google e Firebase.
/// (Este código veio do projeto "login" e foi só organizado em métodos.)
///
/// Como o login funciona, passo a passo:
///   1. O usuário escolhe uma conta Google  -> o Google devolve um "idToken" (prova de identidade).
///   2. Entregamos esse idToken ao Firebase -> ele confere com o Google e cria a sessão.
///   3. O Firebase GUARDA a sessão no aparelho: ao abrir o app de novo, o usuário continua logado.
class GoogleAuthService {
  // FirebaseAuth.instance = o "porteiro" do Firebase (sabe quem está logado).
  // É um getter (e não um campo) para só acessar o Firebase quando for preciso.
  FirebaseAuth get _auth => FirebaseAuth.instance;

  // O GoogleSignIn precisa de initialize() UMA ÚNICA vez por execução do app.
  // Guardamos o Future aqui para não chamar de novo a cada clique no botão.
  static Future<void>? _inicializacao;

  /// Usuário logado agora (null = ninguém logado).
  User? get usuarioAtual => _auth.currentUser;

  /// Stream = "canal" que avisa sempre que o login muda (entrou, saiu).
  /// Também é ele que devolve o usuário salvo quando o app é reaberto
  /// (é assim que a SESSÃO PERSISTE).
  Stream<User?> get mudancasDeLogin => _auth.authStateChanges();

  /// Prepara o pacote google_sign_in (só mobile). Roda uma vez só.
  Future<void> _garantirInicializado() {
    _inicializacao ??= GoogleSignIn.instance.initialize().catchError((erro) {
      // Se falhou, limpa para permitir uma nova tentativa no próximo clique
      _inicializacao = null;
      throw erro;
    });
    return _inicializacao!;
  }

  /// Abre o login do Google. Devolve o usuário logado,
  /// ou null se a pessoa fechou a janela sem escolher nenhuma conta.
  Future<User?> entrarComGoogle() async {
    try {
      late final UserCredential resultado;

      if (kIsWeb) {
        // NA WEB: o Firebase abre um pop-up do Google e já faz tudo sozinho.
        resultado = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        // NO CELULAR (Android/iOS):
        await _garantirInicializado();

        // 1) Abre a janela do Google para escolher a conta
        final conta = await GoogleSignIn.instance.authenticate();

        // 2) Pega a "prova de identidade" (idToken) dessa conta
        final idToken = conta.authentication.idToken;
        if (idToken == null) {
          throw Exception('O Google não devolveu o token de acesso.');
        }

        // 3) Transforma o token em uma "credencial" que o Firebase entende
        final credencial = GoogleAuthProvider.credential(idToken: idToken);

        // 4) Entrega a credencial ao Firebase, que cria a sessão do usuário
        resultado = await _auth.signInWithCredential(credencial);
      }
      return resultado.user;
    } on GoogleSignInException catch (e) {
      // Usuário tocou em "cancelar": não é erro de verdade, só não faz nada
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    } on FirebaseAuthException catch (e) {
      // Mesma coisa na web: pop-up fechado pelo usuário
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        return null;
      }
      rethrow;
    }
  }

  /// Faz LOGOUT: sai da conta Google E encerra a sessão do Firebase.
  Future<void> sair() async {
    // Na web não existe sessão do pacote google_sign_in, só a do Firebase
    if (!kIsWeb) {
      try {
        await _garantirInicializado();
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // Se falhar aqui não pode impedir o logout do Firebase (abaixo)
      }
    }
    await _auth.signOut();
  }
}
