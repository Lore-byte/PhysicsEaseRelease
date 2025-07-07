// lib/pages/calculator_page.dart
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = '';
  String _result = '0';
  bool _isRadians = true;
  bool _showScientificButtons = false;

  final Map<String, String> _operatorMap = {
    '÷': '/',
    '×': '*',
    '^': '^',
    '%': '/100',
  };

  Widget _buildButton(String text, Color buttonColor, Color textColor, {int flex = 1, double fontSize = 24.0}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
          onPressed: () => _onButtonPressed(text),
          child: Text(text),
        ),
      ),
    );
  }

  // Funzione per il fattoriale
  int _factorial(int n) {
    if (n < 0) return 1;
    if (n == 0) return 1;
    int result = 1;
    for (int i = 1; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'AC') {
        _expression = '';
        _result = '0';
      } else if (buttonText == 'DL') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
        if (_expression.isEmpty) {
          _result = '0';
        }
      } else if (buttonText == '=') {
        try {
          String finalExpression = _expression;

          _operatorMap.forEach((key, value) {
            finalExpression = finalExpression.replaceAll(key, value);
          });

          print('Espressione originale: $_expression');
          print('Espressione finale da parsare: $finalExpression');

          // Gestione Fattoriale
          if (finalExpression.contains('!')) {
            RegExp regExp = RegExp(r'(\d+)!');
            finalExpression = finalExpression.replaceAllMapped(regExp, (match) {
              int num = int.parse(match.group(1)!);
              return _factorial(num).toString();
            });
          }

          // Gestione RAD/DEG per funzioni trigonometriche
          if (!_isRadians) {
            finalExpression = finalExpression.replaceAllMapped(
              RegExp(r'(sin|cos|tan)\((\d+(\.\d*)?)\)'),
                  (match) {
                String func = match.group(1)!;
                double angle = double.parse(match.group(2)!);
                double angleInRadians = angle * math.pi / 180.0;
                return '$func($angleInRadians)';
              },
            );
          }

          Parser p = Parser();
          Expression exp = p.parse(finalExpression);
          ContextModel cm = ContextModel();

          cm.bindVariable(Variable('E'), Number(math.e));
          cm.bindVariable(Variable('pi'), Number(math.pi));


          num evaluationResult = exp.evaluate(EvaluationType.REAL, cm);

          String formattedResult;
          final num numericResult = evaluationResult;
          final num absNumericResult = numericResult.abs();

          const double largeNumberThreshold = 1e10;
          const double smallNumberThreshold = 1e-10;
          const int precision = 12;

          if (absNumericResult >= largeNumberThreshold || (absNumericResult > 0 && absNumericResult < smallNumberThreshold)) {
            formattedResult = numericResult.toDouble().toStringAsExponential(precision - 1);
            formattedResult = formattedResult.replaceAll(RegExp(r'0+(?=e[+-]\d+$)'), '');
            if (formattedResult.contains('.') && formattedResult.contains('e') && formattedResult.split('e')[0].endsWith('.')) {
              formattedResult = formattedResult.replaceAllMapped(RegExp(r'\.(?=e[+-]\d+$)'), (match) => '');
            }
          } else if (numericResult == numericResult.roundToDouble()) {
            formattedResult = numericResult.toInt().toString();
          } else {
            formattedResult = numericResult.toStringAsPrecision(precision);
            formattedResult = formattedResult.replaceAll(RegExp(r'\.0+$|(\.\d*?[1-9])0+$'), r'$1');
            if (formattedResult.endsWith('.')) {
              formattedResult = formattedResult.substring(0, formattedResult.length - 1);
            }
          }
          _result = formattedResult;

        } catch (e) {
          _result = 'Errore';
          print('Errore di calcolo: $e'); // Stampa l'errore per il debug
        }
      } else if (buttonText == 'RAD/DEG') {
        _isRadians = !_isRadians;
      } else if (buttonText == 'Sci') {
        _showScientificButtons = !_showScientificButtons;
      }

      else if (buttonText == 'sin' || buttonText == 'cos' || buttonText == 'tan' || buttonText == 'sqrt') {
        _expression += '$buttonText(';
      } else if (buttonText == 'log') {
        _expression += 'log(10,'; // Logaritmo in base 10
      } else if (buttonText == 'ln') {
        _expression += 'ln(';
      } else if (buttonText == '√') {
        _expression += 'sqrt(';
      } else if (buttonText == 'e^x') {
        _expression += 'e^';
      } else if (buttonText == 'π') {
        _expression += 'pi';
      } else if (buttonText == 'e') {
        _expression += 'E';
      } else if (buttonText == '!') {
        if (_expression.isNotEmpty && RegExp(r'\d$').hasMatch(_expression[_expression.length -1])) {
          _expression += buttonText;
        }
      }

      else {

        if (_expression.isEmpty && (_isOperator(buttonText) && buttonText != '-' )) {
          return;
        }

        if (_expression.isNotEmpty && _isOperator(_expression[_expression.length - 1]) && _isOperator(buttonText)) {
          _expression = _expression.substring(0, _expression.length - 1) + buttonText;
        } else {
          _expression += buttonText;
        }
      }
    });
  }

  bool _isOperator(String text) {
    return text == '+' || text == '-' || text == '×' || text == '÷' || text == '^' || text == '%' ||
        text == 's' || text == 'c' || text == 't';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    const double maxExpressionFontSize = 52.0;
    const double minExpressionFontSize = 24.0;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              alignment: Alignment.bottomRight,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _isRadians ? 'RAD' : 'DEG',
                      style: TextStyle(fontSize: 18, color: colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      TextPainter textPainter = TextPainter(
                        text: TextSpan(
                          text: _expression.isEmpty ? '0' : _expression,
                          style: TextStyle(fontSize: maxExpressionFontSize, fontWeight: FontWeight.w300, color: colorScheme.onSurface),
                        ),
                        textDirection: TextDirection.ltr,
                        maxLines: 1,
                      )..layout(minWidth: 0, maxWidth: double.infinity);

                      double textWidth = textPainter.width;
                      double displayWidth = constraints.maxWidth;

                      double calculatedFontSize = maxExpressionFontSize;

                      if (textWidth > displayWidth) {
                        calculatedFontSize = (displayWidth / textWidth) * maxExpressionFontSize;
                        if (calculatedFontSize < minExpressionFontSize) {
                          calculatedFontSize = minExpressionFontSize;
                        }
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          _expression.isEmpty ? '0' : _expression,
                          style: TextStyle(fontSize: calculatedFontSize, color: colorScheme.onSurface, fontWeight: FontWeight.w300),
                          maxLines: 1,
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _result,
                      style: TextStyle(fontSize: 38, color: colorScheme.primary, fontWeight: FontWeight.w300),
                      maxLines: 1,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Divider(height: 1, color: colorScheme.outline.withOpacity(0.5)),

          Expanded(
            flex: 4,
            child: Container(
              color: colorScheme.surface,
              padding: const EdgeInsets.all(6.0),
              child: Column(
                children: [
                  if (!_showScientificButtons)
                    Column(
                      children: [
                        // Riga 1: AC, DEL, %, ÷, Sci
                        Row(
                          children: [
                            _buildButton('AC', colorScheme.error, colorScheme.onError),
                            _buildButton('DL', colorScheme.errorContainer, colorScheme.onErrorContainer),
                            _buildButton('%', colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
                            _buildButton('÷', colorScheme.primary, colorScheme.onPrimary),
                            _buildButton('Sci', colorScheme.tertiary, colorScheme.onTertiary, fontSize: 18),
                          ],
                        ),
                        // Riga 2: 7, 8, 9, ×
                        Row(
                          children: [
                            _buildButton('7', colorScheme.surfaceContainerHighest, colorScheme.onSurface),
                            _buildButton('8', colorScheme.surfaceContainerHighest, colorScheme.onSurface),
                            _buildButton('9', colorScheme.surfaceContainerHighest, colorScheme.onSurface),
                            _buildButton('×', colorScheme.primary, colorScheme.onPrimary),
                            _buildButton('(', colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
                          ],
                        ),
                        // Riga 3: 4, 5, 6, -
                        Row(
                          children: [
                            _buildButton('4', colorScheme.surfaceContainerHighest, colorScheme.onSurface),
                            _buildButton('5', colorScheme.surfaceContainerHighest, colorScheme.onSurface),
                            _buildButton('6', colorScheme.surfaceContainerHighest, colorScheme.onSurface),
                            _buildButton('-', colorScheme.primary, colorScheme.onPrimary),
                            _buildButton(')', colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
                          ],
                        ),
                        // Riga 4: 1, 2, 3, +
                        Row(
                          children: [
                            _buildButton('1', colorScheme.surfaceContainerHighest, colorScheme.onSurface),
                            _buildButton('2', colorScheme.surfaceContainerHighest, colorScheme.onSurface),
                            _buildButton('3', colorScheme.surfaceContainerHighest, colorScheme.onSurface),
                            _buildButton('+', colorScheme.primary, colorScheme.onPrimary),
                            _buildButton('^', colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
                          ],
                        ),
                        // Riga 5: 0, ., =
                        Row(
                          children: [
                            _buildButton('0', colorScheme.surfaceContainerHighest, colorScheme.onSurface, flex: 2),
                            _buildButton('.', colorScheme.surfaceContainerHighest, colorScheme.onSurface),
                            _buildButton('=', colorScheme.tertiary, colorScheme.onTertiary, flex: 2),
                          ],
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        // Riga 1 (SCIENTIFICA): AC, DEL, RAD/DEG, Sci
                        Row(
                          children: [
                            _buildButton('AC', colorScheme.error, colorScheme.onError),
                            _buildButton('DL', colorScheme.errorContainer, colorScheme.onErrorContainer),
                            _buildButton('RAD/DEG', colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer, fontSize: 18),
                            _buildButton('Sci', colorScheme.tertiary, colorScheme.onTertiary, fontSize: 18),
                          ],
                        ),
                        // Riga 2 (SCIENTIFICA): sin, cos, tan, π
                        Row(
                          children: [
                            _buildButton('sin', colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
                            _buildButton('cos', colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
                            _buildButton('tan', colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
                            _buildButton('π', colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
                          ],
                        ),
                        // Riga 3 (SCIENTIFICA): log, ln, √, e
                        Row(
                          children: [
                            _buildButton('log', colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
                            _buildButton('ln', colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
                            _buildButton('√', colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
                            _buildButton('e', colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
                          ],
                        ),
                        // Riga 4 (SCIENTIFICA): !, e^x, (, )
                        Row(
                          children: [
                            _buildButton('!', colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
                            _buildButton('e^x', colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
                            _buildButton('(', colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
                            _buildButton(')', colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
                          ],
                        ),
                        // Riga 5 (SCIENTIFICA): =
                        Row(
                          children: [
                            _buildButton('=', colorScheme.tertiary, colorScheme.onTertiary, flex: 4),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}