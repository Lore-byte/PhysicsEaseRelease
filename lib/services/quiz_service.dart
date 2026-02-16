// lib/services/quiz_service.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:physics_ease_release/models/quiz.dart';
import 'dart:developer' as developer;

class QuizService {
  static final QuizService _instance = QuizService._internal();
  factory QuizService() => _instance;
  QuizService._internal();

  final Map<String, List<Quiz>> _quizzesByCategory = {};
  final Map<String, String> _quizIdToCategoryMap =
      {}; // Nuova mappa per ID -> Categoria Reale
  bool _isLoaded = false;

  // Categorie disponibili
  static const List<String> availableCategories = [
    'kinematica',
    'circuiti',
    'dinamica',
    'elettromagnetismo',
    'elettrostatica',
    'fisicanucleare',
    'fisicaquantistica',
    'fluidi',
    'gravitazione',
    'lavoro',
    'magnetismo',
    'momentoangolare',
    'ottica',
    'qmoto',
    'relativita',
    'termodinamica',
  ];

  static const Map<String, String> categoryNames = {
    'kinematica': 'Cinematica',
    'circuiti': 'Circuiti',
    'dinamica': 'Dinamica',
    'elettromagnetismo': 'Elettromagnetismo',
    'elettrostatica': 'Elettrostatica',
    'fisicanucleare': 'Fisica Nucleare',
    'fisicaquantistica': 'Fisica Quantistica',
    'fluidi': 'Fluidi',
    'gravitazione': 'Gravitazione',
    'lavoro': 'Lavoro ed Energia',
    'magnetismo': 'Magnetismo',
    'momentoangolare': 'Momento Angolare',
    'ottica': 'Ottica',
    'qmoto': 'Quantità di Moto',
    'relativita': 'Relatività',
    'termodinamica': 'Termodinamica',
  };

  Future<void> loadAllQuizzes() async {
    if (_isLoaded) return;

    developer.log('Loading quizzes from assets...');
    for (final category in availableCategories) {
      try {
        final String jsonString = await rootBundle.loadString(
          'assets/quiz/$category.json',
        );
        final Map<String, dynamic> jsonData = jsonDecode(jsonString);
        final List<dynamic> quizList = jsonData['quiz'] as List<dynamic>;

        _quizzesByCategory[category] = quizList.map((quizMap) {
          final quiz = Quiz.fromMap(quizMap as Map<String, dynamic>);
          // Mappiamo l'ID del quiz (es: "kin_001") al nome reale della categoria (es: "Cinematica")
          _quizIdToCategoryMap[quiz.id] = quiz.categoria;
          return quiz;
        }).toList();

        developer.log(
          'Loaded ${_quizzesByCategory[category]!.length} quizzes for $category',
        );
      } catch (e, st) {
        developer.log('Error loading quiz for $category: $e', stackTrace: st);
        _quizzesByCategory[category] = [];
      }
    }

    _isLoaded = true;
    developer.log('All quizzes loaded successfully');
  }

  // Aggiungi questo metodo per recuperare il nome corretto
  String? getCategoryNameByQuizId(String quizId) {
    return _quizIdToCategoryMap[quizId];
  }

  List<Quiz> getQuizzesByCategory(String category) {
    return _quizzesByCategory[category] ?? [];
  }

  List<Quiz> getQuizzesByCategories(
    List<String> categories, {
    String? difficolta,
    int? limit,
  }) {
    List<Quiz> allQuizzes = [];

    for (final category in categories) {
      final categoryQuizzes = _quizzesByCategory[category] ?? [];
      allQuizzes.addAll(categoryQuizzes);
    }

    // Filtra per difficoltà se specificata
    if (difficolta != null && difficolta.isNotEmpty) {
      allQuizzes = allQuizzes
          .where((quiz) => quiz.difficolta == difficolta)
          .toList();
    }

    // Mescola i quiz
    allQuizzes.shuffle();

    // Limita il numero se specificato
    if (limit != null && limit < allQuizzes.length) {
      allQuizzes = allQuizzes.sublist(0, limit);
    }

    return allQuizzes;
  }

  int getTotalQuizCount() {
    return _quizzesByCategory.values.fold(0, (sum, list) => sum + list.length);
  }

  int getQuizCountByCategory(String category) {
    return _quizzesByCategory[category]?.length ?? 0;
  }

  bool get isLoaded => _isLoaded;
}
