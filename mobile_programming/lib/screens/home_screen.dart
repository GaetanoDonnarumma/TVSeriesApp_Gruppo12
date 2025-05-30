import 'package:flutter/material.dart';
import '../db/db.dart';
import '../models/serie.dart';
import 'detail_screen.dart';
import 'aggiungi_serie_screen.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _paginaCorrente = 0;
  String _ricerca = '';
  String? _filtroStato;
  int? _filtroStagioni;

  List<Serie> inCorso = [];
  List<Serie> consigliati = [];
  List<Serie> topRivedere = [];
  List<Serie> preferiti = [];
  List<Serie> tutte = [];
  Serie? evidenza;

  @override
  void initState() {
    super.initState();
    _caricaSerie();
  }

  void _caricaSerie() async {
    final tutteSerie = await DatabaseHelper().getAllSeries();
    final random = Random();

    final inCorsoList = tutteSerie.where((s) => s.status == 'in corso').toList();
    final nonInCorso = tutteSerie.where((s) => s.status != 'in corso').toList();
    final consigliatiList = List<Serie>.from(nonInCorso)..shuffle();
    final suggeriti = consigliatiList.take(2).toList();
    final usati = [...inCorsoList, ...suggeriti];
    final rimanenti = tutteSerie.where((s) => !usati.contains(s)).toList();
    final serieEvidenza = tutteSerie..shuffle();

    final preferiteList = tutteSerie.where((s) => s.isFavorite == 1).toList();

    setState(() {
      inCorso = inCorsoList;
      consigliati = suggeriti;
      topRivedere = rimanenti;
      evidenza = serieEvidenza.first;
      preferiti = preferiteList;
      tutte = tutteSerie;
    });
  }

  void _vaiADettaglio(Serie serie) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(serie: serie)),
    );
    _caricaSerie();
  }

  Widget _grigliaCatalogo(String titolo, List<Serie> lista) {
    if (lista.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          '$titolo (${lista.length})',
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lista.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final serie = lista[index];
            return GestureDetector(
              onTap: () => _vaiADettaglio(serie),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.asset(
                        'assets/immagini/${serie.image}',
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(serie.title, style: const TextStyle(color: Colors.white)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(serie.platform, style: const TextStyle(color: Colors.white70)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _schermataCatalogo() {
    final categorieGenere = <String, List<Serie>>{};
    final categoriePiattaforma = <String, List<Serie>>{};

    for (var serie in tutte) {
      categorieGenere.putIfAbsent(serie.genre, () => []).add(serie);
      categoriePiattaforma.putIfAbsent(serie.platform, () => []).add(serie);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Catalogo per Genere', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ...categorieGenere.entries.map((e) => _grigliaCatalogo(e.key, e.value)),
          const SizedBox(height: 20),
          const Text('Catalogo per Piattaforma', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ...categoriePiattaforma.entries.map((e) => _grigliaCatalogo(e.key, e.value)),
        ],
      ),
    );
  }

  Widget _schermataRicerca() {
    final risultati = tutte.where((serie) {
      final matchTitolo = serie.title.toLowerCase().contains(_ricerca.toLowerCase());
      final matchGenere = serie.genre.toLowerCase().contains(_ricerca.toLowerCase());
      final matchPiattaforma = serie.platform.toLowerCase().contains(_ricerca.toLowerCase());
      final matchStato = _filtroStato == null || serie.status == _filtroStato;
      final matchStagioni = _filtroStagioni == null || serie.seasons == _filtroStagioni;
      return (matchTitolo || matchGenere || matchPiattaforma) && matchStato && matchStagioni;
    }).toList();

    return Column(
      children: [
        TextField(
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(hintText: 'Cerca serie...',hintStyle: TextStyle(color: Colors.grey), fillColor: Colors.white, filled: true),
          onChanged: (value) => setState(() => _ricerca = value),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Filtra per stato", style: TextStyle(color: Colors.grey)),
                  DropdownButton<String?>(
                    value: _filtroStato,
                    hint: const Text("Stato",style: TextStyle(color : Colors.white),),
                    dropdownColor: Colors.grey[900],
                    onChanged: (val) => setState(() => _filtroStato = val),
                    items: [null, 'non iniziata', 'in corso', 'completata'].map((s) => DropdownMenuItem(value: s, child: Text(s ?? 'Tutti', style: const TextStyle(color: Colors.grey)))).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Filtra per n° stagioni", style: TextStyle(color: Colors.grey)),
                  SizedBox(
                    width: 130,
                    child: DropdownButton<int?>(
                      value: _filtroStagioni,
                      dropdownColor: Colors.grey[900],
                      hint: const Text("Stagioni"),
                      onChanged: (val) => setState(() => _filtroStagioni = val),
                      items: [null, ...tutte.map((s) => s.seasons).toSet().toList()..sort()].map((s) => DropdownMenuItem(value: s, child: Text(s?.toString() ?? 'Tutte', style: const TextStyle(color: Colors.grey)),)).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: risultati.isEmpty
              ? const Center(child: Text('Nessuna serie trovata.', style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  itemCount: risultati.length,
                  itemBuilder: (context, index) {
                    final serie = risultati[index];
                    return ListTile(
                      title: Text(serie.title, style: const TextStyle(color: Colors.white)),
                      subtitle: Text('${serie.genre} • ${serie.platform}', style: const TextStyle(color: Colors.white70)),
                      onTap: () => _vaiADettaglio(serie),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSchermata() {
  switch (_paginaCorrente) {
    case 0:
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _evidenzaCard(),
            _sezione("Continua a guardare", inCorso),
            _sezione("Consigliati per te", consigliati),
            _sezione("Top da rivedere", topRivedere),
          ],
        ),
      );
    case 1:
      return _schermataCatalogo();
    case 2:
      return _schermataPreferiti();
    case 3:
      return _schermataRicerca();
    default:
      return const SizedBox.shrink();
    }
  }


  Widget _evidenzaCard() {
    if (evidenza == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => _vaiADettaglio(evidenza!),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage('assets/immagini/${evidenza!.image}'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.bottomLeft,
          child: Text(
            evidenza!.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sezione(String titolo, List<Serie> lista) {
    if (lista.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          titolo,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: titolo == "Consigliati per te" ? 230 : 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final serie = lista[index];
              return GestureDetector(
                onTap: () => _vaiADettaglio(serie),
                child: Container(
                  width: titolo == "Consigliati per te" ? 180 : 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.asset(
                          'assets/immagini/${serie.image}',
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(serie.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(serie.platform, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _schermataPreferiti() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'La tua lista dei preferiti',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: preferiti.isEmpty
              ? const Center(child: Text('Nessuna serie tra i preferiti.', style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  itemCount: preferiti.length,
                  itemBuilder: (context, index) {
                    final serie = preferiti[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Image.asset('assets/immagini/${serie.image}', width: 60, fit: BoxFit.cover),
                      title: Text(serie.title, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(serie.platform, style: const TextStyle(color: Colors.white70)),
                      onTap: () => _vaiADettaglio(serie),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('TV Series App'),
        centerTitle: true,
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AggiungiSerieScreen()),
            ).then((_) => _caricaSerie());
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildSchermata(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.white54,
        currentIndex: _paginaCorrente,
        onTap: (index) {
          setState(() {
            _paginaCorrente = index;
            _caricaSerie();
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Catalogo'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Preferiti'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cerca'),
        ],
      ),
    );
  }
}
