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

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] as String,
      domanda: map['domanda'] as String,
      categoria: map['categoria'] as String,
      sottocategoria: map['sottocategoria'] as String?,
      opzioni: (map['opzioni'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      rispostaCorretta: map['rispostaCorretta'] as int,
      spiegazione: map['spiegazione'] as String,
      difficolta: map['difficolta'] as String,
      paroleChiave: (map['paroleChiave'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          const [],
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
