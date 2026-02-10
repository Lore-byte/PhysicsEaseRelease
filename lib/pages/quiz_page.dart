// lib/pages/quiz_page.dart
import 'package:flutter/material.dart';
import 'package:physics_ease_release/services/quiz_service.dart';
import 'package:physics_ease_release/pages/quiz_session_page.dart';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';
import 'package:physics_ease_release/pages/quiz_statistics_page.dart';
import 'package:physics_ease_release/models/quiz_result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

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
  List<QuizSessionResult> _recentHistory = [];

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
    _loadRecentHistory();
  }

  Future<void> _loadRecentHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedResults = prefs.getStringList('quiz_history') ?? [];
    List<QuizSessionResult> history = [];
    for (String jsonString in savedResults) {
      try {
        history.add(QuizSessionResult.fromJson(jsonString));
      } catch (e) {
        // ignore
      }
    }
    // Ordina dal più recente al meno recente
    history.sort((a, b) => b.dataCompletamento.compareTo(a.dataCompletamento));

    if (mounted) {
      setState(() {
        // Prendi gli ultimi 5 e invertili per il grafico (cronologico sx->dx)
        _recentHistory = history.take(5).toList().reversed.toList();
      });
    }
  }

  Future<void> _loadQuizzes() async {
    await _quizService.loadAllQuizzes();
    setState(() {
      _isLoading = false;
    });
  }

  void _startQuiz() async {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona almeno un argomento!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final difficulty = _selectedDifficulty == 'tutte'
        ? null
        : _selectedDifficulty;
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

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizSessionPage(
          quizzes: quizzes,
          selectedCategories: _selectedCategories.toList(),
          setGlobalAppBarVisibility: widget.setGlobalAppBarVisibility,
        ),
      ),
    );
    if (mounted) {
      await _loadRecentHistory();
    }
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
                                Icon(
                                  Icons.quiz,
                                  size: 48,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Metti alla prova le tue conoscenze!',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Seleziona gli argomenti e inizia il quiz',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: colorScheme.onPrimaryContainer
                                            .withValues(alpha: 0.7),
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Selezione argomenti
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Argomenti',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  if (_selectedCategories.length ==
                                      QuizService.availableCategories.length) {
                                    _selectedCategories.clear();
                                  } else {
                                    _selectedCategories.clear();
                                    _selectedCategories.addAll(
                                      QuizService.availableCategories,
                                    );
                                  }
                                });
                              },
                              icon: Icon(
                                _selectedCategories.length ==
                                        QuizService.availableCategories.length
                                    ? Icons.clear_all
                                    : Icons.select_all,
                                size: 20,
                              ),
                              label: Text(
                                _selectedCategories.length ==
                                        QuizService.availableCategories.length
                                    ? 'Deseleziona tutto'
                                    : 'Seleziona tutto',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: QuizService.availableCategories.map((
                                category,
                              ) {
                                final isSelected = _selectedCategories.contains(
                                  category,
                                );
                                final count = _quizService
                                    .getQuizCountByCategory(category);
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
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'tutte',
                                  label: Text('Tutte'),
                                ),
                                ButtonSegment(
                                  value: 'facile',
                                  label: Text('Facile'),
                                ),
                                ButtonSegment(
                                  value: 'medio',
                                  label: Text('Medio'),
                                ),
                                ButtonSegment(
                                  value: 'difficile',
                                  label: Text('Difficile'),
                                ),
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
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '$_numberOfQuestions domande',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.all(20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                        _buildStatsButton(context, colorScheme),
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

  Widget _buildStatsButton(BuildContext context, ColorScheme colorScheme) {
    List<FlSpot> spots = [];
    const int pointsToShow = 5;

    // Riempi con zeri se abbiamo meno di 5 quiz, per avere sempre il grafico completo
    int padding = pointsToShow - _recentHistory.length;
    for (int i = 0; i < padding; i++) {
      spots.add(FlSpot(i.toDouble(), 0));
    }
    for (int i = 0; i < _recentHistory.length; i++) {
      spots.add(
        FlSpot((padding + i).toDouble(), _recentHistory[i].percentuale),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => QuizStatisticsPage()));
          _loadRecentHistory();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Le tue Statistiche',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                width: 80,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minY: -10,
                    maxY: 110,
                    lineTouchData: const LineTouchData(enabled: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: colorScheme.primary,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
