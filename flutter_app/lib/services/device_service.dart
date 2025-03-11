// lib/services/device_service.dart
import 'package:flutter/material.dart';

class DeviceService {
  static bool isTV(BuildContext context) {
    // Las TVs típicamente tienen pantallas grandes y ratios específicos
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Si el dispositivo es más ancho que alto, o tiene una pantalla muy grande
    // probablemente sea una TV o dispositivo tipo TV
    return (width > height && width > 1200) ||
        (width * height >
            1000000); // Pantalla grande (más de 1 millón de píxeles)
  }
}
