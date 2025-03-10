import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';

void main() {
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
          return ApiService(baseUrl: 'http://192.168.101.101:8084/api');
        }
      },
      child: MaterialApp(
        title: 'Mi Colección de Películas',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          brightness: Brightness.dark,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
