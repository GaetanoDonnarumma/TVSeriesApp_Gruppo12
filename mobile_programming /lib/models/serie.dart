class Serie {
  final int? id;
  final String title;
  final String plot;
  final String genre;
  final String platform;
  final String image;
  final String status;
  final int seasons;
  final int episodes;
  final int episodesWatched;
  final int isFavorite;
  final String? dataProssimoEpisodio; 

  Serie({
    this.id,
    required this.title,
    required this.plot,
    required this.genre,
    required this.platform,
    required this.image,
    required this.status,
    required this.seasons,
    required this.episodes,
    this.episodesWatched = 0,
    this.isFavorite = 0,
    this.dataProssimoEpisodio, 
  });

 
  factory Serie.fromMap(Map<String, dynamic> map) {
    return Serie(
      id: map['id'],
      title: map['title'],
      plot: map['plot'],
      genre: map['genre'],
      platform: map['platform'],
      image: map['image'],
      status: map['status'],
      seasons: map['seasons'],
      episodes: map['episodes'],
      episodesWatched: map['episodesWatched'] ?? 0,
      isFavorite: map['isFavorite'] ?? 0,
      dataProssimoEpisodio: map['dataProssimoEpisodio'],
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'plot': plot,
      'genre': genre,
      'platform': platform,
      'image': image,
      'status': status,
      'seasons': seasons,
      'episodes': episodes,
      'episodesWatched': episodesWatched,
      'isFavorite': isFavorite,
      'dataProssimoEpisodio': dataProssimoEpisodio, 
    };
  }
}
