import 'package:flutter/material.dart';
import 'package:guia_turismo/controller/auth_controller.dart';
import 'package:guia_turismo/controller/camera_controller.dart';
import 'package:guia_turismo/controller/lugares_controller.dart';
import 'package:guia_turismo/controller/theme_controller.dart';
//import 'package:guia_turismo/inicializar.dart';
import 'package:guia_turismo/screens/cadastro_lugar.dart';
import 'package:guia_turismo/screens/home_screen.dart';
import 'package:guia_turismo/screens/login_screen.dart';
import 'package:guia_turismo/screens/lugares_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(inicializar());
}

class inicializar extends StatefulWidget {
  const inicializar({super.key});

  @override
  State<inicializar> createState() => _inicializarState();
}

class _inicializarState extends State<inicializar> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => LugaresController()),
      ChangeNotifierProvider(create: (_) => AuthController()),
      ChangeNotifierProvider(create: (_) => ThemeController()),
      ChangeNotifierProvider(create: (_) => CameraController()),
    ],
    child: Consumer<ThemeController>(
      builder: (context, controllerThema, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: controllerThema.temaClaro(),
        darkTheme: controllerThema.temaEscuro(),
        themeMode: controllerThema.temaAtual,
        initialRoute: 'login',
        routes: {
          'login': (context) => LoginScreen(),
          'home': (context) => HomeScreen(),
          'lugares': (context) => LugaresScreen(),
          'cadastro': (context) => CadastroLugar()
        },
      ),
    ),
    );
  }
}