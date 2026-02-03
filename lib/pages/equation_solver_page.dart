// lib/pages/equation_solver_page.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';

class EquationSolverPage extends StatefulWidget {
  const EquationSolverPage({super.key});

  @override
  State<EquationSolverPage> createState() => _EquationSolverPageState();
}

class _EquationSolverPageState extends State<EquationSolverPage> {
  EquationType _selectedEquationType = EquationType.quadratic;

  final TextEditingController _coeffAController = TextEditingController();
  final TextEditingController _coeffBController = TextEditingController();
  final TextEditingController _coeffCController = TextEditingController();
  final TextEditingController _coeffDController = TextEditingController(); // Solo per cubica

  String _result = '';
  String _errorMessage = '';

  @override
  void dispose() {
    _coeffAController.dispose();
    _coeffBController.dispose();
    _coeffCController.dispose();
    _coeffDController.dispose();
    super.dispose();
  }

  void _solveEquation() {
    setState(() {
      _errorMessage = '';
      _result = '';
    });

    double a, b, c, d;

    try {
      a = double.tryParse(_coeffAController.text.trim()) ?? 0.0;
      b = double.tryParse(_coeffBController.text.trim()) ?? 0.0;
      c = double.tryParse(_coeffCController.text.trim()) ?? 0.0;

      if (_selectedEquationType == EquationType.cubic) {
        d = double.tryParse(_coeffDController.text.trim()) ?? 0.0;
      } else {
        d = 0.0;
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Assicurati di inserire valori numerici validi per i coefficienti.';
      });
      return;
    }

    if (_selectedEquationType == EquationType.quadratic) {
      if (a == 0) {
        setState(() {
          _errorMessage = 'Il coefficiente \'a\' per un\'equazione quadratica non può essere zero.';
        });
        return;
      }
      _result = _solveQuadratic(a, b, c);
    } else { // Cubic
      if (a == 0) {
        setState(() {
          _errorMessage = 'Il coefficiente \'a\' per un\'equazione cubica non può essere zero.';
        });
        return;
      }
      _result = _solveCubic(a, b, c, d);
    }

