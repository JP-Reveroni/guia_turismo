import 'package:flutter/material.dart';
import 'package:guia_turismo/models/resultado_busca_model.dart';
import 'package:guia_turismo/services/geocoding_service.dart';

/// Controller da busca de endereço (Nominatim).
/// Guarda: se está carregando, se deu erro e qual foi o resultado.
/// O formulário de cadastro "escuta" este controller com um Consumer.
class GeocodingController extends ChangeNotifier {
  final GeocodingService _servico = GeocodingService();

  bool carregando = false;
  String erro = "";
  ResultadoBuscaModel? resultado; // último endereço encontrado

  /// Busca o endereço/CEP e devolve o resultado (ou null se não achou).
  Future<ResultadoBuscaModel?> buscar(String texto) async {
    carregando = true;
    erro = "";
    resultado = null;
    notifyListeners(); // mostra o loading no botão

    try {
      resultado = await _servico.buscar(texto);
      if (resultado == null) {
        erro = "Endereço não encontrado. Tente incluir cidade e estado.";
      }
    } catch (e) {
      erro = "Erro ao buscar endereço. Verifique sua conexão.";
      debugPrint("ERRO geocoding: $e");
    } finally {
      carregando = false;
      notifyListeners(); // tira o loading e mostra resultado/erro
    }
    return resultado;
  }

  /// Limpa o estado (chamado toda vez que o formulário é aberto)
  void limpar() {
    carregando = false;
    erro = "";
    resultado = null;
    notifyListeners();
  }
}
