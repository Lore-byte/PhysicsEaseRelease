// lib/pages/quiz_page.dart
import 'package:flutter/material.dart';
import 'package:physics_ease_release/services/quiz_service.dart';
import 'package:physics_ease_release/pages/quiz_session_page.dart';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';

class QuizPage extends StatefulWidget {
  final void Function(bool) setGlobalAppBarVisibility;
  
  const QuizPage({super.key, required this.setGlobalAppBarVisibility});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final QuizService _quizService = QuizService();
  final Set<String> _selectedCategories = {};
  String _selectedDifficulty = 'tutte';
  int _numberOfQuestions = 10;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    await _quizService.loadAllQuizzes();
    setState(() {
      _isLoading = false;
    });
  }

  void _startQuiz() {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona almeno un argomento!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final difficulty = _selectedDifficulty == 'tutte' ? null : _selectedDifficulty;
    final quizzes = _quizService.getQuizzesByCategories(
      _selectedCategories.toList(),
      difficolta: difficulty,
      limit: _numberOfQuestions,
    );

    if (quizzes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nessun quiz disponibile per la selezione corrente!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizSessionPage(
          quizzes: quizzes,
          selectedCategories: _selectedCategories.toList(),
          setGlobalAppBarVisibility: widget.setGlobalAppBarVisibility,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).viewPadding.top + 70,
                ),
                child: const CircularProgressIndicator(),
              ),
            )
          else
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).viewPadding.top + 70,
                      left: 16.0,
                      right: 16.0,
                      bottom: MediaQuery.of(context).viewPadding.bottom + 98,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      Card(
                        color: colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(Icons.quiz, size: 48, color: colorScheme.primary),
                              const SizedBox(height: 8),
                              Text(
                                'Metti alla prova le tue conoscenze!',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Seleziona gli argomenti e inizia il quiz',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Selezione argomenti
                      Text(
                        'Argomenti',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: QuizService.availableCategories.map((category) {
                              final isSelected = _selectedCategories.contains(category);
                              final count = _quizService.getQuizCountByCategory(category);
                              return FilterChip(
                                label: Text(
                                  '${QuizService.categoryNames[category]} ($count)',
                                  style: TextStyle(
                                    color: isSelected
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurface,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedCategories.add(category);
                                    } else {
                                      _selectedCategories.remove(category);
                                    }
                                  });
                                },
                                selectedColor: colorScheme.primary,
                                checkmarkColor: colorScheme.onPrimary,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Difficoltà
                      Text(
                        'Difficoltà',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'tutte', label: Text('Tutte')),
                              ButtonSegment(value: 'facile', label: Text('Facile')),
                              ButtonSegment(value: 'medio', label: Text('Medio')),
                              ButtonSegment(value: 'difficile', label: Text('Difficile')),
                            ],
                            selected: {_selectedDifficulty},
                            onSelectionChanged: (Set<String> newSelection) {
                              setState(() {
                                _selectedDifficulty = newSelection.first;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Numero domande
                      Text(
                        'Numero di domande',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$_numberOfQuestions domande',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Slider(
                                value: _numberOfQuestions.toDouble(),
                                min: 5,
                                max: 50,
                                divisions: 9,
                                label: '$_numberOfQuestions',
                                onChanged: (value) {
                                  setState(() {
                                    _numberOfQuestions = value.round();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Pulsante Start
                      FilledButton.icon(
                        onPressed: _startQuiz,
                        icon: const Icon(Icons.play_arrow, size: 28),
                        label: const Text(
                          'Inizia Quiz',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).viewPadding.top,
            left: 16,
            right: 16,
            child: FloatingTopBar(
              title: 'Quiz di Fisica',
              leading: FloatingTopBarLeading.back,
              onBackPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }
}
