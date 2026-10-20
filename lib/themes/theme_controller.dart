import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier{
  ThemeMode _temaAtual = ThemeMode.light;
  ThemeMode get temaAtual => _temaAtual;

  IconData get iconeAtual => _temaAtual == ThemeMode.light 
  ? Icons.light_mode : Icons.dark_mode;

  static ThemeData _mudarTema(Brightness brilho){
    final cor = ColorScheme.fromSeed(
      seedColor: Colors.lightBlue,
      brightness: brilho
    );
    return ThemeData(
      primarySwatch: Colors.cyan,
      colorScheme: cor,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: cor.primary,
        foregroundColor: cor.onPrimary,
        elevation: 4,//Box shadow
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cor.primary,
        elevation: 4
      ),
    );
  }
    ThemeData temaClaro() => _mudarTema(Brightness.light);
    ThemeData temaEscuro() => _mudarTema(Brightness.dark);

    void alternarTema(){
      _temaAtual = _temaAtual == ThemeMode.light ? ThemeMode.dark: ThemeMode.light;
      notifyListeners(); //Avisa a tela que atualizou "eventListener"
    }

}