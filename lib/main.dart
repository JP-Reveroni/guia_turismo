
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guia_turismo/controllers/auth_controller.dart';
import 'package:guia_turismo/controllers/camera_controller.dart';
import 'package:guia_turismo/controllers/favoritos_controller.dart';
import 'package:guia_turismo/controllers/geocoding_controller.dart';
import 'package:guia_turismo/controllers/gps_controller.dart';
import 'package:guia_turismo/controllers/lugares_controller.dart';
import 'package:guia_turismo/controllers/theme_controller.dart';
import 'package:guia_turismo/firebase_options.dart';
//import 'package:guia_turismo/inicializar.dart'; No fim, nem vai ser usado no projeto
import 'package:guia_turismo/screens/auth_gate.dart';
import 'package:guia_turismo/screens/camera_screen.dart';
import 'package:guia_turismo/screens/cadastro_lugar.dart';
//import 'package:guia_turismo/screens/lugares_screen.dart'; Não vai ser usado devido o cadastro_lugar fazer o que ele faz, mas não vou deletar o codigo kkk
import 'package:provider/provider.dart';

// main agora é "async" porque precisamos ESPERAR o Firebase iniciar antes de abrir o app
Future<void> main() async {
  // Obrigatório antes de usar plugins (Firebase, GPS...) antes do runApp
  WidgetsFlutterBinding.ensureInitialized();

  // TRATAMENTO DE ERROS GLOBAL: se algum erro "escapar" sem try/catch,
  // ele é só registrado no console em vez de fechar o aplicativo.
  FlutterError.onError = (detalhes) {
    debugPrint('ERRO Flutter: ${detalhes.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (erro, pilha) {
    debugPrint('ERRO não tratado: $erro');
    return true; // true = "já cuidei deste erro", não derruba o app
  };

  // Inicia o Firebase com as chaves do projeto (arquivo firebase_options.dart,
  // gerado pelo FlutterFire CLI). Se falhar (ex.: plataforma sem configuração),
  // o app abre mesmo assim e só desativa o botão "Entrar com o Google".
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('ERRO ao iniciar o Firebase: $e');
  }

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
      //Controller de login: junta Google (Firebase) + e-mail/senha (API) e guarda a sessão
      ChangeNotifierProvider(create: (_) => AuthController()),
      ChangeNotifierProvider(create: (_) => ThemeController()),
      ChangeNotifierProvider(create: (_) => CameraController()),
      //Controller do GPS: usado pela tela do mapa
      ChangeNotifierProvider(create: (_) => GpsController()),
      //Controller da busca de endereço/CEP (Nominatim): usado no cadastro de lugares
      ChangeNotifierProvider(create: (_) => GeocodingController()),
      //Controller dos favoritos do usuário logado
      ChangeNotifierProvider(create: (_) => FavoritosController()),
    ],
    child: Consumer<ThemeController>(
      builder: (context, controllerThema, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: controllerThema.temaClaro(),
        darkTheme: controllerThema.temaEscuro(),
        themeMode: controllerThema.temaAtual,
        //Em vez de initialRoute: 'login', o AuthGate escolhe sozinho entre Login e Home
        home: const AuthGate(),
        routes: {
          'lugares': (context) => LugaresScreen(),
          'camera': (context) => CameraScreen()
        },
      ),
    ),
    );
  }
}
