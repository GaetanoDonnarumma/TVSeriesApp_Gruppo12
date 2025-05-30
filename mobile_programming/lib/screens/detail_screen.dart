import 'package:flutter/material.dart';
import '../models/serie.dart';
import '../db/db.dart';
import 'modifica_serie_screen.dart';

class DetailScreen extends StatefulWidget {
  final Serie serie;

  const DetailScreen({super.key, required this.serie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  double _episodiVisti = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _episodiVisti = widget.serie.episodesWatched.toDouble();
    _isFavorite = widget.serie.isFavorite == 1;
  }

  void _salvaNelDatabase(int episodi) async {
    await DatabaseHelper().aggiornaEpisodiVisti(widget.serie.title, episodi, widget.serie.episodes);
  }


  void _togglePreferito() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    await DatabaseHelper().aggiornaPreferiti(widget.serie.title, _isFavorite ? 1 : 0);
  }

  void _eliminaSerie() async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Eliminare la serie?', style: TextStyle(color: Colors.white)),
        content: const Text('Sei sicuro di voler eliminare questa serie?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla', style: TextStyle(color: Colors.white70))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Elimina', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (conferma == true) {
      final db = await DatabaseHelper().database;
      await db.delete('series', where: 'title = ?', whereArgs: [widget.serie.title]);
      if (mounted) Navigator.pop(context);
    }
  }

  void _modificaSerie() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ModificaSerieScreen(serie: widget.serie)),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final serie = widget.serie;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(serie.title),
        backgroundColor: Colors.red,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _modificaSerie),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/immagini/${serie.image}',
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              serie.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),

            
            if (serie.dataProssimoEpisodio != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Nuova stagione disponibile il ${serie.dataProssimoEpisodio}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
            Text(serie.plot, style: const TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 20),
            Text('Genere: ${serie.genre}', style: const TextStyle(color: Colors.white)),
            Text('Piattaforma: ${serie.platform}', style: const TextStyle(color: Colors.white)),
            Text('Stato: ${serie.status}', style: const TextStyle(color: Colors.white)),
            Text('Stagioni: ${serie.seasons}', style: const TextStyle(color: Colors.white)),
            Text('Episodi totali: ${serie.episodes}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            const Divider(color: Colors.white30),
            const SizedBox(height: 20),
            Text('Episodi visti: ${_episodiVisti.toInt()} / ${serie.episodes}', style: const TextStyle(color: Colors.white)),
            Slider(
              value: _episodiVisti,
              min: 0,
              max: serie.episodes.toDouble(),
              divisions: serie.episodes,
              activeColor: Colors.red,
              label: _episodiVisti.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _episodiVisti = value;
                });
                _salvaNelDatabase(_episodiVisti.toInt());
              },
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (_episodiVisti < serie.episodes) {
                  setState(() {
                    _episodiVisti++;
                  });
                  _salvaNelDatabase(_episodiVisti.toInt());
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi 1 episodio visto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _togglePreferito,
              icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
              label: Text(_isFavorite ? 'Rimuovi dai preferiti' : 'Aggiungi ai preferiti'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[850],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _eliminaSerie,
              icon: const Icon(Icons.delete),
              label: const Text('Elimina serie'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
