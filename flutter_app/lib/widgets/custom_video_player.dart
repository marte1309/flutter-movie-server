// lib/widgets/custom_video_player.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class CustomVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final bool autoPlay;
  final VoidCallback? onVideoEnd;
  final VoidCallback? onNextEpisode;
  final VoidCallback? onPreviousEpisode;

  const CustomVideoPlayer({
    Key? key,
    required this.controller,
    this.autoPlay = true,
    this.onVideoEnd,
    this.onNextEpisode,
    this.onPreviousEpisode,
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

  // Opciones simuladas para las pistas de audio y subtítulos
  final List<String> _audioTracks = ['Español', 'Inglés', 'Japonés', 'Ninguno'];
  String _selectedAudioTrack = 'Español';

  final List<String> _subtitleTracks = [
    'Español',
    'Inglés',
    'Francés',
    'Ninguno'
  ];
  String _selectedSubtitleTrack = 'Ninguno';

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

      // Llamar al callback onVideoEnd si está definido
      if (widget.onVideoEnd != null) {
        // Pequeño retraso para permitir que el último fotograma se muestre
        Future.delayed(Duration(seconds: 1), widget.onVideoEnd);
      }
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

  void _showAudioOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text('Pistas de audio', style: TextStyle(color: Colors.white)),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _audioTracks.length,
              itemBuilder: (context, index) {
                final track = _audioTracks[index];
                return ListTile(
                  title: Text(track, style: TextStyle(color: Colors.white)),
                  leading: Radio<String>(
                    value: track,
                    groupValue: _selectedAudioTrack,
                    onChanged: (value) {
                      setState(() {
                        _selectedAudioTrack = value!;
                      });
                      Navigator.of(context).pop();
                      // Aquí iría la lógica real para cambiar la pista de audio
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Pista de audio cambiada a: $value')));
                    },
                    activeColor: Colors.blue,
                  ),
                  onTap: () {
                    setState(() {
                      _selectedAudioTrack = track;
                    });
                    Navigator.of(context).pop();
                    // Aquí iría la lógica real para cambiar la pista de audio
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Pista de audio cambiada a: $track')));
                  },
                );
              },
            ),
          ),
        );
      },
    ).then((_) => _startHideControlsTimer());
  }

  void _showSubtitlesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text('Subtítulos', style: TextStyle(color: Colors.white)),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _subtitleTracks.length,
              itemBuilder: (context, index) {
                final track = _subtitleTracks[index];
                return ListTile(
                  title: Text(track, style: TextStyle(color: Colors.white)),
                  leading: Radio<String>(
                    value: track,
                    groupValue: _selectedSubtitleTrack,
                    onChanged: (value) {
                      setState(() {
                        _selectedSubtitleTrack = value!;
                      });
                      Navigator.of(context).pop();
                      // Aquí iría la lógica real para cambiar los subtítulos
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Subtítulos cambiados a: $value')));
                    },
                    activeColor: Colors.blue,
                  ),
                  onTap: () {
                    setState(() {
                      _selectedSubtitleTrack = track;
                    });
                    Navigator.of(context).pop();
                    // Aquí iría la lógica real para cambiar los subtítulos
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Subtítulos cambiados a: $track')));
                  },
                );
              },
            ),
          ),
        );
      },
    ).then((_) => _startHideControlsTimer());
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PopupMenuButton<String>(
                        icon: Icon(Icons.settings, color: Colors.white),
                        onSelected: (String choice) {
                          // Manejar la selección del menú
                          if (choice == 'audio') {
                            _showAudioOptionsDialog(context);
                          } else if (choice == 'subtitles') {
                            _showSubtitlesDialog(context);
                          }
                        },
                        color: Colors.black87,
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem<String>(
                              value: 'audio',
                              child: Row(
                                children: [
                                  Icon(Icons.audiotrack, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Pistas de audio',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'subtitles',
                              child: Row(
                                children: [
                                  Icon(Icons.subtitles, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Subtítulos',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ];
                        },
                      ),
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
                          // Botón de episodio anterior
                          IconButton(
                            icon:
                                Icon(Icons.skip_previous, color: Colors.white),
                            onPressed: widget.onPreviousEpisode,
                            tooltip: "Episodio anterior",
                          ),
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
                            tooltip: "Retroceder 10 segundos",
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
                            tooltip: "Avanzar 10 segundos",
                          ),
                          // Botón de siguiente episodio
                          IconButton(
                            icon: Icon(Icons.skip_next, color: Colors.white),
                            onPressed: widget.onNextEpisode,
                            tooltip: "Siguiente episodio",
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
