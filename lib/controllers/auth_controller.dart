import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:guia_turismo/services/auth_service.dart';
import 'package:guia_turismo/services/google_auth_service.dart';
import 'package:guia_turismo/services/session_service.dart';

/// CONTROLLER DE AUTENTICAÇÃO = a "central" de login do app.
/// Ele junta DOIS jeitos de entrar e responde uma única pergunta para as telas:
/// "tem alguém logado?" (propriedade [logado]).
///
///  1) Login com GOOGLE  (Firebase)  -> é o login principal do app.
///  2) Login com E-MAIL/SENHA (API)  -> mantido porque só a API gera o "token"
///     necessário para CADASTRAR lugares.
///
/// Como é um ChangeNotifier, toda vez que chamamos notifyListeners() as telas
/// que usam Consumer<AuthController> são redesenhadas automaticamente.
class AuthController extends ChangeNotifier {
  final GoogleAuthService _google = GoogleAuthService();
  final SessionService _sessao = SessionService();

  // Fica "ouvindo" o Firebase para saber quando o login muda
  StreamSubscription<User?>? _ouvinte;

  /// true enquanto o app descobre se já existe uma sessão salva (tela de "carregando").
  bool inicializando = true;

  /// true enquanto um login está em andamento (para mostrar o loading no botão).
  bool carregando = false;

  /// Mensagem de erro para mostrar na tela de login (vazia = sem erro).
  String erro = '';

  /// true se o Firebase foi iniciado com sucesso (se não, o botão do Google fica desativado).
  bool firebaseDisponivel = false;

  /// Usuário do Google/Firebase (null = não logou com Google).
  User? usuarioGoogle;

  /// Token da API (vazio = não logou com e-mail/senha).
  String tokenApi = '';

  AuthController() {
    _iniciar();
  }

  // ---------------------------------------------------------------------------
  // DADOS DO USUÁRIO (as telas só leem estes getters, sem saber de onde vêm)
  // ---------------------------------------------------------------------------

  /// Logado = entrou com o Google OU com e-mail/senha.
  bool get logado => usuarioGoogle != null || tokenApi.isNotEmpty;

  /// Já tem o token da API? (necessário para cadastrar lugares)
  bool get temTokenApi => tokenApi.isNotEmpty;

  String get nome {
    final doGoogle = usuarioGoogle?.displayName ?? '';
    if (doGoogle.isNotEmpty) return doGoogle;
    return SessionService.nome.isNotEmpty ? SessionService.nome : 'Visitante';
  }

  String get email {
    final doGoogle = usuarioGoogle?.email ?? '';
    return doGoogle.isNotEmpty ? doGoogle : SessionService.email;
  }

  /// Foto de perfil (só existe no login com Google).
  String get foto => usuarioGoogle?.photoURL ?? '';

  /// Identificador do usuário: usado para guardar os FAVORITOS de cada pessoa separados.
  String get idUsuario {
    if (usuarioGoogle != null) return usuarioGoogle!.uid;
    if (SessionService.email.isNotEmpty) return SessionService.email;
    return 'anonimo';
  }

  // ---------------------------------------------------------------------------
  // INICIALIZAÇÃO (roda uma vez quando o app abre)
  // ---------------------------------------------------------------------------
  Future<void> _iniciar() async {
    try {
      // Recupera o login da API que ficou salvo no aparelho
      tokenApi = await _sessao.pegarToken() ?? '';
      await _sessao.pegarNome();
      await _sessao.pegarEmail();
    } catch (e) {
      debugPrint('ERRO ao ler sessão salva: $e');
    }

    // Foi o main.dart que iniciou o Firebase. Se Firebase.apps está vazio, deu erro lá.
    firebaseDisponivel = Firebase.apps.isNotEmpty;

    if (!firebaseDisponivel) {
      inicializando = false;
      notifyListeners();
      return;
    }

    try {
      // PERSISTÊNCIA DE SESSÃO:
      // O Firebase guarda o usuário no aparelho. Ao abrir o app, este stream
      // dispara UMA vez com o usuário salvo (ou null se não tinha ninguém)
      // e depois dispara de novo a cada login/logout.
      _ouvinte = _google.mudancasDeLogin.listen((usuario) {
        usuarioGoogle = usuario;
        inicializando = false;
        notifyListeners();
      }, onError: (e) {
        debugPrint('ERRO no stream de login: $e');
        inicializando = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('ERRO ao ouvir o login: $e');
      inicializando = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // LOGIN COM GOOGLE
  // ---------------------------------------------------------------------------
  Future<void> entrarComGoogle() async {
    if (!firebaseDisponivel) {
      erro = 'Login com Google indisponível neste dispositivo.';
      notifyListeners();
      return;
    }
    carregando = true;
    erro = '';
    notifyListeners(); // mostra o loading

    try {
      final usuario = await _google.entrarComGoogle();
      // Se vier null, a pessoa cancelou: não mostramos erro
      if (usuario != null) usuarioGoogle = usuario;
    } on FirebaseAuthException catch (e) {
      erro = 'Não foi possível entrar com o Google (${e.code}).';
      debugPrint('ERRO FirebaseAuth: ${e.code} - ${e.message}');
    } catch (e) {
      erro = 'Não foi possível entrar com o Google. Tente novamente.';
      debugPrint('ERRO login Google: $e');
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // LOGIN COM E-MAIL E SENHA (API do professor) - já existia no projeto
  // ---------------------------------------------------------------------------
  Future<bool> autenticarUsuario(String email, String senha) async {
    carregando = true;
    erro = '';
    notifyListeners();
    try {
      final Map dados = await AuthService().autenticar(email, senha);
      final String? token = dados['token'];
      if (token == null) {
        erro = 'Login ou senha inválidos!';
        return false;
      }
      await _sessao.salvarToken(token);
      await _sessao.salvarUsuario(dados['usuario'] ?? {'email': email});
      await _sessao.pegarNome();
      await _sessao.pegarEmail();
      tokenApi = token;
      return true;
    } catch (e) {
      erro = 'Não foi possível entrar. Verifique sua conexão e tente novamente.';
      debugPrint('ERRO login API: $e');
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------
  /// Sai de TUDO: Google, Firebase e o token da API.
  /// Depois do notifyListeners(), o AuthGate percebe que [logado] virou false
  /// e volta sozinho para a tela de login.
  Future<void> deslogarUsuario() async {
    try {
      await _google.sair();
    } catch (e) {
      debugPrint('ERRO ao sair do Google: $e');
    }
    try {
      await _sessao.logout();
    } catch (e) {
      debugPrint('ERRO ao limpar sessão: $e');
    }
    usuarioGoogle = null;
    tokenApi = '';
    erro = '';
    notifyListeners();
  }

  @override
  void dispose() {
    // Para de ouvir o Firebase quando o controller é destruído
    _ouvinte?.cancel();
    super.dispose();
  }
}
