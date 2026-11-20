import 'package:flutter/foundation.dart';
// geolocator = pacote que conversa com o GPS do aparelho (ou com o navegador, na web)
import 'package:geolocator/geolocator.dart';
// latlong2 = pacote que fornece a classe LatLng (um par latitude/longitude)
import 'package:latlong2/latlong.dart';

/// SERVICE = a camada que "fala com o mundo externo".
/// Aqui o mundo externo é o GPS do celular. A tela e o controller
/// não precisam saber COMO a posição é obtida, só pedem "me dá o local".
class GpsService {
  /// Devolve a posição atual do usuário, ou null se não for possível obter.
  /// Future = o resultado não vem na hora (GPS demora), por isso é assíncrono.
  /// Quando não dá para obter, lança um Exception com uma mensagem clara
  /// (o GpsController captura e mostra na tela, sem travar o app).
  Future<LatLng?> obterLocal() async {
    // 1) O GPS/serviço de localização do aparelho está ligado?
    bool ativo = await Geolocator.isLocationServiceEnabled();
    if (!ativo) {
      throw Exception('O GPS está desligado. Ative a localização do aparelho.');
    }

    // 2) O app tem permissão para usar a localização?
    LocationPermission permissao = await Geolocator.checkPermission();

    // Se ainda não foi decidido (denied), abre aquele pop-up pedindo permissão
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    // Se o usuário marcou "nunca mais perguntar", não adianta insistir:
    // só ele consegue liberar nas configurações do aparelho.
    if (permissao == LocationPermission.deniedForever) {
      throw Exception(
          'Permissão de localização bloqueada. Libere nas configurações do aparelho.');
    }
    // Negou no pop-up acima
    if (permissao == LocationPermission.denied) {
      throw Exception('Permissão de localização negada.');
    }

    // 3) Com tudo liberado, pede a posição atual
    try {
      Position posicao = await Geolocator.getCurrentPosition(
        // timeLimit evita ficar esperando para sempre quando o sinal é ruim
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      // Converte o objeto Position (do geolocator) para LatLng (do mapa)
      return LatLng(posicao.latitude, posicao.longitude);
    } catch (erro) {
      // Se algo falhar (timeout, sinal ruim...) só registra no console e devolve null
      debugPrint("ERRO ao obter posição: $erro");
      return null;
    }
  }

  /// DISTÂNCIA em metros entre dois pontos (em linha reta).
  /// Usa a classe Distance do latlong2, que já faz a conta da curvatura da Terra.
  double distanciaEmMetros(LatLng origem, LatLng destino) {
    return const Distance().as(LengthUnit.Meter, origem, destino);
  }
}
