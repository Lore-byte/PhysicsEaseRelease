// lib/pages/quiz_results_page.dart
import 'package:flutter/material.dart';
import 'package:physics_ease_release/models/quiz.dart';
import 'package:physics_ease_release/models/quiz_result.dart';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'package:physics_ease_release/pages/quiz_statistics_page.dart';

class QuizResultsPage extends StatefulWidget {
  final QuizSessionResult sessionResult;
  final List<Quiz> quizzes;
  final void Function(bool) setGlobalAppBarVisibility;

  const QuizResultsPage({
    super.key,
    required this.sessionResult,
    required this.quizzes,
    required this.setGlobalAppBarVisibility,
  });

  @override
  State<QuizResultsPage> createState() => _QuizResultsPageState();
}

class _QuizResultsPageState extends State<QuizResultsPage> {
  late Future<void> _saveFuture;

  @override
  void initState() {
    super.initState();
    _saveFuture = _saveQuizResult();
  }

  Future<void> _saveQuizResult() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedResults = prefs.getStringList('quiz_history') ?? [];

      savedResults.add(widget.sessionResult.toJson());

      await prefs.setStringList('quiz_history', savedResults);
      developer.log('Quiz result saved successfully');
    } catch (e) {
      developer.log('Error saving quiz result: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentuale = widget.sessionResult.percentuale;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).viewPadding.top + 80,
              left: 16.0,
              right: 16.0,
              bottom: MediaQuery.of(context).viewPadding.bottom + 220,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card punteggio principale
                Card(
                  color: _getScoreColor(percentuale),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(
                          _getScoreIcon(percentuale),
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getScoreMessage(percentuale),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.sessionResult.punteggio} / ${widget.sessionResult.totale}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${percentuale.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Statistiche
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${widget.sessionResult.punteggio}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Corrette',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(Icons.cancel, color: Colors.red, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                '${widget.sessionResult.totale - widget.sessionResult.punteggio}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Errate',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Dettagli risposte
                Text(
                  'Dettaglio Risposte',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                ...widget.sessionResult.risultati.asMap().entries.map((entry) {
                  final index = entry.key;
                  final result = entry.value;
                  final quiz = widget.quizzes[index];
                  final isCorrect = result.isCorretta;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isCorrect
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: isCorrect ? Colors.green : Colors.red,
                        child: Icon(
                          isCorrect ? Icons.check : Icons.close,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        'Domanda ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        quiz.domanda,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quiz.domanda,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...quiz.opzioni.asMap().entries.map((optEntry) {
                                final optIndex = optEntry.key;
                                final option = optEntry.value;
                                final isUserAnswer =
                                    optIndex == result.rispostaUtente;
                                final isCorrectAnswer =
                                    optIndex == quiz.rispostaCorretta;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isCorrectAnswer
                                            ? Icons.check_circle
                                            : (isUserAnswer
                                                  ? Icons.cancel
                                                  : Icons.circle_outlined),
                                        color: isCorrectAnswer
                                            ? Colors.green
                                            : (isUserAnswer
                                                  ? Colors.red
                                                  : Colors.grey),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            fontWeight:
                                                (isUserAnswer ||
                                                    isCorrectAnswer)
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }), //.toList(),
                              const Divider(height: 24),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.tertiaryContainer
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.lightbulb_outline,
                                          size: 20,
                                          color:
                                              colorScheme.onTertiaryContainer,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Spiegazione',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                colorScheme.onTertiaryContainer,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(quiz.spiegazione),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }), //.toList(),
              ],
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 10,
            left: 16,
            right: 16,
            child: FloatingTopBar(
              title: 'Risultati Quiz',
              leading: FloatingTopBarLeading.none,
            ),
          ),

          Positioned(
            bottom: MediaQuery.of(context).viewPadding.bottom + 30,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    // Wait for save to complete before popping to ensure QuizPage reloads new data
                    await _saveFuture;
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('Nuovo Quiz'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    minimumSize: const Size.fromHeight(56),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    await _saveFuture;
                    if (context.mounted) {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) => QuizStatisticsPage()),
                        );
                    }
                  },
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Le tue statistiche'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    minimumSize: const Size.fromHeight(56),
                  ),
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double percentuale) {
    if (percentuale >= 90) return Colors.green;
    if (percentuale >= 70) return Colors.blue;
    if (percentuale >= 50) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon(double percentuale) {
    if (percentuale >= 90) return Icons.emoji_events;
    if (percentuale >= 70) return Icons.thumb_up;
    if (percentuale >= 50) return Icons.sentiment_satisfied;
    return Icons.sentiment_dissatisfied;
  }

  String _getScoreMessage(double percentuale) {
    if (percentuale >= 90) return 'Eccellente!';
    if (percentuale >= 70) return 'Molto Bene!';
    if (percentuale >= 50) return 'Buon Lavoro!';
    return 'Continua a Studiare!';
  }
}
