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
  };

  final List<String> _buttons = [
    'AC', 'DL', '%', '÷', 'Sci',
    '7', '8', '9', '×', '(',
    '4', '5', '6', '-', ')',
    '1', '2', '3', '+', '^',
    '0', '.', '=',
  ];

  final List<String> _scientificButtons = [
    'AC', 'DL', 'RAD/DEG', 'Sci',
    'sin', 'cos', 'tan', 'π',
    'log', 'ln', '√', 'e',
    '!', 'e^x', '(', ')',
    '=',
  ];

  Widget _buildButton(String text, Color buttonColor, Color textColor, {double fontSize = 24.0}) {
    return Padding(
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
    );
  }

  int _factorial(int n) {
    if (n < 0) return 1;
    if (n == 0) return 1;
    int result = 1;
    for (int i = 1; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  String _formatDecimal(double value) {
    String formatted = value.toStringAsPrecision(12);

    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      if (formatted.endsWith('.')) {
        formatted = formatted.substring(0, formatted.length - 1);
      }
    }
    return formatted;
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

          finalExpression = finalExpression.replaceAllMapped(
            RegExp(r'(\d+(\.\d*)?)%'),
                (match) {
              double num = double.parse(match.group(1)!);
              return (num / 100).toString();
            },
          );

          print('Espressione originale: $_expression');
          print('Espressione finale da parsare: $finalExpression');

          if (finalExpression.contains('!')) {
            RegExp regExp = RegExp(r'(\d+)!');
            finalExpression = finalExpression.replaceAllMapped(regExp, (match) {
              int num = int.parse(match.group(1)!);
              return _factorial(num).toString();
            });
          }

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
          final double numericResultDouble = evaluationResult.toDouble();
          final num absNumericResult = numericResultDouble.abs();

          const double largeNumberThreshold = 1e10;
          const double smallNumberThreshold = 1e-10;
          const int displayPrecision = 12;

          if (absNumericResult >= largeNumberThreshold || (absNumericResult > 0 && absNumericResult < smallNumberThreshold)) {
            formattedResult = numericResultDouble.toStringAsExponential(displayPrecision - 1);
            formattedResult = formattedResult.replaceAll(RegExp(r'0+(?=e[+-]\d+$)'), '');
            if (formattedResult.contains('.') && formattedResult.contains('e') && formattedResult.split('e')[0].endsWith('.')) {
              formattedResult = formattedResult.replaceAllMapped(RegExp(r'\.(?=e[+-]\d+$)'), (match) => '');
            }
          } else if (numericResultDouble == numericResultDouble.roundToDouble()) {
            formattedResult = numericResultDouble.toInt().toString();
          } else {
            formattedResult = _formatDecimal(numericResultDouble);
          }
          _result = formattedResult;

        } catch (e) {
          _result = 'Errore';
          print('Errore di calcolo: $e');
        }
      } else if (buttonText == 'RAD/DEG') {
        _isRadians = !_isRadians;
      } else if (buttonText == 'Sci') {
        _showScientificButtons = !_showScientificButtons;
      }
      else if (['sin', 'cos', 'tan', 'sqrt'].contains(buttonText)) {
        _expression += '$buttonText(';
      } else if (buttonText == 'log') {
        _expression += 'log(10,';
      } else if (buttonText == 'ln') {
        _expression += 'ln(';
      } else if (buttonText == '√') {
        _expression += 'sqrt(';
      } else if (buttonText == 'e^x') {
        _expression += 'E^';
      } else if (buttonText == 'π') {
        _expression += 'pi';
      } else if (buttonText == 'e') {
        _expression += 'E';
      } else if (buttonText == '!') {
        if (_expression.isNotEmpty && RegExp(r'\d$').hasMatch(_expression[_expression.length - 1])) {
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
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _showScientificButtons ? 4 : 5,
                  childAspectRatio: _showScientificButtons ? 1.2 : 1.0,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                ),
                itemCount: _showScientificButtons ? _scientificButtons.length : _buttons.length,
                itemBuilder: (context, index) {
                  final String buttonText = _showScientificButtons ? _scientificButtons[index] : _buttons[index];
                  Color buttonColor = colorScheme.surfaceContainerHighest;
                  Color textColor = colorScheme.onSurface;
                  double fontSize = 24.0;

                  if (buttonText == 'AC') {
                    buttonColor = colorScheme.error;
                    textColor = colorScheme.onError;
                  } else if (buttonText == 'DL') {
                    buttonColor = colorScheme.errorContainer;
                    textColor = colorScheme.onErrorContainer;
                  } else if (['÷', '×', '-', '+'].contains(buttonText)) {
                    buttonColor = colorScheme.primary;
                    textColor = colorScheme.onPrimary;
                  } else if (buttonText == '=') {
                    buttonColor = colorScheme.tertiary;
                    textColor = colorScheme.onTertiary;
                  } else if (['%', '^', '(', ')'].contains(buttonText) ||
                      _showScientificButtons && ['sin', 'cos', 'tan', 'π', 'log', 'ln', '√', 'e', '!', 'e^x'].contains(buttonText)) {
                    buttonColor = colorScheme.secondaryContainer;
                    textColor = colorScheme.onSecondaryContainer;
                  } else if (buttonText == 'Sci' || buttonText == 'RAD/DEG') {
                    buttonColor = colorScheme.tertiary;
                    textColor = colorScheme.onTertiary;
                    fontSize = 18.0;
                  }

                  if (!_showScientificButtons && (buttonText == '0' || buttonText == '=')) {
                    return AspectRatio(
                      aspectRatio: 2.0,
                      child: _buildButton(buttonText, buttonColor, textColor, fontSize: fontSize),
                    );
                  }
                  return _buildButton(buttonText, buttonColor, textColor, fontSize: fontSize);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}