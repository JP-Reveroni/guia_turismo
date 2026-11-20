# guia_turismo

Guia turístico em Flutter: login com Google, mapa (OpenStreetMap), GPS, favoritos, filtros e "Como chegar".

## Como rodar
```bash
flutter pub get
flutter run
```

## Funcionalidades
| Requisito | Onde está |
|---|---|
| Login com Google + sessão + logout | `services/google_auth_service.dart`, `controllers/auth_controller.dart`, `screens/auth_gate.dart`, `screens/login_screen.dart`, `widgets/perfil_usuario.dart` |
| Mapa OpenStreetMap + pins com foto + minha localização | `screens/mapa_screen.dart`, `widgets/pin_lugar.dart`, `widgets/foto_lugar.dart` |
| GPS e distância | `services/gps_service.dart`, `controllers/gps_controller.dart` (`distanciaAte`) |
| Favoritos (por usuário) | `services/favoritos_service.dart`, `controllers/favoritos_controller.dart`, `widgets/botao_favorito.dart` |
| Extra: Como chegar (Google Maps) | `services/navegacao_service.dart`, `widgets/detalhes_lugar.dart` |
| Extra: Filtros por categoria/favoritos | `widgets/filtro_categorias.dart`, `controllers/lugares_controller.dart` |

## Login com Google - configuração (Android)
- O `android/app/google-services.json` é do projeto Firebase `login-e31de`, registrado com o pacote `com.example.login`.
  Por isso o `applicationId` do app é `com.example.login` (em `android/app/build.gradle.kts`).
- A impressão digital **SHA-1** da sua máquina precisa estar cadastrada no Firebase (Configurações do projeto > seu app Android).
  Para ver o SHA-1: `cd android && ./gradlew signingReport`.
- Na web, `localhost` já é um domínio autorizado por padrão no Firebase Authentication.
- iOS/macOS/Windows/Linux: o app abre normalmente, mas o botão do Google fica desativado (sem configuração do Firebase).

## Login por e-mail e senha (API)
Continua existindo porque somente a API gera o token necessário para **cadastrar lugares**.
Quem entra só com o Google pode ver mapa, lista e favoritos, mas não cadastra lugares.
