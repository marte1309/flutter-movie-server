import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'services/device_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
        create: (_) {
          try {
            return ApiService();
          } catch (e) {
            print("Error al crear ApiService: $e");
            // Retorna una versión fallback o con una URL hardcodeada
            return ApiService(baseUrl: 'http://192.168.101.106:8084/api');
          }
        },
        child: MaterialApp(
          title: 'Mi Colección de Películas',
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            brightness: Brightness.dark,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            focusColor: Colors.indigo[300],
          ),
          home: const OrientationHandler(child: HomeScreen()),
        ));
  }
}

class OrientationHandler extends StatefulWidget {
  final Widget child;

  const OrientationHandler({
    super.key,
    required this.child,
  });

  @override
  State<OrientationHandler> createState() => _OrientationHandlerState();
}

class _OrientationHandlerState extends State<OrientationHandler> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _setOrientation();
      _isInitialized = true;
    }
  }

  Future<void> _setOrientation() async {
    try {
      final isTV = await DeviceService.isTV(context);

      if (isTV) {
        // Para TV, preferimos formato landscape
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        print('Estableciendo orientación de TV (landscape)');
      } else {
        // Para celulares, formato portrait
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        print('Estableciendo orientación de celular (portrait)');
      }
    } catch (e) {
      print('Error al establecer orientación: $e');
      // Configuración por defecto en caso de error
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
