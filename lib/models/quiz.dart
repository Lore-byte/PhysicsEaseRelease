// lib/models/quiz.dart
import 'dart:convert';

class Quiz {
  final String id;
  final String domanda;
  final String categoria;
  final String? sottocategoria;
  final List<String> opzioni;
  final int rispostaCorretta;
  final String spiegazione;
  final String difficolta;
  final List<String> paroleChiave;

  Quiz({
    required this.id,
    required this.domanda,
    required this.categoria,
    this.sottocategoria,
    required this.opzioni,
    required this.rispostaCorretta,
    required this.spiegazione,
    required this.difficolta,
    this.paroleChiave = const [],
  });

  // --- helpers (robust JSON parsing) ---
  static String _readString(
    Map<String, dynamic> map,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final k in keys) {
      final v = map[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return fallback;
  }

  static int _readInt(
    Map<String, dynamic> map,
    List<String> keys, {
    int fallback = 0,
  }) {
    for (final k in keys) {
      final v = map[k];
      if (v == null) continue;
      if (v is int) return v;
      final parsed = int.tryParse(v.toString());
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  static List<String> _readStringList(
    Map<String, dynamic> map,
    List<String> keys, {
    List<String> fallback = const [],
  }) {
    for (final k in keys) {
      final v = map[k];
      if (v == null) continue;
      if (v is List) return v.map((e) => e.toString()).toList();
    }
    return fallback;
  }

  factory Quiz.fromMap(Map<String, dynamic> map) {
    // NOTE: molti JSON usano "Categoria" (C maiuscola). Accetta entrambe.
    final id = _readString(map, const ['id']);
    final domanda = _readString(map, const ['domanda', 'Domanda']);
    final categoria = _readString(map, const [
      'categoria',
      'Categoria',
      'category',
      'Category',
    ]);
    final difficolta = _readString(map, const [
      'difficolta',
      'difficoltà',
      'Difficolta',
      'Difficoltà',
    ]);

    if (id.isEmpty || domanda.isEmpty || categoria.isEmpty) {
      throw FormatException(
        'Quiz JSON missing required fields (id/domanda/categoria): $map',
      );
    }

    final opzioni = _readStringList(map, const [
      'opzioni',
      'Opzioni',
      'options',
      'Options',
    ]);
    if (opzioni.isEmpty) {
      throw FormatException('Quiz JSON missing opzioni list: $map');
    }

    return Quiz(
      id: id,
      domanda: domanda,
      categoria: categoria,
      sottocategoria:
          _readString(map, const [
            'sottocategoria',
            'Sottocategoria',
          ], fallback: '').isEmpty
          ? null
          : _readString(map, const ['sottocategoria', 'Sottocategoria']),
      opzioni: opzioni,
      rispostaCorretta: _readInt(map, const [
        'rispostaCorretta',
        'RispostaCorretta',
        'correctAnswer',
        'correct_answer',
      ]),
      spiegazione: _readString(map, const ['spiegazione', 'Spiegazione']),
      difficolta: difficolta,
      paroleChiave: _readStringList(map, const [
        'paroleChiave',
        'ParoleChiave',
        'parole_chiave',
        'keywords',
        'Keywords',
      ]),
    );
  }

  factory Quiz.fromJson(String jsonString) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return Quiz.fromMap(jsonMap);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'domanda': domanda,
      'categoria': categoria,
      'sottocategoria': sottocategoria,
      'opzioni': opzioni,
      'rispostaCorretta': rispostaCorretta,
      'spiegazione': spiegazione,
      'difficolta': difficolta,
      'paroleChiave': paroleChiave,
    };
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}
