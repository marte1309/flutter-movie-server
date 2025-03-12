// lib/widgets/custom_video_player.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class CustomVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final bool autoPlay;

  const CustomVideoPlayer({
    Key? key,
    required this.controller,
    this.autoPlay = true,
  }) : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _controller;
  bool _showControls = true;
  bool _isPlaying = false;
  Timer? _hideControlsTimer;
  double _seekBarValue = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _isPlaying = widget.autoPlay;

    // Cuando inicia, si autoPlay es true, empezar a reproducir el video
    if (widget.autoPlay) {
      _controller.play();
      _startHideControlsTimer();
      WakelockPlus.enable(); // Mantener la pantalla encendida
    }

    // Escuchar los cambios en el estado del controlador
    _controller.addListener(_videoPlayerListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_videoPlayerListener);
    _hideControlsTimer?.cancel();
    WakelockPlus.disable(); // Desactivar wakelock al salir
    super.dispose();
  }

  void _videoPlayerListener() {
    if (_controller.value.position == _controller.value.duration) {
      // Video terminado
      setState(() {
        _isPlaying = false;
        _showControls = true;
      });
    }

    if (!_isDragging && _controller.value.isPlaying) {
      // Actualizar el valor de la barra de búsqueda solo si no estamos arrastrando
      final duration = _controller.value.duration.inMilliseconds;
      if (duration > 0) {
        setState(() {
          _seekBarValue = _controller.value.position.inMilliseconds / duration;
        });
      }
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(Duration(seconds: 3), () {
      if (_isPlaying && mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
        _showControls = true;
        _hideControlsTimer?.cancel();
      } else {
        _controller.play();
        _isPlaying = true;
        _startHideControlsTimer();
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls && _isPlaying) {
        _startHideControlsTimer();
      }
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  void _seekToRelative(double value) {
    final duration = _controller.value.duration;
    final position = duration * value;
    _controller.seekTo(position);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        children: [
          // Video Player
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),

          // Controles
          if (_showControls)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

          // Botones de control
          if (_showControls)
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Barra superior
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.fullscreen, color: Colors.white),
                        onPressed: () {
                          // La pantalla completa ya es manejada por la pantalla
                        },
                      ),
                    ],
                  ),
                ),

                // Barra de controles inferior
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Barra de progreso
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Text(
                            _formatDuration(_controller.value.position),
                            style: TextStyle(color: Colors.white),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 8.0),
                                overlayShape: RoundSliderOverlayShape(
                                    overlayRadius: 16.0),
                                trackHeight: 4.0,
                                activeTrackColor: Colors.red,
                                inactiveTrackColor:
                                    Colors.white.withOpacity(0.3),
                                thumbColor: Colors.red,
                              ),
                              child: Slider(
                                value: _seekBarValue.clamp(0.0, 1.0),
                                onChanged: (value) {
                                  setState(() {
                                    _seekBarValue = value;
                                    _isDragging = true;
                                  });
                                },
                                onChangeStart: (value) {
                                  _isDragging = true;
                                  _hideControlsTimer?.cancel();
                                },
                                onChangeEnd: (value) {
                                  _isDragging = false;
                                  _seekToRelative(value);
                                  _startHideControlsTimer();
                                },
                              ),
                            ),
                          ),
                          Text(
                            _formatDuration(_controller.value.duration),
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    // Botones principales
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(Icons.replay_10, color: Colors.white),
                            onPressed: () {
                              final newPosition = _controller.value.position -
                                  Duration(seconds: 10);
                              _controller.seekTo(newPosition < Duration.zero
                                  ? Duration.zero
                                  : newPosition);
                              _startHideControlsTimer();
                            },
                          ),
                          IconButton(
                            iconSize: 60,
                            icon: Icon(
                              _isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              color: Colors.white,
                            ),
                            onPressed: _togglePlayPause,
                          ),
                          IconButton(
                            icon: Icon(Icons.forward_10, color: Colors.white),
                            onPressed: () {
                              final newPosition = _controller.value.position +
                                  Duration(seconds: 10);
                              final duration = _controller.value.duration;
                              _controller.seekTo(newPosition > duration
                                  ? duration
                                  : newPosition);
                              _startHideControlsTimer();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

          // Indicador de carga
          if (_controller.value.isBuffering)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
