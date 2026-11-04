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
  Future<LatLng?> obterLocal() async {
    // 1) O GPS/serviço de localização do aparelho está ligado?
    bool ativo = await Geolocator.isLocationServiceEnabled();
    if (!ativo) return null;

    // 2) O app tem permissão para usar a localização?
    LocationPermission permissao = await Geolocator.checkPermission();

    // Se ainda não foi decidido (denied), abre aquele pop-up pedindo permissão
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    // Se o usuário marcou "nunca mais perguntar", não adianta insistir:
    // só ele consegue liberar nas configurações do aparelho.
    // (Também tratamos o caso de ele ter negado de novo no pop-up acima.)
    if (permissao == LocationPermission.deniedForever ||
        permissao == LocationPermission.denied) {
      return null;
    }

    // 3) Com tudo liberado, pede a posição atual
    try {
      Position posicao = await Geolocator.getCurrentPosition();
      // Converte o objeto Position (do geolocator) para LatLng (do mapa)
      return LatLng(posicao.latitude, posicao.longitude);
    } catch (erro) {
      // Se algo falhar (timeout, sinal ruim...) só registra no console e devolve null
      debugPrint("ERRO ao obter posição: $erro");
      return null;
    }
  }
}
