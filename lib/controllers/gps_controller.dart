import 'package:flutter/material.dart';
import 'package:guia_turismo/services/gps_service.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:latlong2/latlong.dart';

/// CONTROLLER = guarda o ESTADO e avisa a tela quando algo muda.
/// Ele estende ChangeNotifier: quando chamamos notifyListeners(), todo
/// widget que está "escutando" (Consumer) é reconstruído com os dados novos.
class GpsController extends ChangeNotifier {
  // O controller conversa com o service; a tela nunca fala direto com o GPS
  final GpsService _servico = GpsService();

  LatLng? atual; // posição do usuário (null = ainda não sabemos)
  bool carregando = false; // true enquanto espera o GPS responder
  String erro = ""; // mensagem de erro para mostrar na tela

  // OBS: no projeto "maps" original existia uma lista "pontos" com a posição
  // do usuário e o buscarLocal() era chamado aqui no construtor.
  // No guia_turismo os pins vêm dos LUGARES cadastrados (LugaresController),
  // e a localização só é pedida quando o usuário abre a tela do mapa
  // (assim o pop-up de permissão não aparece já na tela de login).

  Future<void> buscarLocal() async {
    carregando = true;
    erro = ""; // limpa erro antigo antes de tentar de novo
    notifyListeners(); // avisa a tela: "mostra o loading"
    try {
      atual = await _servico.obterLocal();
      if (atual == null && erro.isEmpty) {
        erro = "Não foi possível obter sua localização";
      }
    } catch (e) {
      // Tira o "Exception: " do começo para a mensagem ficar bonita na tela
      erro = e.toString().replaceFirst('Exception: ', '');
      atual = null;
      debugPrint("ERRO: $erro");
    } finally {
      // finally roda sempre, dando certo ou errado
      carregando = false;
      notifyListeners(); // avisa a tela: "terminou, atualiza"
    }
  }

  /// DISTÂNCIA do usuário até um lugar, já formatada ("850 m" ou "2,4 km").
  /// Devolve null se ainda não sabemos onde o usuário está.
  String? distanciaAte(LugaresModel lugar) {
    if (atual == null) return null;
    final metros = _servico.distanciaEmMetros(
      atual!,
      LatLng(lugar.latitude.toDouble(), lugar.longitude.toDouble()),
    );
    if (metros < 1000) return '${metros.round()} m';
    // toStringAsFixed(1) = 1 casa decimal; trocamos o ponto por vírgula (padrão brasileiro)
    return '${(metros / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
  }
}
