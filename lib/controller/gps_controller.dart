import 'package:flutter/material.dart';
import 'package:guia_turismo/services/gps_service.dart';
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
      if (atual == null) {
        erro = "Não foi possível obter sua localização";
      }
    } catch (e) {
      erro = e.toString();
      debugPrint("ERRO: $erro");
    } finally {
      // finally roda sempre, dando certo ou errado
      carregando = false;
      notifyListeners(); // avisa a tela: "terminou, atualiza"
    }
  }
}
