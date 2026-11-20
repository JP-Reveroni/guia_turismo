import 'package:flutter/material.dart';
import 'package:guia_turismo/controllers/auth_controller.dart';
import 'package:guia_turismo/screens/home_screen.dart';
import 'package:guia_turismo/screens/login_screen.dart';
import 'package:provider/provider.dart';

/// AUTH GATE = o "porteiro" do app. Decide qual tela mostrar:
///
///   descobrindo se há sessão salva  -> tela de carregando
///   usuário logado                  -> HomeScreen
///   ninguém logado                  -> LoginScreen
///
/// Como ele usa Consumer<AuthController>, a troca de tela é AUTOMÁTICA:
///  - ao logar com sucesso, o AuthController avisa e o porteiro abre a Home;
///  - ao tocar em "Sair", ele avisa de novo e o porteiro volta para o Login;
///  - ao reabrir o app com sessão salva, ele já abre direto na Home.
/// Por isso as telas NÃO precisam usar Navigator para ir/voltar do login.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, child) {
        if (auth.inicializando) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return auth.logado ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
