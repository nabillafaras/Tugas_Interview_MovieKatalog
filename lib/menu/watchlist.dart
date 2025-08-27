import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/movie.dart';

class Watchlist extends StatefulWidget {
  const Watchlist({super.key});

  @override
  _WatchlistState createState() => _WatchlistState();
}

class _WatchlistState extends State<Watchlist>
    with AutomaticKeepAliveClientMixin {
  List<Movie> watchlistMovies = [];
  bool isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    loadWatchlist();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadWatchlist();
  }

  Future<void> loadWatchlist() async {
    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final watchlistJson = prefs.getStringList('watchlist') ?? [];


      print('Loading watchlist...');
      print('Raw data dari SharedPreferences: $watchlistJson');
      print('Jumlah item: ${watchlistJson.length}');

      List<Movie> movies = [];

      for (String json in watchlistJson) {
        try {
          final movieData = jsonDecode(json);
          final movie = Movie.fromJson(movieData);
          movies.add(movie);
          print('Berhasil parse movie: ${movie.title}');
        } catch (e) {
          print('Error parsing movie JSON: $json, Error: $e');

          continue;
        }
      }

      setState(() {
        watchlistMovies = movies;
        isLoading = false;
      });

      print('Total movies loaded: ${watchlistMovies.length}');
    } catch (e) {
      print('Error loading watchlist: $e');
      setState(() {
        isLoading = false;

      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading watchlist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> removeFromWatchlist(Movie movie) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final watchlistJson = prefs.getStringList('watchlist') ?? [];

      watchlistJson.removeWhere((json) {
        try {
          final movieData = jsonDecode(json);
          return movieData['id'] == movie.id;
        } catch (e) {
          print('Error parsing JSON for removal: $e');
          return false;
        }
      });

      await prefs.setStringList('watchlist', watchlistJson);

      setState(() {
        watchlistMovies.removeWhere((m) => m.id == movie.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${movie.title} removed from watchlist'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error removing from watchlist: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error removing movie from watchlist'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
        title: const Text(
          'My Watchlist',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: loadWatchlist,
            tooltip: 'Refresh',
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
                'Loading watchlist...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        )
            : watchlistMovies.isEmpty
            ? _buildEmptyState()
            : _buildWatchlist(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          const Text(
            'Your watchlist is empty',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add movies to your watchlist to watch them later',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {

              DefaultTabController.of(context)?.animateTo(0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Browse Movies',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlist() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Text(
            '${watchlistMovies.length} movie${watchlistMovies.length != 1 ? 's' : ''} in your watchlist',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: loadWatchlist,
            color: Colors.blue,
            backgroundColor: const Color(0xFF1A1D3A),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: watchlistMovies.length,
              itemBuilder: (context, index) {
                final movie = watchlistMovies[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D3A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/movie-detail',
                        arguments: movie.id,
                      ).then((_) {
                        loadWatchlist();
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              movie.posterUrl,
                              width: 60,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 90,
                                  color: Colors.grey[800],
                                  child: Icon(
                                    Icons.movie,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.yellow, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      movie.formattedRating,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),

                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  movie.formattedReleaseYear,
                                  style: TextStyle(
                                      color: Colors.grey[400], fontSize: 12),
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }


}