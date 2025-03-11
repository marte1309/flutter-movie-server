// Modificación de lib/widgets/movie_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final thumbnailUrl = apiService.getThumbnailUrl(movie.id);

    return InkWell(
      borderRadius: BorderRadius.circular(15.0),
      onTap: onTap,
      focusColor: Theme.of(context)
          .focusColor
          .withValues(alpha: 0.3), // Color cuando está enfocado
      child: Card(
        elevation: 10,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: Center(
                      child: Icon(
                        Icons.movie,
                        size: 50,
                        color: Colors.white54,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
