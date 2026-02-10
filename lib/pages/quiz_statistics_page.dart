// lib/pages/quiz_statistics_page.dart
import 'package:flutter/material.dart';
import 'package:physics_ease_release/models/quiz_result.dart';
import 'package:physics_ease_release/models/quiz.dart';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';
import 'package:physics_ease_release/services/quiz_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:physics_ease_release/services/quiz_service.dart'; // Aggiungi import
import 'dart:developer' as developer;
import 'package:fl_chart/fl_chart.dart';

class QuizStatisticsPage extends StatefulWidget {
  const QuizStatisticsPage({super.key});

  @override
  State<QuizStatisticsPage> createState() => _QuizStatisticsPageState();
}

class _QuizStatisticsPageState extends State<QuizStatisticsPage> {
  List<QuizSessionResult> _quizHistory = [];
  bool _isLoading = true;
  final QuizService _quizService = QuizService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _quizService.loadAllQuizzes();
    await _loadQuizHistory();
  }

  Future<void> _loadQuizHistory() async {
    setState(() => _isLoading = true);
    
    // Assicuriamoci che i quiz siano caricati per avere i nomi corretti delle categorie
    await QuizService().loadAllQuizzes();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedResults = prefs.getStringList('quiz_history') ?? [];

      final List<QuizSessionResult> history = [];
      for (String jsonString in savedResults) {
        try {
          history.add(QuizSessionResult.fromJson(jsonString));
        } catch (e) {
          developer.log('Error parsing quiz result: $e');
        }
      }

      history.sort(
        (a, b) => b.dataCompletamento.compareTo(a.dataCompletamento),
      );

      setState(() {
        _quizHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      developer.log('Error loading quiz history: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteQuiz(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: const Text('Vuoi eliminare questo quiz dallo storico?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedResults = prefs.getStringList('quiz_history') ?? [];

        final List<QuizSessionResult> allResults = [];
        for (String jsonString in savedResults) {
          try {
            allResults.add(QuizSessionResult.fromJson(jsonString));
          } catch (e) {
            developer.log('Error parsing quiz result: $e');
          }
        }

        allResults.sort(
          (a, b) => b.dataCompletamento.compareTo(a.dataCompletamento),
        );

        allResults.removeAt(index);

        final newSavedResults = allResults.map((r) => r.toJson()).toList();
        await prefs.setStringList('quiz_history', newSavedResults);

        await _loadQuizHistory();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quiz eliminato con successo'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        developer.log('Error deleting quiz: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Errore durante l\'eliminazione'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteAllQuizzes() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: const Text(
          'Vuoi eliminare TUTTI i quiz dallo storico? Questa azione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina Tutto'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('quiz_history');

        await _loadQuizHistory();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tutti i quiz sono stati eliminati'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        developer.log('Error deleting all quizzes: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Errore durante l\'eliminazione'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Map<String, dynamic> _calculateStatistics() {
    if (_quizHistory.isEmpty) {
      return {
        'totalQuizzes': 0,
        'totalQuestions': 0,
        'correctAnswers': 0,
        'averageScore': 0.0,
        'bestScore': 0.0,
        'worstScore': 0.0,
      };
    }

    final totalQuizzes = _quizHistory.length;
    final totalQuestions = _quizHistory.fold<int>(
      0,
      (sum, quiz) => sum + quiz.totale,
    );
    final correctAnswers = _quizHistory.fold<int>(
      0,
      (sum, quiz) => sum + quiz.punteggio,
    );

    final averageScore = (correctAnswers / totalQuestions) * 100;
    final bestScore = _quizHistory
        .map((q) => q.percentuale)
        .reduce((a, b) => a > b ? a : b);
    final worstScore = _quizHistory
        .map((q) => q.percentuale)
        .reduce((a, b) => a < b ? a : b);

    return {
      'totalQuizzes': totalQuizzes,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'averageScore': averageScore,
      'bestScore': bestScore,
      'worstScore': worstScore,
    };
  }

  // Aggregatore interno per categoria (per-domanda, non per-quiz)
  // (tenuto qui per evitare nuovi file)
  // ignore: unused_element
  static const String _uncategorizedLabel = 'Senza categoria';

  String _normalizeCategory(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return _uncategorizedLabel;
    // Normalizza spazi multipli
    return trimmed.replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Helper per rendere i nomi delle categorie "belli" (es: "kinematica" -> "Cinematica")
  String _prettifyCategory(String raw) {
    if (raw.isEmpty) return raw;
    final trimmed = raw.trim();
    
    // Cerca nella mappa del servizio (chiavi minuscole, es: 'kinematica')
    final lower = trimmed.toLowerCase();
    if (QuizService.categoryNames.containsKey(lower)) {
      return QuizService.categoryNames[lower]!;
    }

    // Fallback: se non è nella mappa, capitalizza la prima lettera
    if (trimmed.length > 1) {
      return trimmed[0].toUpperCase() + trimmed.substring(1);
    }
    return trimmed.toUpperCase();
  }

  /// Helper per stringhe che possono contenere più categorie separate (es: "kinematica, dinamica")
  String _prettifyCategoriesString(String categories) {
    if (categories.isEmpty) return categories;
    
    // Split basato su separatori comuni
    final parts = categories.split(RegExp(r'\s*(?:,|;|\+|•|\||/)\s*'));
    
    final prettyParts = parts
        .where((s) => s.trim().isNotEmpty)
        .map((s) => _prettifyCategory(s))
        .toSet() // Rimuove duplicati
        .toList();
        
    if (prettyParts.isEmpty) return categories;
    return prettyParts.join(', ');
  }

  /// Prova a ricavare la categoria dalla singola domanda.
  /// Supporta formati tipici: "Dinamica_12", "Dinamica:12", "[Dinamica] 12", "Dinamica-12", "Dinamica/12".
  String? _extractCategoryFromQuestionId(String quizId) {
    final id = quizId.trim();
    if (id.isEmpty) return null;

    // [Categoria]resto
    final bracket = RegExp(r'^\s*\[([^\]]+)\]\s*').firstMatch(id);
    if (bracket != null) {
      return _normalizeCategory(bracket.group(1) ?? '');
    }

    // Categoria:resto  | Categoria/resto | Categoria-resto | Categoria_resto
    final sep = RegExp(r'^\s*([^:_/\-]+?)\s*[:_/\-]\s*.+$').firstMatch(id);
    if (sep != null) {
      return _normalizeCategory(sep.group(1) ?? '');
    }

    // Categoria + spazio + numero (es "Dinamica 12")
    final spaceNum = RegExp(r'^\s*([^\d]+?)\s+\d+\s*$').firstMatch(id);
    if (spaceNum != null) {
      return _normalizeCategory(spaceNum.group(1) ?? '');
    }

    return null;
  }

  Map<String, Map<String, dynamic>> _calculateCategoryStatistics() {
    // Nuova logica: statistica per categoria basata sulle DOMANDE effettive.
    // Evita il problema: quiz "Dinamica + Termodinamica" da 10 domande -> non deve contare 10 su entrambe.
    final Map<String, int> totalQuestionsByCategory = {};
    final Map<String, int> correctByCategory = {};
    final Map<String, Set<DateTime>> sessionsByCategory =
        {}; // per conteggiare "quiz" che contengono quella categoria

    for (final quiz in _quizHistory) {
      // NOTA: qui non usiamo più quiz.categorie per splittare e duplicare i contatori.
      for (final risultato in quiz.risultati) {
        // Tenta di recuperare il nome ufficiale della categoria dal servizio (es. "Cinematica")
        String? category = QuizService().getCategoryNameByQuizId(risultato.quizId);
        
        // Se non trovato (es. quiz rimossi o vecchi), usa la logica di estrazione dall'ID come fallback
        if (category == null) {
           final rawCategory = _extractCategoryFromQuestionId(risultato.quizId);
           category = rawCategory ?? _uncategorizedLabel;
        }

        // Applica sempre prettify per uniformare i nomi (es: "kinematica" -> "Cinematica", "cinematica" -> "Cinematica")
        category = _prettifyCategory(category);

        totalQuestionsByCategory[category] =
            (totalQuestionsByCategory[category] ?? 0) + 1;
        if (risultato.isCorretta == true) {
          correctByCategory[category] = (correctByCategory[category] ?? 0) + 1;
        }

        (sessionsByCategory[category] ??= <DateTime>{}).add(
          quiz.dataCompletamento,
        );
      }
    }

    final Map<String, Map<String, dynamic>> categoryStats = {};
    for (final entry in totalQuestionsByCategory.entries) {
      final category = entry.key;
      final totalQuestions = entry.value;
      final correctAnswers = correctByCategory[category] ?? 0;
      final averageScore = totalQuestions == 0
          ? 0.0
          : (correctAnswers / totalQuestions) * 100;

      categoryStats[category] = {
        // "quizCount" = numero di sessioni che includono almeno una domanda di quella categoria
        'quizCount': (sessionsByCategory[category]?.length ?? 0),
        // "questionCount" = domande effettivamente svolte di quella categoria
        'questionCount': totalQuestions,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'averageScore': averageScore,
      };
    }

    // Opzionale: se non vuoi mostrare "Senza categoria", filtra qui.
    // categoryStats.remove(_uncategorizedLabel);

    return categoryStats;
  }

  String _formatCategoriesMultiline(String categories) {
    if (categories.isEmpty) return categories.trim();

    final parts = categories
        .split(RegExp(r'\s*(?:,|;|\+|•|\||/)\s*'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => _prettifyCategory(s))
        .toSet()
        .toList();

    if (parts.isEmpty) return categories.trim();
    return parts.join('\n');
  }

  List<Map<String, dynamic>> _calculateMostMissedQuestions({int limit = 10}) {
    final Map<String, int> missedCount = {};
    final Map<String, Quiz> quizMap = {};

    for (final category in QuizService.availableCategories) {
      final quizzes = _quizService.getQuizzesByCategory(category);
      for (final quiz in quizzes) {
        quizMap[quiz.id] = quiz;
      }
    }

    for (final session in _quizHistory) {
      for (final result in session.risultati) {
        if (!result.isCorretta) {
          missedCount[result.quizId] = (missedCount[result.quizId] ?? 0) + 1;
        }
      }
    }

    final List<Map<String, dynamic>> mostMissed = [];
    for (final entry in missedCount.entries) {
      final quiz = quizMap[entry.key];
      if (quiz != null) {
        mostMissed.add({'quiz': quiz, 'errors': entry.value});
      }
    }

    mostMissed.sort(
      (a, b) => (b['errors'] as int).compareTo(a['errors'] as int),
    );

    return mostMissed.take(limit).toList();
  }

  List<Widget> _buildCategoryCards(
    Map<String, Map<String, dynamic>> categoryStats,
    ColorScheme colorScheme,
  ) {
    final sortedCategories = categoryStats.entries.toList()
      ..sort(
        (a, b) => (b.value['averageScore'] as double).compareTo(
          a.value['averageScore'] as double,
        ),
      );

    return sortedCategories.map((entry) {
      // Applichiamo la formattazione corretta anche qui
      final category = _prettifyCategory(entry.key);
      final stats = entry.value;
      final averageScore = stats['averageScore'] as double;

      Color scoreColor;
      if (averageScore >= 80) {
        scoreColor = Colors.green;
      } else if (averageScore >= 60) {
        scoreColor = Colors.blue;
      } else if (averageScore >= 40) {
        scoreColor = Colors.orange;
      } else {
        scoreColor = Colors.red;
      }

      final totalQ = stats['totalQuestions'] as int;
      final correct = stats['correctAnswers'] as int;
      final wrong = totalQ - correct;
      final quizCount = stats['quizCount'] as int;

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.category, color: scoreColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$totalQ domande svolte • in $quizCount quiz',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: scoreColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${averageScore.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text('$correct', style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.cancel, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Text('$wrong', style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.quiz, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          '$totalQ domande',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildQuizHistoryCard(
    QuizSessionResult quiz,
    int index,
    ColorScheme colorScheme,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final percentuale = quiz.percentuale;

    // Converti la stringa categorie (che potrebbe essere "kinematica") in una forma leggibile ("Cinematica")
    final displayCategories = _prettifyCategoriesString(quiz.categorie);
    
    final correct = quiz.punteggio;
    final wrong = quiz.totale - quiz.punteggio;

    Color scoreColor;
    if (percentuale >= 90) {
      scoreColor = Colors.green;
    } else if (percentuale >= 70) {
      scoreColor = Colors.blue;
    } else if (percentuale >= 50) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showQuizDetails(quiz);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${quiz.punteggio}/${quiz.totale}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                          ),
                        ),
                        Text(
                          '${percentuale.toStringAsFixed(0)}%',
                          style: TextStyle(fontSize: 12, color: scoreColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayCategories, // Usa la stringa processata
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(quiz.dataCompletamento),
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text('$correct', style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 12),
                            Icon(Icons.cancel, size: 16, color: Colors.red),
                            const SizedBox(width: 4),
                            Text('$wrong', style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    onPressed: () => _deleteQuiz(index),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuizDetails(QuizSessionResult quiz) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
        final percentuale = quiz.percentuale;

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20.0),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Dettagli Quiz',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Card(
                  color: colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Categorie',
                          _formatCategoriesMultiline(quiz.categorie),
                          Icons.category,
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          'Data',
                          dateFormat.format(quiz.dataCompletamento),
                          Icons.calendar_today,
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          'Punteggio',
                          '${quiz.punteggio} / ${quiz.totale}',
                          Icons.score,
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          'Percentuale',
                          '${percentuale.toStringAsFixed(1)}%',
                          Icons.percent,
                        ),
                      ],
                    ),
                  ),
                ),
                //const SizedBox(height: 20),

                // Text(
                //   'Risposte (${quiz.risultati.length})',
                //   style: Theme.of(context).textTheme.titleMedium?.copyWith(
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // const SizedBox(height: 12),

                // Expanded(
                //   child: ListView.builder(
                //     controller: scrollController,
                //     itemCount: quiz.risultati.length,
                //     itemBuilder: (context, index) {
                //       final risultato = quiz.risultati[index];
                //       return Card(
                //         color: risultato.isCorretta
                //             ? Colors.green.withValues(alpha: 0.1)
                //             : Colors.red.withValues(alpha: 0.1),
                //         child: ListTile(
                //           leading: CircleAvatar(
                //             backgroundColor: risultato.isCorretta
                //                 ? Colors.green
                //                 : Colors.red,
                //             child: Icon(
                //               risultato.isCorretta
                //                   ? Icons.check
                //                   : Icons.close,
                //               color: Colors.white,
                //             ),
                //           ),
                //           title: Text('Domanda ${index + 1}'),
                //           subtitle: Text('Quiz ID: ${risultato.quizId}'),
                //         ),
                //       );
                //     },
                //   ),
                // ),
                //const SizedBox(height: 24),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            softWrap: true,
            maxLines: null,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _getProgressChartData() {
    if (_quizHistory.isEmpty) return [];

    // _quizHistory è ordinata: più recenti -> più vecchi
    // Vogliamo i 10 più recenti (take 10) ma in ordine cronologico nel grafico.
    final recentQuizzes = _quizHistory.take(10).toList().reversed.toList();

    return recentQuizzes.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.percentuale);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statistics = _calculateStatistics();
    final categoryStats = _calculateCategoryStatistics();

    return Scaffold(
      appBar: null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).viewPadding.top + 80,
                    left: 16.0,
                    right: 16.0,
                    bottom: MediaQuery.of(context).viewPadding.bottom + 94,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_quizHistory.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.quiz_outlined,
                                  size: 80,
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nessun quiz completato',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: colorScheme.onSurface.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Completa un quiz per vedere le statistiche qui!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        Card(
                          color: colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.analytics,
                                      color: colorScheme.onPrimaryContainer,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Statistiche Complessive',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildStatRow(
                                  'Quiz completati',
                                  '${statistics['totalQuizzes']}',
                                  Icons.quiz,
                                  colorScheme,
                                ),
                                const SizedBox(height: 12),
                                _buildStatRow(
                                  'Domande totali',
                                  '${statistics['totalQuestions']}',
                                  Icons.question_answer,
                                  colorScheme,
                                ),
                                const SizedBox(height: 12),
                                _buildStatRow(
                                  'Risposte corrette',
                                  '${statistics['correctAnswers']}',
                                  Icons.check_circle,
                                  colorScheme,
                                ),
                                const SizedBox(height: 12),
                                _buildStatRow(
                                  'Media punteggio',
                                  '${(statistics['averageScore'] as double).toStringAsFixed(1)}%',
                                  Icons.trending_up,
                                  colorScheme,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatRow(
                                        'Migliore',
                                        '${(statistics['bestScore'] as double).toStringAsFixed(1)}%',
                                        Icons.stars,
                                        colorScheme,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildStatRow(
                                        'Peggiore',
                                        '${(statistics['worstScore'] as double).toStringAsFixed(1)}%',
                                        Icons.show_chart,
                                        colorScheme,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_quizHistory.length > 1) ...[
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.show_chart,
                                        color: colorScheme.primary,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Andamento Ultimi Quiz',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 200,
                                    child: _buildProgressChart(colorScheme),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.pie_chart,
                                      color: colorScheme.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Distribuzione Risposte',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 200,
                                  child: _buildPieChart(
                                    statistics,
                                    colorScheme,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildMostMissedQuestionsCard(colorScheme),
                        if (categoryStats.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.category,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Statistiche per Categoria',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ..._buildCategoryCards(categoryStats, colorScheme),
                          const SizedBox(height: 24),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.history,
                                  color: colorScheme.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Storico Quiz',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever),
                              color: Colors.red,
                              onPressed: _deleteAllQuizzes,
                              tooltip: 'Elimina tutto lo storico',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._quizHistory.asMap().entries.map((entry) {
                          final index = entry.key;
                          final quiz = entry.value;
                          return _buildQuizHistoryCard(
                            quiz,
                            index,
                            colorScheme,
                          );
                        }),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).viewPadding.top + 10,
                  left: 16,
                  right: 16,
                  child: const FloatingTopBar(
                    title: 'Statistiche Quiz',
                    leading: FloatingTopBarLeading.back,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProgressChart(ColorScheme colorScheme) {
    final spots = _getProgressChartData();
    if (spots.isEmpty)
      return const Center(child: Text('Nessun dato disponibile'));

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) => FlLine(
            color: colorScheme.outline.withValues(alpha: 0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}%',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= spots.length) return const SizedBox();
                return Text(
                  '${value.toInt() + 1}',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 100,
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 4,
                    color: colorScheme.primary,
                    strokeWidth: 2,
                    strokeColor: colorScheme.surface,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(
    Map<String, dynamic> statistics,
    ColorScheme colorScheme,
  ) {
    final correctAnswers = statistics['correctAnswers'] as int;
    final totalQuestions = statistics['totalQuestions'] as int;
    final wrongAnswers = totalQuestions - correctAnswers;

    if (totalQuestions == 0)
      return const Center(child: Text('Nessun dato disponibile'));

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: [
                PieChartSectionData(
                  color: Colors.green,
                  value: correctAnswers.toDouble(),
                  title:
                      '${((correctAnswers / totalQuestions) * 100).toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.red,
                  value: wrongAnswers.toDouble(),
                  title:
                      '${((wrongAnswers / totalQuestions) * 100).toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24), // <-- più distanza tra grafico e legenda
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem('Errate', Colors.red, wrongAnswers),
              const SizedBox(height: 80),
              _buildLegendItem('Corrette', Colors.green, correctAnswers),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMostMissedQuestionsCard(ColorScheme colorScheme) {
    final mostMissedQuestions = _calculateMostMissedQuestions(limit: 10);

    if (mostMissedQuestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            childrenPadding: const EdgeInsets.only(bottom: 8.0),
            leading: Icon(
              Icons.warning_amber,
              color: Colors.orange,
              size: 24,
            ),
            title: Text(
              'Domande Più Sbagliate',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mostMissedQuestions.length,
                itemBuilder: (context, index) {
                  final data = mostMissedQuestions[index];
                  final quiz = data['quiz'] as Quiz;
                  final errors = data['errors'] as int;

                  return InkWell(
                    onTap: () {
                      _showMissedQuestionDetails(quiz, errors, colorScheme);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quiz.domanda,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  quiz.categoria,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '❌ $errors',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMissedQuestionDetails(
    Quiz quiz,
    int errors,
    ColorScheme colorScheme,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Dettagli Domanda',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: colorScheme.secondaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Domanda',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSecondaryContainer
                                  .withValues(alpha: 0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            quiz.domanda,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Categoria',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSecondaryContainer
                                            .withValues(alpha: 0.7),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      quiz.categoria,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Difficoltà',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSecondaryContainer
                                            .withValues(alpha: 0.7),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      quiz.difficolta,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Errori',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red.withValues(alpha: 0.7),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$errors',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Opzioni di Risposta',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: quiz.opzioni.length,
                      itemBuilder: (context, index) {
                        final isCorrect = index == quiz.rispostaCorretta;
                        return Card(
                          color: isCorrect
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  isCorrect ? Colors.green : Colors.grey,
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(quiz.opzioni[index]),
                            trailing: isCorrect
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
