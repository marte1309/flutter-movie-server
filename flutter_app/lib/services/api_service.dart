// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie.dart';

class ApiService {
  final String baseUrl;

  ApiService({String? baseUrl})
      : baseUrl = baseUrl ??
            dotenv.env['API_URL'] ??
            'http://192.168.101.102:8084/api';

  Future<List<Movie>> getMovies() async {
    final response = await http.get(Uri.parse('$baseUrl/movies'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<Movie> getMovie(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/movies/$id'));

    if (response.statusCode == 200) {
      return Movie.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  Uri getStreamUrl(int movieId) {
    return Uri.parse('$baseUrl/stream/$movieId');
  }

  String getThumbnailUrl(int movieId) {
    return '$baseUrl/stream/thumbnail/$movieId';
  }

  Future<void> scanMovies() async {
    final response = await http.post(Uri.parse('$baseUrl/movies/scan'));

    if (response.statusCode != 200) {
      throw Exception('Failed to scan for movies');
    }
  }
}
