// lib/pages/quiz_session_page.dart
import 'package:flutter/material.dart';
import 'package:physics_ease_release/models/quiz.dart';
import 'package:physics_ease_release/models/quiz_result.dart';
import 'package:physics_ease_release/pages/quiz_results_page.dart';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';

class QuizSessionPage extends StatefulWidget {
  final List<Quiz> quizzes;
  final List<String> selectedCategories;
  final void Function(bool) setGlobalAppBarVisibility;

  const QuizSessionPage({
    super.key,
    required this.quizzes,
    required this.selectedCategories,
    required this.setGlobalAppBarVisibility,
  });

  @override
  State<QuizSessionPage> createState() => _QuizSessionPageState();
}

class _QuizSessionPageState extends State<QuizSessionPage> {
  int _currentQuizIndex = 0;
  int? _selectedAnswer;
  bool _showFeedback = false;
  final List<QuizResult> _results = [];

  Quiz get _currentQuiz => widget.quizzes[_currentQuizIndex];
  bool get _isLastQuestion => _currentQuizIndex == widget.quizzes.length - 1;

  void _selectAnswer(int index) {
    if (_showFeedback) return;

    setState(() {
      _selectedAnswer = index;
    });
  }

  void _confirmAnswer() {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona una risposta!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final isCorrect = _selectedAnswer == _currentQuiz.rispostaCorretta;

    setState(() {
      _showFeedback = true;
      _results.add(QuizResult(
        quizId: _currentQuiz.id,
        rispostaUtente: _selectedAnswer!,
        isCorretta: isCorrect,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _nextQuestion() {
    if (_isLastQuestion) {
      _finishQuiz();
    } else {
      setState(() {
        _currentQuizIndex++;
        _selectedAnswer = null;
        _showFeedback = false;
      });
    }
  }

  void _finishQuiz() {
    final correctAnswers = _results.where((r) => r.isCorretta).length;
    final sessionResult = QuizSessionResult(
      risultati: _results,
      dataCompletamento: DateTime.now(),
      punteggio: correctAnswers,
      totale: widget.quizzes.length,
      categorie: widget.selectedCategories.join(', '),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultsPage(
          sessionResult: sessionResult,
          quizzes: widget.quizzes,
          setGlobalAppBarVisibility: widget.setGlobalAppBarVisibility,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Uscire dal quiz?'),
            content: const Text('I tuoi progressi andranno persi.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annulla'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Esci'),
              ),
            ],
          ),
        );
        if (shouldPop == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).viewPadding.top + 70,
                left: 16.0,
                right: 16.0,
                bottom: MediaQuery.of(context).viewPadding.bottom + 140,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    Row(
                      children: [
                        Chip(
                          label: Text(_currentQuiz.categoria),
                          backgroundColor: colorScheme.secondaryContainer,
                          labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(_currentQuiz.difficolta.toUpperCase()),
                          backgroundColor: _getDifficultyColor(colorScheme),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Card(
                      color: colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          _currentQuiz.domanda,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ..._currentQuiz.opzioni.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final isSelected = _selectedAnswer == index;
                      final isCorrect = index == _currentQuiz.rispostaCorretta;

                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      Color? cardColor;
                      Color? borderColor;
                      Color? optionTextColor;

                      if (_showFeedback) {
                        if (isCorrect) {
                          cardColor = isDark ? Colors.green.shade800 : Colors.green.shade100;
                          borderColor = Colors.green;
                          optionTextColor = isDark ? Colors.white : colorScheme.onSurface;
                        } else if (isSelected) {
                          cardColor = isDark ? Colors.red.shade800 : Colors.red.shade100;
                          borderColor = Colors.red;
                          optionTextColor = isDark ? Colors.white : colorScheme.onSurface;
                        }
                      } else if (isSelected) {
                        cardColor = colorScheme.primaryContainer;
                        borderColor = colorScheme.primary;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: InkWell(
                          onTap: () => _selectAnswer(index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardColor ?? colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: borderColor ?? colorScheme.outline.withOpacity(0.3),
                                width: borderColor != null ? 2 : 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.surfaceVariant,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index), // A, B, C, D
                                      style: TextStyle(
                                        color: isSelected
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: optionTextColor,
                                        ),
                                  ),
                                ),
                                if (_showFeedback && isCorrect)
                                  const Icon(Icons.check_circle, color: Colors.green),
                                if (_showFeedback && isSelected && !isCorrect)
                                  const Icon(Icons.cancel, color: Colors.red),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                    if (_showFeedback) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: colorScheme.tertiaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: colorScheme.onTertiaryContainer),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Spiegazione',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onTertiaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _currentQuiz.spiegazione,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onTertiaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: _showFeedback
                          ? FilledButton.icon(
                              onPressed: _nextQuestion,
                              icon: Icon(_isLastQuestion ? Icons.check : Icons.arrow_forward),
                              label: Text(
                                _isLastQuestion ? 'Termina Quiz' : 'Prossima Domanda',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )
                          : FilledButton.icon(
                              onPressed: _confirmAnswer,
                              icon: const Icon(Icons.check),
                              label: const Text(
                                'Conferma Risposta',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                    ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).viewPadding.top,
            left: 16,
            right: 16,
            child: FloatingTopBar(
              title: 'Domanda ${_currentQuizIndex + 1}/${widget.quizzes.length}',
              leading: FloatingTopBarLeading.back,
              onBackPressed: () async {
                final shouldPop = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Uscire dal quiz?'),
                    content: const Text('I tuoi progressi andranno persi.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annulla'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Esci'),
                      ),
                    ],
                  ),
                );
                if (shouldPop == true && mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Color _getDifficultyColor(ColorScheme colorScheme) {
    switch (_currentQuiz.difficolta) {
      case 'facile':
        return Colors.green;
      case 'medio':
        return Colors.orange;
      case 'difficile':
        return Colors.red;
      default:
        return colorScheme.primary;
    }
  }
}
