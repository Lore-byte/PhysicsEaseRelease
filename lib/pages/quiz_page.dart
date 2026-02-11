// lib/pages/quiz_page.dart
import 'package:flutter/material.dart';
import 'package:physics_ease_release/services/quiz_service.dart';
import 'package:physics_ease_release/pages/quiz_session_page.dart';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';
import 'package:physics_ease_release/pages/quiz_statistics_page.dart';
import 'package:physics_ease_release/models/quiz_result.dart';
import 'package:physics_ease_release/models/quiz.dart';
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
  int _missedQuestionsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadQuizzes();
    await _loadRecentHistory();
    await _updateMissedQuestionsCount();
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
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
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
      _updateMissedQuestionsCount();
    }
  }

  Future<void> _updateMissedQuestionsCount() async {
    final missedQuizzes = await _getMissedQuizzes();
    if (mounted) {
      setState(() {
        _missedQuestionsCount = missedQuizzes.length;
      });
    }
  }

  Future<List<Quiz>> _getMissedQuizzes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedResults = prefs.getStringList('quiz_history') ?? [];

    // Nuova logica:
    // - una domanda è "da rifare" SOLO se l'ULTIMO tentativo è stato sbagliato
    // - manteniamo anche il conteggio totale degli errori per ordinare per priorità
    final Map<String, int> wrongAttempts = {};
    final Map<String, bool> lastIsCorrect = {};
    final List<QuizSessionResult> sessions = [];

    for (final jsonString in savedResults) {
      try {
        sessions.add(QuizSessionResult.fromJson(jsonString));
      } catch (e) {
        // ignore
      }
    }

    // Ordina in senso cronologico (vecchio -> nuovo) così l'ultimo tentativo sovrascrive correttamente
    sessions.sort((a, b) => a.dataCompletamento.compareTo(b.dataCompletamento));

    for (final session in sessions) {
      for (final result in session.risultati) {
        final isCorrect = result.isCorretta == true;

        if (!isCorrect) {
          wrongAttempts[result.quizId] =
              (wrongAttempts[result.quizId] ?? 0) + 1;
        }

        // l'ultimo esito vince
        lastIsCorrect[result.quizId] = isCorrect;
      }
    }

    final pendingMissedIds = lastIsCorrect.entries
        .where((e) => e.value == false)
        .map((e) => e.key)
        .toSet();

    // Recupera i quiz effettivi (filtrati per categorie selezionate, o tutte se nessuna selezionata)
    final List<Quiz> missedQuizzes = [];
    final categoriesToCheck = _selectedCategories.isEmpty
        ? QuizService.availableCategories
        : _selectedCategories.toList();

    for (final category in categoriesToCheck) {
      final quizzes = _quizService.getQuizzesByCategory(category);
      for (final quiz in quizzes) {
        if (pendingMissedIds.contains(quiz.id)) {
          missedQuizzes.add(quiz);
        }
      }
    }

    // Ordina per numero totale di errori (più sbagliate -> meno sbagliate)
    missedQuizzes.sort(
      (a, b) => (wrongAttempts[b.id] ?? 0).compareTo(wrongAttempts[a.id] ?? 0),
    );

    return missedQuizzes;
  }

  void _startMissedQuestionsQuiz() async {
    final missedQuizzes = await _getMissedQuizzes();

    if (!mounted) {
      return;
    }

    if (missedQuizzes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedCategories.isEmpty
                ? 'Nessuna domanda sbagliata trovata!'
                : 'Nessuna domanda sbagliata per gli argomenti selezionati!',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Limita al numero di domande richiesto (o prendi tutte se sono meno)
    final quizzesToUse = missedQuizzes.take(_numberOfQuestions).toList();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizSessionPage(
          quizzes: quizzesToUse,
          selectedCategories: _selectedCategories.isEmpty
              ? QuizService.availableCategories
              : _selectedCategories.toList(),
          setGlobalAppBarVisibility: widget.setGlobalAppBarVisibility,
        ),
      ),
    );
    if (!mounted) {
      return;
    }

    await _loadRecentHistory();
    _updateMissedQuestionsCount();
  }

  void _showMissedQuestionsInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Come funziona'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Questa funzione ti permette di rifare tutte le domande che hai sbagliato in passato.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _buildTipItem(
                'Filtra per argomento',
                'Seleziona gli argomenti sopra per ripassare solo le domande sbagliate di quegli argomenti.',
              ),
              const SizedBox(height: 12),
              _buildTipItem(
                'Tutte le domande',
                'Non selezionare nessun argomento per rifare tutte le domande sbagliate.',
              ),
              const SizedBox(height: 12),
              _buildTipItem(
                'Priorità agli errori',
                'Le domande sono ordinate: prima quelle che sbagli più spesso!',
              ),
              const SizedBox(height: 12),
              _buildTipItem(
                'Numero di domande',
                'Usa lo slider sopra per decidere quante domande rifare.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ho capito!'),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
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
                                      _updateMissedQuestionsCount();
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
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _missedQuestionsCount > 0
                                    ? _startMissedQuestionsQuiz
                                    : null,
                                icon: const Icon(Icons.refresh, size: 24),
                                label: Text(
                                  _missedQuestionsCount > 0
                                      ? 'Rifai Domande Sbagliate ($_missedQuestionsCount)'
                                      : 'Nessuna Domanda Sbagliata',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(20),
                                  side: BorderSide(
                                    color: _missedQuestionsCount > 0
                                        ? colorScheme.error
                                        : colorScheme.onSurface.withValues(
                                            alpha: 0.12,
                                          ),
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  foregroundColor: _missedQuestionsCount > 0
                                      ? colorScheme.error
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _showMissedQuestionsInfo,
                              icon: Icon(
                                Icons.info_outline,
                                color: colorScheme.primary,
                                size: 28,
                              ),
                              tooltip: 'Come funziona',
                            ),
                          ],
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
                        dotData: FlDotData(
                          show: true,
                          checkToShowDot: (spot, barData) {
                            // Mostra i pallini solo per i punti "reali" (non per lo padding iniziale)
                            return spot.x >= padding.toDouble();
                          },
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 2.5,
                              color: colorScheme.primary,
                              strokeWidth: 1.5,
                              strokeColor: colorScheme.surface,
                            );
                          },
                        ),
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
