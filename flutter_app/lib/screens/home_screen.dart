import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Movie>> _moviesFuture;
  
  @override
  void initState() {
    super.initState();
    _moviesFuture = _fetchMovies();
  }
  
  Future<List<Movie>> _fetchMovies() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    return apiService.getMovies();
  }
  
  Future<void> _refreshMovies() async {
    setState(() {
      _moviesFuture = _fetchMovies();
    });
  }
  
  Future<void> _scanForMovies() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      await apiService.scanMovies();
      await _refreshMovies();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('¡Biblioteca de películas actualizada!'))
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error al escanear películas: $e'))
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Colección de Películas'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshMovies,
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Implementar búsqueda
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Movie>>(
        future: _moviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _refreshMovies,
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No se encontraron películas'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _scanForMovies,
                    child: Text('Buscar películas'),
                  ),
                ],
              ),
            );
          }
          
          final movies = snapshot.data!;
          
          return GridView.builder(
            padding: EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return MovieCard(
                movie: movie,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailScreen(movie: movie),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanForMovies,
        tooltip: 'Escanear películas',
        child: Icon(Icons.sync),
      ),
    );
  }
}