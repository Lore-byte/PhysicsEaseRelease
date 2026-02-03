// lib/models/quiz_result.dart
import 'dart:convert';

class QuizResult {
  final String quizId;
  final int rispostaUtente;
  final bool isCorretta;
  final DateTime timestamp;

  QuizResult({
    required this.quizId,
    required this.rispostaUtente,
    required this.isCorretta,
    required this.timestamp,
  });

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      quizId: map['quizId'] as String,
      rispostaUtente: map['rispostaUtente'] as int,
      isCorretta: map['isCorretta'] as bool,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'rispostaUtente': rispostaUtente,
      'isCorretta': isCorretta,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  factory QuizResult.fromJson(String jsonString) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return QuizResult.fromMap(jsonMap);
  }
}

class QuizSessionResult {
  final List<QuizResult> risultati;
  final DateTime dataCompletamento;
  final int punteggio;
  final int totale;
  final String categorie;

  QuizSessionResult({
    required this.risultati,
    required this.dataCompletamento,
    required this.punteggio,
    required this.totale,
    required this.categorie,
  });

  double get percentuale => (punteggio / totale) * 100;

  factory QuizSessionResult.fromMap(Map<String, dynamic> map) {
    return QuizSessionResult(
      risultati: (map['risultati'] as List<dynamic>)
          .map((e) => QuizResult.fromMap(e as Map<String, dynamic>))
          .toList(),
      dataCompletamento: DateTime.parse(map['dataCompletamento'] as String),
      punteggio: map['punteggio'] as int,
      totale: map['totale'] as int,
      categorie: map['categorie'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'risultati': risultati.map((e) => e.toMap()).toList(),
      'dataCompletamento': dataCompletamento.toIso8601String(),
      'punteggio': punteggio,
      'totale': totale,
      'categorie': categorie,
    };
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  factory QuizSessionResult.fromJson(String jsonString) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return QuizSessionResult.fromMap(jsonMap);
  }
}
