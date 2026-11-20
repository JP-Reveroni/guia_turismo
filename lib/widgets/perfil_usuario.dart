import 'package:flutter/material.dart';
import 'package:guia_turismo/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

/// Cartão do PERFIL do usuário logado: foto, nome, e-mail e botão "Sair" (LOGOUT).
/// Mostrado na aba "Início".
class PerfilUsuario extends StatelessWidget {
  const PerfilUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    // watch = redesenha o cartão se os dados do usuário mudarem
    final auth = context.watch<AuthController>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              // Foto do Google; sem foto (login por e-mail) mostra um ícone
              backgroundImage: auth.foto.isNotEmpty ? NetworkImage(auth.foto) : null,
              // Se a foto não carregar, não derruba a tela
              onBackgroundImageError: auth.foto.isNotEmpty ? (erro, pilha) {} : null,
              child: auth.foto.isEmpty ? const Icon(Icons.person, size: 40) : null,
            ),
            const SizedBox(height: 12),
            Text(
              'Olá, ${auth.nome}!',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (auth.email.isNotEmpty) Text(auth.email),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sair'),
              // Ao sair, o AuthGate volta sozinho para a tela de login
              onPressed: () => confirmarLogout(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pergunta "Deseja sair?" e, se o usuário confirmar, faz o LOGOUT.
/// Fica como função solta porque também é usada pelo botão da barra superior.
Future<void> confirmarLogout(BuildContext context) async {
  final auth = context.read<AuthController>();
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (dialogo) => AlertDialog(
      title: const Text('Sair'),
      content: const Text('Deseja sair da sua conta?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogo, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(dialogo, true), child: const Text('Sair')),
      ],
    ),
  );
  if (confirmou == true) await auth.deslogarUsuario();
}
