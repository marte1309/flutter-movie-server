// lib/screens/movie_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'player_screen.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final thumbnailUrl = apiService.getThumbnailUrl(movie.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: Center(
                          child: Icon(
                            Icons.movie,
                            size: 80,
                            color: Colors.white54,
                          ),
                        ),
                      );
                    },
                  ),
                  Center(
                    child: IconButton(
                      icon: Icon(
                        Icons.play_circle_fill,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.0),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayerScreen(movie: movie),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text(movie.format.toUpperCase()),
                        backgroundColor: Colors.blue,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Añadido: ${_formatDate(movie.addedAt)}',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.play_arrow),
                    label: Text('Reproducir'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayerScreen(movie: movie),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
