import 'package:flutter/material.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:guia_turismo/services/lugares_services.dart';
import 'package:guia_turismo/services/session_service.dart';

class LugaresController extends ChangeNotifier {
  bool carregando = false;
  String erro = "";
  List<LugaresModel> _lugares = [];
  List<LugaresModel> get lugares => _lugares;

  LugaresController(){
    listaLugares();
  }

  Future<void> listaLugares() async {
    carregando = true;
    notifyListeners();
    try{
      final lugaresService = LugaresServices();
      final listaLugares = await lugaresService.buscarLugares();
      _lugares = listaLugares;
    } catch (error) {
      erro = "Erro ao listar: ${error.toString()}";
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<String> cadastrarLugar(LugaresModel dados) async {
    final token = await SessionService().pegarToken() ?? '';
    carregando = true;
    erro = "";
    notifyListeners();

    try{
      final lugaresService = LugaresServices();
      //Gera uma autenticação permitindo registro de dados na api
      final resposta = await lugaresService.cadastrarLugar(dados, token);
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

}