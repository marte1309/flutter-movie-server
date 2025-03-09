# Flutter Movie App

Aplicación móvil para visualizar y reproducir películas desde un servidor casero.

## Características

- Visualización de colección de películas en una cuadrícula
- Miniaturas para cada película
- Reproducción de video con controles personalizados
- Modo de pantalla completa
- Escaneo automático de nuevas películas
- Interfaz de usuario intuitiva y moderna

## Requisitos

- Flutter 2.5+
- Dart 2.14+
- Conexión a internet para conectarse al servidor

## Configuración

1. Clona este repositorio
2. Instala las dependencias:

```bash
cd flutter_app
flutter pub get
```

3. Crea un archivo `.env` basado en `.env.example` con la dirección IP de tu servidor

4. Ejecuta la aplicación:

```bash
flutter run
```

## Estructura del proyecto

```
flutter_app/
  ├── lib/
  │   ├── main.dart           # Punto de entrada
  │   ├── models/             # Modelos de datos
  │   ├── screens/            # Pantallas de la aplicación
  │   ├── services/           # Servicios de API
  │   └── widgets/            # Widgets reutilizables
  ├── pubspec.yaml            # Dependencias y configuración
  └── .env.example            # Configuración de ejemplo
```

## Permisos requeridos

### Android

Añade los siguientes permisos en `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

### iOS

Añade lo siguiente en `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Funcionamiento

La aplicación se conecta al servidor backend Node.js que escanea y sirve las películas. La aplicación Flutter muestra la colección de películas, permite la navegación y la reproducción de video.

1. La pantalla de inicio muestra un grid con todas las películas disponibles
2. Al seleccionar una película, se muestra una pantalla detallada con información
3. El botón "Reproducir" inicia la reproducción de la película
4. El reproductor de video permite controles básicos (reproducir, pausar, avanzar, retroceder)

## Características futuras

- Soporte para subtítulos
- Historial de reproducción
- Sincronización de progreso entre dispositivos
- Modo sin conexión (descargar películas)
- Búsqueda y filtrado por género, año, etc.
- Integración con APIs de metadatos de películas