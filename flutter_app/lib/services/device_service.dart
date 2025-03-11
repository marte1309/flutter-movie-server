import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

class DeviceService {
  static const MethodChannel _channel =
      MethodChannel('com.marianosoft.mmovies/device');

  static Future<bool> isTV(BuildContext context) async {
    // Imprime dimensiones para debug
    final size = MediaQuery.of(context).size;
    print('Ancho: ${size.width}, Alto: ${size.height}');

    // En Android, podemos detectar Android TV específicamente
    if (Platform.isAndroid) {
      try {
        final bool isAndroidTV = await _channel.invokeMethod('isAndroidTV');
        print('Es Android TV: $isAndroidTV');
        return isAndroidTV;
      } catch (e) {
        print('Error detectando Android TV: $e');
        // Fallback a detección por tamaño si falla el método nativo
      }
    }

    // También podemos considerar como TV dispositivos con relación de aspecto mayor a 16:9
    final aspectRatio = size.width / size.height;
    final bool isTVByAspectRatio =
        aspectRatio > 1.8; // TV típicas tienen 16:9 (1.78) o mayor

    // La combinación de aspectRatio ancho junto con pantalla grande suele indicar TV
    final bool isLargeScreen = size.width > 1000;

    final result = isTVByAspectRatio || isLargeScreen;
    print('Es un ${result ? "TV" : "dispositivo móvil"}');
    return result;
  }
}
