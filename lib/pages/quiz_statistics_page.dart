// lib/pages/quiz_statistics_page.dart
import 'package:flutter/material.dart';
import 'package:physics_ease_release/models/quiz_result.dart';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'package:fl_chart/fl_chart.dart';

class QuizStatisticsPage extends StatefulWidget {
  final ThemeMode themeMode;

  const QuizStatisticsPage({
    super.key,
    required this.themeMode,
  });

  @override
  State<QuizStatisticsPage> createState() => _QuizStatisticsPageState();
}

class _QuizStatisticsPageState extends State<QuizStatisticsPage> {
  List<QuizSessionResult> _quizHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizHistory();
  }

  Future<void> _loadQuizHistory() async {
    setState(() => _isLoading = true);
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
      
      history.sort((a, b) => b.dataCompletamento.compareTo(a.dataCompletamento));
      
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
        
        allResults.sort((a, b) => b.dataCompletamento.compareTo(a.dataCompletamento));
        
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
        content: const Text('Vuoi eliminare TUTTI i quiz dallo storico? Questa azione non può essere annullata.'),
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
    final totalQuestions = _quizHistory.fold<int>(0, (sum, quiz) => sum + quiz.totale);
    final correctAnswers = _quizHistory.fold<int>(0, (sum, quiz) => sum + quiz.punteggio);
    
    final averageScore = (correctAnswers / totalQuestions) * 100;
    final bestScore = _quizHistory.map((q) => q.percentuale).reduce((a, b) => a > b ? a : b);
    final worstScore = _quizHistory.map((q) => q.percentuale).reduce((a, b) => a < b ? a : b);

    return {
      'totalQuizzes': totalQuizzes,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'averageScore': averageScore,
      'bestScore': bestScore,
      'worstScore': worstScore,
    };
  }

  Map<String, Map<String, dynamic>> _calculateCategoryStatistics() {
    final Map<String, List<QuizSessionResult>> quizzesByCategory = {};
    
    for (var quiz in _quizHistory) {
      // Separa le categorie (potrebbero essere multiple separate da virgola)
      final categories = quiz.categorie.split(',').map((c) => c.trim()).toList();
      for (var category in categories) {
        if (!quizzesByCategory.containsKey(category)) {
          quizzesByCategory[category] = [];
        }
        quizzesByCategory[category]!.add(quiz);
      }
    }

    final Map<String, Map<String, dynamic>> categoryStats = {};
    
    quizzesByCategory.forEach((category, quizzes) {
      final totalQuizzes = quizzes.length;
      final totalQuestions = quizzes.fold<int>(0, (sum, quiz) => sum + quiz.totale);
      final correctAnswers = quizzes.fold<int>(0, (sum, quiz) => sum + quiz.punteggio);
      final averageScore = (correctAnswers / totalQuestions) * 100;
      
      categoryStats[category] = {
        'count': totalQuizzes,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'averageScore': averageScore,
      };
    });

    return categoryStats;
  }

  List<FlSpot> _getProgressChartData() {
    if (_quizHistory.isEmpty) return [];
    
    final recentQuizzes = _quizHistory.reversed.take(10).toList();
    
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).viewPadding.top + 80,
                    left: 16.0,
                    right: 16.0,
                    bottom: MediaQuery.of(context).viewPadding.bottom + 20,
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
                                  color: colorScheme.primary.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nessun quiz completato',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Completa un quiz per vedere le statistiche qui!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: colorScheme.onSurface.withValues(alpha: 0.4),
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
                                  '${statistics['averageScore'].toStringAsFixed(1)}%',
                                  Icons.trending_up,
                                  colorScheme,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatRow(
                                        'Migliore',
                                        '${statistics['bestScore'].toStringAsFixed(1)}%',
                                        Icons.stars,
                                        colorScheme,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildStatRow(
                                        'Peggiore',
                                        '${statistics['worstScore'].toStringAsFixed(1)}%',
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
                                  child: _buildPieChart(statistics, colorScheme),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

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
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
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
                            Text(
                              'Storico Quiz',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
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
                          return _buildQuizHistoryCard(quiz, index, colorScheme);
                        }),
                      ],
                    ],
                  ),
                ),
                
                Positioned(
                  top: MediaQuery.of(context).viewPadding.top + 10,
                  left: 16,
                  right: 16,
                  child: FloatingTopBar(
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
    if (spots.isEmpty) return const Center(child: Text('Nessun dato disponibile'));

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: colorScheme.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                );
              },
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
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: colorScheme.primary,
                  strokeWidth: 2,
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
    );
  }

  Widget _buildPieChart(Map<String, dynamic> statistics, ColorScheme colorScheme) {
    final correctAnswers = statistics['correctAnswers'] as int;
    final totalQuestions = statistics['totalQuestions'] as int;
    final wrongAnswers = totalQuestions - correctAnswers;

    if (totalQuestions == 0) {
      return const Center(child: Text('Nessun dato disponibile'));
    }

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
                  title: '${((correctAnswers / totalQuestions) * 100).toStringAsFixed(1)}%',
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
                  title: '${((wrongAnswers / totalQuestions) * 100).toStringAsFixed(1)}%',
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
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem('Corrette', Colors.green, correctAnswers),
              const SizedBox(height: 8),
              _buildLegendItem('Errate', Colors.red, wrongAnswers),
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
              Text(
                label,
                style: const TextStyle(fontSize: 12),
              ),
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

  List<Widget> _buildCategoryCards(
    Map<String, Map<String, dynamic>> categoryStats,
    ColorScheme colorScheme,
  ) {
    final sortedCategories = categoryStats.entries.toList()
      ..sort((a, b) => (b.value['averageScore'] as double)
          .compareTo(a.value['averageScore'] as double));

    return sortedCategories.map((entry) {
      final category = entry.key;
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
                    child: Icon(
                      Icons.category,
                      color: scoreColor,
                      size: 24,
                    ),
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
                          '${stats['count']} quiz completati',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${stats['correctAnswers']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${stats['totalQuestions'] - stats['correctAnswers']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.quiz,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${stats['totalQuestions']} domande',
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
        Icon(icon, size: 20, color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7)),
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
                          style: TextStyle(
                            fontSize: 12,
                            color: scoreColor,
                          ),
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
                          quiz.categorie,
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
                            Text(
                              '${quiz.punteggio}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.cancel,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${quiz.totale - quiz.punteggio}',
                              style: const TextStyle(fontSize: 12),
                            ),
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
                    'Dettagli Quiz',
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
                        children: [
                          _buildDetailRow('Categorie', quiz.categorie, Icons.category),
                          const Divider(height: 24),
                          _buildDetailRow('Data', dateFormat.format(quiz.dataCompletamento), Icons.calendar_today),
                          const Divider(height: 24),
                          _buildDetailRow('Punteggio', '${quiz.punteggio} / ${quiz.totale}', Icons.score),
                          const Divider(height: 24),
                          _buildDetailRow('Percentuale', '${percentuale.toStringAsFixed(1)}%', Icons.percent),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    'Risposte (${quiz.risultati.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: quiz.risultati.length,
                      itemBuilder: (context, index) {
                        final risultato = quiz.risultati[index];
                        return Card(
                          color: risultato.isCorretta
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: risultato.isCorretta ? Colors.green : Colors.red,
                              child: Icon(
                                risultato.isCorretta ? Icons.check : Icons.close,
                                color: Colors.white,
                              ),
                            ),
                            title: Text('Domanda ${index + 1}'),
                            subtitle: Text('Quiz ID: ${risultato.quizId}'),
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

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
