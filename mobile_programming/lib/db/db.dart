import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/serie.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tvseries.db');

    //await deleteDatabase(path); // nel momento in cui questa riga di codice viene decommentata, il database SQLite viene cancellato completamente

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE series (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        plot TEXT,
        genre TEXT,
        platform TEXT,
        image TEXT,
        status TEXT,
        seasons INTEGER,
        episodes INTEGER,
        episodesWatched INTEGER DEFAULT 0,
        isFavorite INTEGER DEFAULT 0,
        dataProssimoEpisodio TEXT
      )
    ''');

    await db.insert('series', {
      'title': 'Stranger Things',
      'plot': 'Un gruppo di ragazzi affronta eventi sovrannaturali in una piccola città.',
      'genre': 'Fantascienza',
      'platform': 'Netflix',
      'image': 'StrangerThings.jpg',
      'status': 'in corso',
      'seasons': 4,
      'episodes': 34,
      'episodesWatched': 12,
      'isFavorite': 1,
      'dataProssimoEpisodio': '2025-06-05'
    });

    await db.insert('series', {
      'title': 'Breaking Bad',
      'plot': 'Un professore di chimica diventa produttore di metanfetamina.',
      'genre': 'Dramma',
      'platform': 'Netflix',
      'image': 'breakingbad.jpg',
      'status': 'completata',
      'seasons': 5,
      'episodes': 62,
      'episodesWatched': 62,
      'isFavorite': 1,
      'dataProssimoEpisodio': null
    });

    await db.insert('series', {
      'title': 'The Crown',
      'plot': 'La storia della regina Elisabetta II e della famiglia reale britannica.',
      'genre': 'Dramma',
      'platform': 'Netflix',
      'image': 'TheCrown.jpg',
      'status': 'completata',
      'seasons': 6,
      'episodes': 60,
      'episodesWatched': 60,
      'isFavorite': 0,
      'dataProssimoEpisodio': null
    });

    await db.insert('series', {
      'title': 'The Mandalorian',
      'plot': 'Un cacciatore di taglie vaga nella galassia dopo la caduta dell\'Impero.',
      'genre': 'Fantascienza',
      'platform': 'Disney+',
      'image': 'theMandalorian.jpg',
      'status': 'in corso',
      'seasons': 3,
      'episodes': 24,
      'episodesWatched': 6,
      'isFavorite': 0,
      'dataProssimoEpisodio': '2025-07-20'
    });

    await db.insert('series', {
      'title': 'Peaky Blinders',
      'plot': 'Una gang criminale guida la città di Birmingham nel dopoguerra.',
      'genre': 'Dramma',
      'platform': 'Netflix',
      'image': 'PeakyBlinders.jpg',
      'status': 'completata',
      'seasons': 6,
      'episodes': 36,
      'episodesWatched': 36,
      'isFavorite': 1,
      'dataProssimoEpisodio': null
    });

    await db.insert('series', {
      'title': 'Friends',
      'plot': 'Sei amici a New York affrontano vita, amore e lavoro insieme.',
      'genre': 'Commedia',
      'platform': 'Netflix',
      'image': 'Friends.jpg',
      'status': 'completata',
      'seasons': 10,
      'episodes': 236,
      'episodesWatched': 236,
      'isFavorite': 1,
      'dataProssimoEpisodio': null
    });

    await db.insert('series', {
      'title': 'Dark',
      'plot': 'Un mistero temporale sconvolge una piccola città tedesca.',
      'genre': 'Thriller',
      'platform': 'Netflix',
      'image': 'Dark.jpg',
      'status': 'non iniziata',
      'seasons': 3,
      'episodes': 26,
      'episodesWatched': 0,
      'isFavorite': 1,
      'dataProssimoEpisodio': null
    });

    await db.insert('series', {
      'title': 'The Boys',
      'plot': 'Un gruppo segreto cerca di combattere supereroi corrotti.',
      'genre': 'Azione',
      'platform': 'Prime Video',
      'image': 'TheBoys.jpg',
      'status': 'in corso',
      'seasons': 4,
      'episodes': 32,
      'episodesWatched': 8,
      'isFavorite': 0,
      'dataProssimoEpisodio': '2025-08-25'
    });

    await db.insert('series', {
      'title': 'Jack Ryan',
      'plot': 'Un analista della CIA si ritrova coinvolto in pericolose operazioni sul campo.',
      'genre': 'Azione',
      'platform': 'Prime Video',
      'image': 'JackRyan.jpg',
      'status': 'non iniziata',
      'seasons': 4,
      'episodes': 32,
      'episodesWatched': 0,
      'isFavorite': 0,
      'dataProssimoEpisodio': ''
   });

    await db.insert('series', {
      'title': 'The Bear',
      'plot': 'Uno chef di alta cucina torna nella paninoteca di famiglia per affrontare il suo passato.',
      'genre': 'Dramma',
      'platform': 'Disney+',
      'image': 'TheBear.jpeg',
      'status': 'in corso',
      'seasons': 2,
      'episodes': 18,
      'episodesWatched': 10,
      'isFavorite': 1,
      'dataProssimoEpisodio': '2025-07-10'
    });

    await db.insert('series', {
      'title': 'The Office',
      'plot': 'Le assurde giornate degli impiegati di un ufficio raccontate in stile documentario.',
      'genre': 'Commedia',
      'platform': 'NOW TV',
      'image': 'TheOffice.jpg',
      'status': 'completata',
      'seasons': 9,
      'episodes': 201,
      'episodesWatched': 201,
      'isFavorite': 0,
      'dataProssimoEpisodio': ''
    });

    await db.insert('series', {
      'title': 'Sharp Objects',
      'plot': 'Una giornalista indaga su misteriosi omicidi nella sua città natale, svelando segreti oscuri.',
      'genre': 'Thriller',
      'platform': 'NOW TV',
      'image': 'SharpObjects.jpg',
      'status': 'completata',
      'seasons': 1,
      'episodes': 8,
      'episodesWatched': 8,
      'isFavorite': 0,
      'dataProssimoEpisodio': ''
    });
  }
  

  Future<List<Serie>> getAllSeries() async {
    final db = await database;
    final result = await db.query('series');
    return result.map((map) => Serie.fromMap(map)).toList();
  }

  Future<void> aggiornaEpisodiVisti(String titolo, int episodiVisti, int episodiTotali) async {
    final db = await database;
    String nuovoStato;
    if (episodiVisti == 0) {
      nuovoStato = 'non iniziata';
    } else if (episodiVisti < episodiTotali) {
      nuovoStato = 'in corso';
    } else {
      nuovoStato = 'completata';
    }
    await db.update(
      'series',
      {
        'episodesWatched': episodiVisti,
        'status': nuovoStato,
      },
      where: 'title = ?',
      whereArgs: [titolo],
    );
  }


  Future<void> aggiornaPreferiti(String titolo, int isFavorite) async {
    final db = await database;
    await db.update(
      'series',
      {'isFavorite': isFavorite},
      where: 'title = ?',
      whereArgs: [titolo],
    );
  }

  Future<List<Serie>> getPreferiti() async {
    final db = await database;
    final result = await db.query(
      'series',
      where: 'isFavorite = ?',
      whereArgs: [1],
    );
    return result.map((map) => Serie.fromMap(map)).toList();
  }
}
