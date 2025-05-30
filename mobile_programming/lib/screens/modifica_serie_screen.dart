import 'package:flutter/material.dart';
import '../models/serie.dart';
import '../db/db.dart';

class ModificaSerieScreen extends StatefulWidget {
  final Serie serie;
  const ModificaSerieScreen({super.key, required this.serie});

  @override
  State<ModificaSerieScreen> createState() => _ModificaSerieScreenState();
}

class _ModificaSerieScreenState extends State<ModificaSerieScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _plotController;
  late TextEditingController _seasonsController;
  late TextEditingController _episodesController;
  late TextEditingController _watchedController;

  String? _selectedGenre;
  String? _selectedPlatform;
  String? _selectedStatus;

  final List<String> _generi = [
    'Dramma', 'Azione', 'Commedia', 'Fantasy', 'Horror',
    'Thriller', 'Fantascienza', 'Romantico', 'Documentario',
  ];

  final List<String> _piattaforme = [
    'Netflix', 'Prime Video', 'Disney+', 'NowTV', 'Apple TV+', 'Altro',
  ];

  final List<String> _stati = ['non iniziata', 'in corso', 'completata'];

  @override
  void initState() {
    super.initState();
    final s = widget.serie;
    _titleController = TextEditingController(text: s.title);
    _plotController = TextEditingController(text: s.plot);
    _seasonsController = TextEditingController(text: s.seasons.toString());
    _episodesController = TextEditingController(text: s.episodes.toString());
    _watchedController = TextEditingController(text: s.episodesWatched.toString());
    _selectedGenre = s.genre;
    _selectedPlatform = s.platform;
    _selectedStatus = s.status;
  }

  void _salvaModifiche() async {
    if (_formKey.currentState!.validate()) {
      int episodes = int.parse(_episodesController.text);
      int episodiVisti = 0;

      if (_selectedStatus == 'completata') {
        episodiVisti = episodes;
      } else if (_selectedStatus == 'in corso') {
        episodiVisti = int.tryParse(_watchedController.text) ?? 0;
        if (episodiVisti > episodes) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gli episodi visti non possono superare il totale!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      if (_selectedStatus == 'non iniziata') {
        episodiVisti = 0;
      }

      final serieAggiornata = Serie(
        id: widget.serie.id,
        title: _titleController.text,
        plot: _plotController.text,
        genre: _selectedGenre!,
        platform: _selectedPlatform!,
        image: widget.serie.image,
        status: _selectedStatus!,
        seasons: int.parse(_seasonsController.text),
        episodes: episodes,
        episodesWatched: episodiVisti,
      );

      final db = await DatabaseHelper().database;
      await db.update('series', serieAggiornata.toMap(), where: 'id = ?', whereArgs: [widget.serie.id]);

      if (mounted) Navigator.pop(context);
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Campo obbligatorio' : null,
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: Colors.grey[900],
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null || value.isEmpty ? 'Campo obbligatorio' : null,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _plotController.dispose();
    _seasonsController.dispose();
    _episodesController.dispose();
    _watchedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Modifica Serie'), backgroundColor: Colors.red),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_titleController, 'Titolo'),
              _buildTextField(_plotController, 'Trama'),
              _buildDropdown('Genere', _selectedGenre, _generi, (val) => setState(() => _selectedGenre = val)),
              _buildDropdown('Piattaforma', _selectedPlatform, _piattaforme, (val) => setState(() => _selectedPlatform = val)),
              _buildDropdown('Stato', _selectedStatus, _stati, (val) => setState(() => _selectedStatus = val)),
              _buildTextField(_seasonsController, 'Stagioni', isNumber: true),
              _buildTextField(_episodesController, 'Episodi', isNumber: true),
              if (_selectedStatus == 'in corso')
                _buildTextField(_watchedController, 'Episodi visti', isNumber: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvaModifiche,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.black),
                child: const Text('Salva modifiche'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