    setState(() {});
  }

  void _clearAllFields() {
    setState(() {
      _coeffAController.clear();
      _coeffBController.clear();
      _coeffCController.clear();
      _coeffDController.clear();
      _result = '';
      _errorMessage = '';
    });
  }
  String _solveQuadratic(double a, double b, double c) {
    final d = b * b - 4 * a * c; // Discriminant
    if (d < 0) {
      // Complex solutions
      final real = -b / (2 * a);
      final imag = sqrt(-d) / (2 * a);
      return 'Soluzioni complesse:\nx₁ = ${real.toStringAsFixed(6)} + ${imag.toStringAsFixed(6)}i\nx₂ = ${real.toStringAsFixed(6)} - ${imag.toStringAsFixed(6)}i';
    } else if (d == 0) {
      // Real and equal solutions
      final x = -b / (2 * a);
      return 'x = ${x.toStringAsFixed(6)} (radice doppia)';
    }
    else {
      // Real and distinct solutions
      final x1 = (-b + sqrt(d)) / (2 * a);
      final x2 = (-b - sqrt(d)) / (2 * a);
      return 'x₁ = ${x1.toStringAsFixed(6)}, x₂ = ${x2.toStringAsFixed(6)}';
    }
  }

  // Cardano's method
  String _solveCubic(double a, double b, double c, double d) {
    final p = (3 * a * c - b * b) / (3 * a * a);
    final q = (2 * b * b * b - 9 * a * b * c + 27 * a * a * d) / (27 * a * a * a);

    final discriminant = (q / 2) * (q / 2) + (p / 3) * (p / 3) * (p / 3);

    if (discriminant >= 0) {
      final u = _cbrt(-q / 2 + sqrt(discriminant));
      final v = _cbrt(-q / 2 - sqrt(discriminant));
      final y1 = u + v;
      final x1 = y1 - b / (3 * a);

      if (discriminant.abs() < 1e-9) {
        final y2 = -u / 2 - v / 2;
        final x2 = y2 - b / (3 * a);
        return 'x₁ = ${x1.toStringAsFixed(6)}\nx₂ = ${x2.toStringAsFixed(6)} (radice doppia)';
      } else {
        final realPart = -(u + v) / 2;
        final imagPart = sqrt(3) / 2 * (u - v);

        final x2Real = realPart - b / (3 * a);
        final x2Imag = imagPart;
        final x3Real = realPart - b / (3 * a);
        final x3Imag = -imagPart;

        String result = 'x₁ = ${x1.toStringAsFixed(6)}';
        if (x2Imag.abs() < 1e-9) {
          result += '\nx₂ = ${x2Real.toStringAsFixed(6)}';
          result += '\nx₃ = ${x3Real.toStringAsFixed(6)}';
        } else {
          result += '\nx₂ = ${x2Real.toStringAsFixed(6)} + ${x2Imag.toStringAsFixed(6)}i';
          result += '\nx₃ = ${x3Real.toStringAsFixed(6)} - ${x3Imag.toStringAsFixed(6)}i';
        }
        return result;
      }
    } else {
      final r = sqrt(-(p * p * p) / 27);
      final theta = acos(-q / (2 * r));
      final y1 = 2 * r * cos(theta / 3);
      final y2 = 2 * r * cos((theta + 2 * pi) / 3);
      final y3 = 2 * r * cos((theta + 4 * pi) / 3);

      final x1 = y1 - b / (3 * a);
      final x2 = y2 - b / (3 * a);
      final x3 = y3 - b / (3 * a);
      return 'x₁ = ${x1.toStringAsFixed(6)}, x₂ = ${x2.toStringAsFixed(6)}, x₃ = ${x3.toStringAsFixed(6)}';
    }
  }

  double _cbrt(double x) => x >= 0 ? pow(x, 1 / 3).toDouble() : -pow(-x, 1 / 3).toDouble();


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + 98, left: 16, right: 16, top: MediaQuery.of(context).viewPadding.top + 70),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Seleziona il tipo di equazione e inserisci i coefficienti.',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Card(
                  color: colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      RadioListTile<EquationType>(
                        title: Text('Eqz. 2° grado (ax² + bx + c = 0)', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        value: EquationType.quadratic,
                        groupValue: _selectedEquationType,
                        onChanged: (EquationType? value) {
                          setState(() {
                            _selectedEquationType = value!;
                            _result = '';
                            _errorMessage = '';
                          });
                        },
                        activeColor: colorScheme.primary,
                      ),
                      RadioListTile<EquationType>(
                        title: Text('Eqz. 3° grado (ax³ + bx² + cx + d = 0)', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        value: EquationType.cubic,
                        groupValue: _selectedEquationType,
                        onChanged: (EquationType? value) {
                          setState(() {
                            _selectedEquationType = value!;
                            _result = '';
                            _errorMessage = '';
                          });
                        },
                        activeColor: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Input Coefficienti
                Text(
                  'Inserisci i coefficienti:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
                const SizedBox(height: 10),

                _buildCoefficientTextField(
                  controller: _coeffAController,
                  label: 'Coefficiente a',
                  hintText: _selectedEquationType == EquationType.quadratic ? 'es. per ax²' : 'es. per ax³',
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 10),
                _buildCoefficientTextField(
                  controller: _coeffBController,
                  label: 'Coefficiente b',
                  hintText: _selectedEquationType == EquationType.quadratic ? 'es. per bx' : 'es. per bx²',
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 10),
                _buildCoefficientTextField(
                  controller: _coeffCController,
                  label: 'Coefficiente c',
                  hintText: _selectedEquationType == EquationType.quadratic ? 'es. per c (costante)' : 'es. per cx',
                  colorScheme: colorScheme,
                ),
                if (_selectedEquationType == EquationType.cubic) ...[
                  const SizedBox(height: 10),
                  _buildCoefficientTextField(
                    controller: _coeffDController,
                    label: 'Coefficiente d',
                    hintText: 'es. per d (costante)',
                    colorScheme: colorScheme,
                  ),
                ],

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _solveEquation,
                        icon: const Icon(Icons.check),
                        label: const Text('Risolvi Equazione'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _clearAllFields,
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Pulisci Campi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.tertiary,
                          foregroundColor: colorScheme.onTertiary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_errorMessage.isNotEmpty)
                  Card(
                    color: colorScheme.errorContainer,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: colorScheme.onErrorContainer, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (_result.isNotEmpty)
                  Card(
                    color: colorScheme.secondaryContainer,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Risultato:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSecondaryContainer),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            _result,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSecondaryContainer),
                          ),
                        ],
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
              title: 'Risolutore Equazioni',
              leading: FloatingTopBarLeading.back,
              onBackPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildCoefficientTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required ColorScheme colorScheme,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(Icons.numbers, color: colorScheme.primary),
      ),
      style: TextStyle(color: colorScheme.onSurface, fontSize: 18),
    );
  }
}

enum EquationType {
  quadratic,
  cubic,
}