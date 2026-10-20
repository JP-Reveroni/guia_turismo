import 'package:flutter/material.dart';
import 'package:guia_turismo/controller/theme_controller.dart';
import 'package:guia_turismo/screens/home_screen.dart';
import 'package:provider/provider.dart';

class Inicializar extends StatelessWidget {
  const Inicializar({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, controllerThema, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: 'home',
          theme: controllerThema.temaClaro(),
          darkTheme: controllerThema.temaEscuro(),
          themeMode: controllerThema.temaAtual,
          routes: {'home': (context) => HomeScreen()},
        ),
      ),
    );
  }
}
