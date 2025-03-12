// lib/screens/player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

class PlayerScreen extends StatefulWidget {
  final Movie movie;

  const PlayerScreen({super.key, required this.movie});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    // Solo ocultar la UI del sistema, pero no forzar orientación aquí
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Forzar orientación horizontal
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _configureChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControls: true,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            'Error: $errorMessage',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );

    setState(() {
      _isInitialized = true;
    });
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

      _configureChewieController();
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

        _configureChewieController();

        // ignore: use_build_context_synchronously
        print('Error on Movies: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error on Movies: $e')),
        );
      } catch (e) {
        setState(() {
          _hasError = true;
        });
        // Mostrar mensaje de error
        // ignore: use_build_context_synchronously
        print('Error on Movies: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error on Movies: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    // Restaurar UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Restaurar orientación
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    _videoPlayerController.dispose();
    _chewieController?.dispose();
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
                  : Chewie(controller: _chewieController!),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
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
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _hasError = false;
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
        ),
      ],
    );
  }
}
