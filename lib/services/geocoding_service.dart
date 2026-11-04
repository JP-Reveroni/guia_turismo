import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:guia_turismo/models/resultado_busca_model.dart';

/// Service que transforma ENDEREÇO / CEP em LATITUDE e LONGITUDE.
/// Isso se chama GEOCODIFICAÇÃO (geocoding).
///
/// API usada: Nominatim (OpenStreetMap)
/// https://wiki.openstreetmap.org/wiki/Nominatim
///
/// Regras de uso da API pública (política do Nominatim):
///  - no máximo 1 requisição por segundo;
///  - identificar o app (cabeçalho User-Agent);
///  - NÃO usar para "autocompletar enquanto digita" -> por isso a busca
///    só acontece quando o usuário aperta o botão da lupa.
class GeocodingService {
  // Endereço base da API e do caminho de busca: https://nominatim.openstreetmap.org/search
  static const String _hostNominatim = 'nominatim.openstreetmap.org';

  // API gratuita de CEP (devolve rua, cidade e estado a partir do CEP).
  // O Nominatim sozinho conhece pouco os CEPs do Brasil, então usamos o ViaCEP
  // só para descobrir a RUA e depois o Nominatim acha as coordenadas dela.
  static const String _hostViaCep = 'viacep.com.br';

  /// Recebe o que o usuário digitou (endereço ou CEP) e devolve o 1º resultado
  /// encontrado, ou null se o Nominatim não achou nada.
  Future<ResultadoBuscaModel?> buscar(String texto) async {
    String consulta = texto.trim();
    if (consulta.isEmpty) return null;

    // 1) O texto parece um CEP? (só números, espaço, ponto ou hífen, com 8 dígitos)
    final apenasDigitos = consulta.replaceAll(RegExp(r'\D'), '');
    final pareceCep =
        RegExp(r'^[\d\s.\-]+$').hasMatch(consulta) && apenasDigitos.length == 8;

    if (pareceCep) {
      // Troca o CEP por um endereço "de verdade" (ex: "Avenida Paulista, São Paulo, SP, Brasil").
      // Se o ViaCEP não souber, usamos o próprio CEP na busca como plano B.
      consulta = await _cepParaEndereco(apenasDigitos) ?? '$apenasDigitos, Brasil';
    }

    // 2) Monta a URL de forma segura. O Uri já faz o "encode" dos acentos e espaços.
    // Resultado parecido com:
    // https://nominatim.openstreetmap.org/search?q=Avenida+Paulista&format=jsonv2&limit=1...
    final uri = Uri.https(_hostNominatim, '/search', {
      'q': consulta, // o que estamos procurando
      'format': 'jsonv2', // queremos a resposta em JSON
      'limit': '1', // só o melhor resultado
      'countrycodes': 'br', // limita a busca ao Brasil
      'accept-language': 'pt-BR', // nomes em português
    });

    // 3) Cabeçalhos da requisição.
    // O navegador (web) NÃO permite trocar o User-Agent e ele ainda
    // causaria erro de CORS, então só enviamos quando NÃO é web.
    final headers = <String, String>{
      if (!kIsWeb) 'User-Agent': 'br.com.guiaturismo.maps (app de aula Flutter)',
    };

    // 4) Faz o GET. timeout evita ficar esperando para sempre se a rede cair.
    final resposta = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 10));

    if (resposta.statusCode != 200) {
      throw Exception('Erro na busca de endereço (${resposta.statusCode})');
    }

    // 5) A resposta é uma LISTA de resultados. Lista vazia = nada encontrado.
    final List<dynamic> lista = jsonDecode(resposta.body);
    if (lista.isEmpty) return null;

    // Pega o primeiro item e transforma no nosso model
    return ResultadoBuscaModel.fromJson(lista.first as Map<String, dynamic>);
  }

  /// Consulta o ViaCEP e devolve um texto de endereço, ou null se não achar.
  /// Nunca lança erro: se der qualquer problema, só devolve null
  /// e a busca continua com o CEP puro.
  Future<String?> _cepParaEndereco(String cep) async {
    try {
      final resposta = await http
          .get(Uri.https(_hostViaCep, '/ws/$cep/json/'))
          .timeout(const Duration(seconds: 8));
      if (resposta.statusCode != 200) return null;

      final Map<String, dynamic> dados = jsonDecode(resposta.body);
      // Quando o CEP não existe, o ViaCEP responde {"erro": true}
      if (dados['erro'] != null) return null;

      final rua = (dados['logradouro'] ?? '').toString();
      final cidade = (dados['localidade'] ?? '').toString();
      final uf = (dados['uf'] ?? '').toString();

      // CEPs de cidades pequenas não têm rua, então a rua é opcional
      return [rua, cidade, uf, 'Brasil'].where((p) => p.isNotEmpty).join(', ');
    } catch (e) {
      debugPrint('ViaCEP falhou: $e');
      return null;
    }
  }
}
