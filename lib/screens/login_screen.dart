import 'package:flutter/material.dart';
import 'package:guia_turismo/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

/// TELA DE LOGIN: botão "Entrar com o Google" (principal)
/// e, mais abaixo, o login antigo por e-mail/senha da API.
///
/// Repare que esta tela NÃO navega para a Home: quando o login dá certo,
/// o AuthGate (auth_gate.dart) percebe e troca de tela sozinho.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /*
    Dados para entrar no sistema (login por e-mail/senha da API)
    email: lilia@teste.com  | Senha: senha123 (Do proprio API)
  */
  final _email = TextEditingController();
  final _senha = TextEditingController();

  @override
  void dispose() {
    // Libera os campos de texto da memória ao fechar a tela
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      //Consumer vai ler/ouvir o controller de Autenticação
      body: Consumer<AuthController>(
        builder: (context, controleAuth, _) => Center(
          // SingleChildScrollView evita "overflow" quando o teclado abre
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.travel_explore,
                    size: 72, color: Theme.of(context).colorScheme.primary),
                SizedBox(height: 8),
                Text("Guia Turismo",
                    style: Theme.of(context).textTheme.headlineSmall),
                SizedBox(height: 32),

                // ---------- LOGIN COM GOOGLE ----------
                // Enquanto está carregando (ou sem Firebase) o botão fica desativado (onPressed null)
                ElevatedButton.icon(
                  onPressed: (controleAuth.carregando || !controleAuth.firebaseDisponivel)
                      ? null
                      : () => controleAuth.entrarComGoogle(),
                  icon: controleAuth.carregando
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.login),
                  label: Text("Entrar com o Google"),
                ),
                if (!controleAuth.firebaseDisponivel)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      "Login com Google indisponível nesta plataforma.",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),

                SizedBox(height: 24),
                Row(children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("ou use e-mail e senha"),
                  ),
                  Expanded(child: Divider()),
                ]),
                SizedBox(height: 8),

                // ---------- LOGIN COM E-MAIL/SENHA (API) ----------
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: "E-mail"),
                ),
                TextField(
                  controller: _senha,
                  obscureText: true, //Esconde a senha
                  decoration: InputDecoration(labelText: "Senha"),
                ),
                SizedBox(height: 16),
                //Fica vazio se não tiver erro
                if (controleAuth.erro.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      controleAuth.erro,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ElevatedButton(
                  onPressed: controleAuth.carregando
                      ? null
                      : () => controleAuth.autenticarUsuario(
                            _email.text.trim(),
                            _senha.text,
                          ),
                  //Se logar, o AuthGate troca para a Home automaticamente
                  child: Text("Entrar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
