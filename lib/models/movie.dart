class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String backdropPath;
  final String overview;
  final String releaseDate;
  final double voteAverage;
  final List<int> genreIds;
  final bool adult;
  final String originalTitle;
  final String originalLanguage;
  final double popularity;
  final int voteCount;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.backdropPath,
    required this.overview,
    required this.releaseDate,
    required this.voteAverage,
    this.genreIds = const [],
    this.adult = false,
    required this.originalTitle,
    required this.originalLanguage,
    required this.popularity,
    required this.voteCount,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      overview: json['overview'] ?? '',
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      adult: json['adult'] ?? false,
      originalTitle: json['original_title'] ?? '',
      originalLanguage: json['original_language'] ?? '',
      popularity: (json['popularity'] ?? 0.0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'overview': overview,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'genre_ids': genreIds,
      'adult': adult,
      'original_title': originalTitle,
      'original_language': originalLanguage,
      'popularity': popularity,
      'vote_count': voteCount,
    };
  }

  String get posterUrl {
    if (posterPath.isEmpty) {
      return 'https://via.placeholder.com/500x750/333333/FFFFFF?text=No+Image';
    }
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String get backdropUrl {
    if (backdropPath.isEmpty) {
      return 'https://via.placeholder.com/1280x720/333333/FFFFFF?text=No+Image';
    }
    return 'https://image.tmdb.org/t/p/w1280$backdropPath';
  }

  String get formattedRating {
    return voteAverage.toStringAsFixed(1);
  }

  String get formattedReleaseYear {
    if (releaseDate.isEmpty) return 'Unknown';
    return releaseDate.split('-')[0];
  }
}
