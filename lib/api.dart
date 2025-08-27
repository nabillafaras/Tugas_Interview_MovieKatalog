import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class Api {
  static const String apiKey = '8e06155e9d2bbf6962ef612e17f3f54c';
  static const String baseUrl = 'https://api.themoviedb.org/3';

  static Future<List<Movie>> fetchMovies(String endpoint,
      {int page = 1}) async {
    if (apiKey.isEmpty) {
      throw Exception(
          'API Key tidak ditemukan. Silakan masukkan API Key TMDB yang valid.');
    }

    final url = '$baseUrl/$endpoint?api_key=$apiKey&language=en-US&page=$page';

    try {
      print('Fetching: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            'Failed to load movies: ${errorData['status_message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<List<Movie>> getNowPlayingMovies({int page = 1}) async {
    return await fetchMovies('movie/now_playing', page: page);
  }

  static Future<List<Movie>> getUpcomingMovies({int page = 1}) async {
    return await fetchMovies('movie/upcoming', page: page);
  }

  static Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    return await fetchMovies('movie/top_rated', page: page);
  }

  static Future<List<Movie>> getPopularMovies({int page = 1}) async {
    return await fetchMovies('movie/popular', page: page);
  }

  static Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.isEmpty) return [];

    final url =
        '$baseUrl/search/movie?api_key=$apiKey&language=en-US&page=$page&query=${Uri.encodeComponent(query)}';

    try {
      print('Searching: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            'Failed to search movies: ${errorData['status_message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Search error: ${e.toString()}');
    }
  }

  static Future<Movie> getMovieDetails(int movieId) async {
    final url = '$baseUrl/movie/$movieId?api_key=$apiKey&language=en-US';

    try {
      print('Fetching movie details: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Movie.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            'Failed to load movie details: ${errorData['status_message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
