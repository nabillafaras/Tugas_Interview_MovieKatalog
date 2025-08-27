import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/movie.dart';
import '../api.dart';

class MovieDetail extends StatefulWidget {
  final int movieId;

  const MovieDetail({super.key, required this.movieId});

  @override
  _MovieDetailState createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  Movie? movie;
  bool isLoading = true;
  bool isInWatchlist = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadMovieDetails();
    checkWatchlistStatus();
  }

  Future<void> loadMovieDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final movieDetails = await Api.getMovieDetails(widget.movieId);

      setState(() {
        movie = movieDetails;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> checkWatchlistStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final watchlistJson = prefs.getStringList('watchlist') ?? [];

      final isInList = watchlistJson.any((json) {
        final movieData = jsonDecode(json);
        return movieData['id'] == widget.movieId;
      });

      setState(() {
        isInWatchlist = isInList;
      });
    } catch (e) {
      print('Error checking watchlist status: $e');
    }
  }

  Future<void> toggleWatchlist() async {
    if (movie == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final watchlistJson = prefs.getStringList('watchlist') ?? [];

      if (isInWatchlist) {
        watchlistJson.removeWhere((json) {
          final movieData = jsonDecode(json);
          return movieData['id'] == movie!.id;
        });

        setState(() {
          isInWatchlist = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from watchlist'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        watchlistJson.add(jsonEncode(movie!.toJson()));

        setState(() {
          isInWatchlist = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to watchlist'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      await prefs.setStringList('watchlist', watchlistJson);
    } catch (e) {
      print('Error toggling watchlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update watchlist'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        title: const Text(
          'Movie Detail',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (movie != null)
            IconButton(
              onPressed: toggleWatchlist,
              icon: Icon(
                isInWatchlist ? Icons.favorite : Icons.favorite_border,
                color: isInWatchlist ? Colors.red : Colors.white,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              )
            : errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        const Text(
                          'Something went wrong',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: loadMovieDetails,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : movie != null
                    ? _buildMovieDetails()
                    : const Center(
                        child: Text(
                          'No movie data',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
      ),
    );
  }

  Widget _buildMovieDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  movie!.posterUrl,
                  width: 100,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 150,
                      color: Colors.grey[800],
                      child: const Icon(Icons.movie, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie!.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.yellow, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          movie!.formattedRating,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '/10',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie!.releaseDate.isNotEmpty
                          ? movie!.releaseDate
                          : 'Release date unknown',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie!.overview.isNotEmpty
                ? movie!.overview
                : 'No overview available.',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: toggleWatchlist,
              style: ElevatedButton.styleFrom(
                backgroundColor: isInWatchlist ? Colors.red : Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isInWatchlist ? 'Remove from Watchlist' : 'Add to Watchlist',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
