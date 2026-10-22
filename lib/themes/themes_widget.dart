import 'package:flutter/material.dart';

AppBarTheme defineAppBar(cor) {
  return AppBarTheme(
    centerTitle: true,
    backgroundColor: Colors.amber,
    foregroundColor: cor.onPrimary, //cor de texto
    elevation: 4, //Box shadow
  );
}

BottomNavigationBarThemeData defineNavegacaoBase(cor) {
  return BottomNavigationBarThemeData(
    backgroundColor: Colors.deepOrange,
    elevation: 4,
  );
}

ElevatedButtonThemeData defineBotaoElevated(cor) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: cor.primary,
      foregroundColor: cor.onPrimary,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}