import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
// url_launcher = abre links fora do app (navegador, Google Maps, WhatsApp...)
import 'package:url_launcher/url_launcher.dart';

/// SERVICE do botão "Como chegar" (funcionalidade extra).
/// Monta um link do Google Maps com o destino. No celular, o Android/iOS
/// abre o aplicativo do Google Maps (ou o navegador, se não estiver instalado).
/// Como o link não informa a origem, o Google Maps usa a localização atual do usuário.
class NavegacaoService {
  /// Abre a rota até [destino]. Devolve false se não foi possível abrir.
  Future<bool> abrirRota(LatLng destino) async {
    try {
      final uri = Uri.https('www.google.com', '/maps/dir/', {
        'api': '1', // versão da API de links do Google Maps
        'destination': '${destino.latitude},${destino.longitude}',
        'travelmode': 'driving', // carro (o usuário pode trocar dentro do Maps)
      });
      // externalApplication = abrir FORA do nosso app
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('ERRO ao abrir rota: $e');
      return false;
    }
  }
}
