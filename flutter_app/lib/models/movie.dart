// lib/models/movie.dart
class Movie {
  final int id;
  final String title;
  final String path;
  final String format;
  final DateTime addedAt;
  final int? duration;
  final int? year;
  final String? poster;

  Movie({
    required this.id,
    required this.title,
    required this.path,
    required this.format,
    required this.addedAt,
    this.duration = 0,
    this.year = 0,
    this.poster,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      path: json['path'],
      format: json['format'],
      addedAt: DateTime.parse(json['addedAt']),
      duration: json['duration'],
      year: json['year'],
      poster: json['poster'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'path': path,
      'format': format,
      'addedAt': addedAt.toIso8601String(),
      'duration': duration,
      'year': year,
      'poster': poster,
    };
  }
}
