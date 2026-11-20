import 'package:flutter/material.dart';
import 'package:guia_turismo/services/favoritos_service.dart';

/// CONTROLLER dos FAVORITOS: sabe quais lugares o usuário favoritou
/// e avisa as telas (corações) quando isso muda.
class FavoritosController extends ChangeNotifier {
  final FavoritosService _servico = FavoritosService();

  // Set = lista SEM repetição, perfeita para "este id é favorito?"
  Set<int> _ids = {};
  Set<int> get ids => _ids;

  String _usuarioId = '';
  String erro = '';

  /// Chamado quando o usuário entra: carrega os favoritos DELE.
  Future<void> carregar(String usuarioId) async {
    _usuarioId = usuarioId;
    try {
      _ids = await _servico.carregar(usuarioId);
      erro = '';
    } catch (e) {
      _ids = {};
      erro = 'Não foi possível carregar os favoritos.';
      debugPrint('ERRO favoritos (carregar): $e');
    }
    notifyListeners();
  }

  bool ehFavorito(int idLugar) => _ids.contains(idLugar);

  /// Se já é favorito, remove; se não é, adiciona. Devolve o novo estado.
  Future<bool> alternar(int idLugar) async {
    final favoritoAntes = ehFavorito(idLugar);
    // Atualiza a tela NA HORA (o coração muda de cor sem esperar o disco)
    favoritoAntes ? _ids.remove(idLugar) : _ids.add(idLugar);
    notifyListeners();
    try {
      await _servico.salvar(_usuarioId, _ids);
      erro = '';
    } catch (e) {
      // Se não conseguiu salvar, desfaz a mudança para a tela não mentir
      favoritoAntes ? _ids.add(idLugar) : _ids.remove(idLugar);
      erro = 'Não foi possível salvar o favorito.';
      debugPrint('ERRO favoritos (salvar): $e');
      notifyListeners();
    }
    return ehFavorito(idLugar);
  }
}
