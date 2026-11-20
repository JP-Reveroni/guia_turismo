import 'package:flutter/material.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:guia_turismo/services/lugares_services.dart';
import 'package:guia_turismo/services/navegacao_service.dart';
import 'package:guia_turismo/services/session_service.dart';
import 'package:latlong2/latlong.dart';

class LugaresController extends ChangeNotifier {
  bool carregando = false;
  String erro = "";
  List<LugaresModel> _lugares = [];
  List<LugaresModel> get lugares => _lugares;

  // Informa se o ÚLTIMO cadastro deu certo (a tela usa para decidir se fecha o formulário)
  bool cadastroOk = false;

  // ---------------- FILTROS (funcionalidade extra) ----------------
  // null = "Todas" as categorias
  String? categoriaSelecionada;
  // true = mostra só os lugares favoritados
  bool apenasFavoritos = false;

  LugaresController(){
    listaLugares();
  }

  Future<void> listaLugares() async {
    carregando = true;
    erro = ""; // limpa erro antigo, senão a tela ficaria mostrando erro para sempre
    notifyListeners();
    try{
      final lugaresService = LugaresServices();
      final listaLugares = await lugaresService.buscarLugares();
      _lugares = listaLugares;
    } catch (error) {
      erro = "Não foi possível carregar os lugares. Verifique sua conexão.";
      debugPrint("ERRO ao listar: $error");
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<String> cadastrarLugar(LugaresModel dados) async {
    final token = await SessionService().pegarToken() ?? '';
    cadastroOk = false;
    //Quem entrou só com o Google não tem token da API, então não pode cadastrar
    if (token.isEmpty) {
      return "Para cadastrar lugares, saia e entre com e-mail e senha.";
    }
    carregando = true;
    erro = "";
    notifyListeners();

    try{
      final lugaresService = LugaresServices();
      //Gera uma autenticação permitindo registro de dados na api
      final resposta = await lugaresService.cadastrarLugar(dados, token);
      cadastroOk = true;
      await listaLugares();
      return resposta;
    } catch (e){
      erro = "Erro ao cadastrar: $e";
      return erro;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  // ---------------- FILTROS ----------------

  /// Nomes das categorias que existem nos lugares carregados (sem repetir, em ordem alfabética).
  List<String> get categorias {
    final nomes = _lugares
        .map((l) => l.categoria ?? '')
        .where((nome) => nome.isNotEmpty)
        .toSet()
        .toList();
    nomes.sort();
    return nomes;
  }

  void selecionarCategoria(String? categoria) {
    categoriaSelecionada = categoria;
    notifyListeners();
  }

  void alternarApenasFavoritos() {
    apenasFavoritos = !apenasFavoritos;
    notifyListeners();
  }

  /// Aplica os filtros escolhidos e devolve só os lugares que combinam.
  /// [favoritos] = ids favoritados (vem do FavoritosController).
  List<LugaresModel> lugaresFiltrados(Set<int> favoritos) {
    return _lugares.where((lugar) {
      final categoriaOk = categoriaSelecionada == null ||
          lugar.categoria == categoriaSelecionada;
      final favoritoOk = !apenasFavoritos || favoritos.contains(lugar.id);
      return categoriaOk && favoritoOk;
    }).toList();
  }

  // ---------------- COMO CHEGAR (funcionalidade extra) ----------------

  /// Abre o Google Maps com a rota até o lugar. Devolve false se não conseguiu abrir.
  Future<bool> comoChegar(LugaresModel lugar) {
    return NavegacaoService().abrirRota(
      LatLng(lugar.latitude.toDouble(), lugar.longitude.toDouble()),
    );
  }
}
