// lib/models/movie.dart
class Movie {
  final int id;
  final String title;
  final String path;
  final String format;
  final DateTime addedAt;
  final int? duration;
  final int? year;

  Movie({
    required this.id,
    required this.title,
    required this.path,
    required this.format,
    required this.addedAt,
    this.duration = 0,
    this.year = 0,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      path: json['path'],
      format: json['format'],
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'path': path,
      'format': format,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}
