import 'package:shared_preferences/shared_preferences.dart';

/// SERVICE dos FAVORITOS: guarda no próprio aparelho (SharedPreferences)
/// os ids dos lugares favoritados. Cada usuário tem a sua lista,
/// porque a chave inclui o id da pessoa logada.
class FavoritosService {
  //Ex.: "favoritos_AbC123" (uma lista para cada usuário)
  String _chave(String usuarioId) => 'favoritos_$usuarioId';

  /// Lê os ids favoritos salvos deste usuário.
  Future<Set<int>> carregar(String usuarioId) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_chave(usuarioId)) ?? [];
    //SharedPreferences só guarda texto, então convertemos de volta para número
    return lista.map(int.tryParse).whereType<int>().toSet();
  }

  /// Salva a lista completa de ids favoritos deste usuário.
  Future<void> salvar(String usuarioId, Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _chave(usuarioId),
      ids.map((id) => id.toString()).toList(),
    );
  }
}
