// lib/screens/player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../widgets/custom_video_player.dart';
import 'dart:async';

class PlayerScreen extends StatefulWidget {
  final Movie movie;

  const PlayerScreen({super.key, required this.movie});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();

    // Ocultar la UI del sistema y forzar orientación horizontal
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _initializePlayer() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      // Intenta primero con el video original
      final streamUrl = apiService.getStreamUrl(widget.movie.id);
      _videoPlayerController = VideoPlayerController.networkUrl(
        streamUrl,
        httpHeaders: {
          'Accept-Ranges': 'bytes',
        },
      );

      await _videoPlayerController.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error con video original: $e');

      // Si falla, intenta con video transcodificado
      try {
        // Limpiar el controlador anterior
        await _videoPlayerController.dispose();

        final transcodedUrl =
            apiService.getStreamUrl(widget.movie.id, transcode: true);
        _videoPlayerController =
            VideoPlayerController.networkUrl(transcodedUrl);
        await _videoPlayerController.initialize();

        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      } catch (e) {
        print('Error en reproductor: $e');
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = e.toString();
          });
        }
      }
    }
  }

  @override
  void dispose() {
    // Restaurar UI y orientación
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: _hasError
              ? _buildErrorWidget()
              : !_isInitialized
                  ? _buildLoadingWidget()
                  : CustomVideoPlayer(
                      controller: _videoPlayerController,
                      autoPlay: true,
                    ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Colors.white),
        SizedBox(height: 20),
        Text(
          'Cargando ${widget.movie.title}...',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error, color: Colors.red, size: 60),
        SizedBox(height: 20),
        Text(
          'Error al cargar el video',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _hasError = false;
              _errorMessage = '';
              _initializePlayer();
            });
          },
          child: Text('Reintentar'),
        ),
        SizedBox(height: 10),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Volver'),
          style: TextButton.styleFrom(foregroundColor: Colors.white),
        ),
      ],
    );
  }
}
