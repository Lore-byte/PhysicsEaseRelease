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

  bool _showResult = false;
  bool _showExpression = true;

  late TextEditingController _expressionController;
  late ScrollController _scrollController;
  late FocusNode _focusNode;

  double _expressionFontSize = 52;
  final double _minFontSize = 24;
  final double _maxFontSize = 52;

  final double _resultHeight = 55.0;
  final double _radDegHeight = 34.0;

  @override
  void initState() {
    super.initState();
    _expressionController = TextEditingController(text: _expression);
    _scrollController = ScrollController();
    _focusNode = FocusNode();

    _expressionController.selection =
        TextSelection.collapsed(offset: _expressionController.text.length);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _showResult = !_isSmallScreen();
      _showExpression = true;
    });
  }

  @override
  void dispose() {
    _expressionController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  final Map<String, String> _operatorMap = {
    '÷': '/',
    '×': '*',
    '^': '^',
  };

  final List<List<String>> _buttonsLayout = [
    ['AC', 'DL', '%', '÷', 'Sci'],
    ['7', '8', '9', '×', '('],
    ['4', '5', '6', '-', ')'],
    ['1', '2', '3', '+', '^'],
    ['0', '.', '='],
  ];

  final List<List<String>> _scientificButtonsLayout = [
    ['AC', 'DL', 'RAD/DEG_TOGGLE', 'Sci'],
    ['sin', 'cos', 'tan', 'π'],
    ['log', 'ln', '√', 'e'],
    ['!', 'e^x', '(', ')'],
    ['='],
  ];

  Widget _buildButton(String displayedText, String actionText, Color buttonColor, Color textColor, {double fontSize = 24.0, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
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
          onPressed: actionText.isEmpty ? null : () => _onButtonPressed(actionText),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(displayedText),
          ),
        ),
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
    String formatted = value.toStringAsPrecision(8);
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      if (formatted.endsWith('.')) {
        formatted = formatted.substring(0, formatted.length - 1);
      }
    }
    return formatted;
  }

  void _adjustFontSize() {
    final text = _expressionController.text;
    if (text.isEmpty) {
      if (_expressionFontSize != _maxFontSize) {
        setState(() {
          _expressionFontSize = _maxFontSize;
        });
      }
      return;
    }

    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: _expressionFontSize)),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    double maxWidth = MediaQuery.of(context).size.width - 32;

    if (tp.width > maxWidth && _expressionFontSize > _minFontSize) {
      setState(() {
        _expressionFontSize = (_expressionFontSize - 2).clamp(_minFontSize, _maxFontSize);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          try {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          } catch (_) {}
        }
      });
    } else if (tp.width < maxWidth && _expressionFontSize < _maxFontSize) {
      setState(() {
        _expressionFontSize = (_expressionFontSize + 2).clamp(_minFontSize, _maxFontSize);
      });
    }
  }

  bool _isSmallScreen() {
    return MediaQuery.of(context).size.width < 350;
  }

  void _onButtonPressed(String buttonText) {
    setState(() {
      final text = _expressionController.text;
      TextSelection selection = _expressionController.selection;
      if (!selection.isValid ||
          selection.start < 0 ||
          selection.end < 0 ||
          selection.start > text.length ||
          selection.end > text.length) {
        selection = TextSelection.collapsed(offset: text.length);
        _expressionController.selection = selection;
      }

      void insertTextAtCursor(String insertText) {
        final newText = text.replaceRange(selection.start, selection.end, insertText);
        _expressionController.text = newText;
        _expression = newText;

        final newCursorPosition = selection.start + insertText.length;
        _expressionController.selection = TextSelection.collapsed(offset: newCursorPosition);

        if (_isSmallScreen()) {
          _showResult = false;
          _showExpression = true;
        } else {
          _showResult = true;
          _showExpression = true;
        }

        _adjustFontSize();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }

      if (buttonText == 'AC') {
        _expression = '';
        _expressionController.text = '';
        _result = '0';
        _expressionFontSize = _maxFontSize;
        _expressionController.selection = const TextSelection.collapsed(offset: 0);
        _focusNode.requestFocus();
        _showResult = !_isSmallScreen();
        _showExpression = true;
      } else if (buttonText == 'DL') {
        if (selection.start > 0) {
          final newText = text.replaceRange(selection.start - 1, selection.start, '');
          _expressionController.text = newText;
          _expression = newText;
          _expressionController.selection =
              TextSelection.collapsed(offset: selection.start - 1);
        }
        if (_expressionController.text.isEmpty) {
          _result = '0';
          _expressionFontSize = _maxFontSize;
        }

        if (_isSmallScreen()) {
          _showResult = false;
          _showExpression = true;
        } else {
          _showResult = true;
          _showExpression = true;
        }

        _adjustFontSize();
      } else if (buttonText == '=') {
        try {
          String finalExpression = _expressionController.text;
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

          if (finalExpression.contains('!')) {
            RegExp regExp = RegExp(r'(\d+)!');
            finalExpression = finalExpression.replaceAllMapped(regExp, (match) {
              int num = int.parse(match.group(1)!);
              return _factorial(num).toString();
            });
          }

          if (!_isRadians) {
            finalExpression = finalExpression.replaceAllMapped(
              RegExp(r'(sin|cos|tan)\((-?\d+(\.\d*)?)\)'),
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
          const int displayPrecision = 8;

          if (absNumericResult >= largeNumberThreshold ||
              (absNumericResult > 0 && absNumericResult < smallNumberThreshold)) {
            formattedResult = numericResultDouble.toStringAsExponential(displayPrecision - 1);

            formattedResult = formattedResult.replaceAll(RegExp(r'0+(?=e[+-]\d+$)'), '');
            if (formattedResult.contains('.') &&
                formattedResult.contains('e') &&
                formattedResult.split('e')[0].endsWith('.')) {
              formattedResult = formattedResult.replaceAllMapped(
                  RegExp(r'\.(?=e[+-]\d+$)'), (match) => '');
            }
          } else if (numericResultDouble == numericResultDouble.roundToDouble()) {
            formattedResult = numericResultDouble.toInt().toString();
          } else {
            formattedResult = _formatDecimal(numericResultDouble);
          }
          _result = formattedResult;

          _showResult = true;
          if (_isSmallScreen()) {
            _showExpression = false;
          } else {
            _showExpression = true;
          }
        } catch (e) {
          _result = 'Errore';
          print('Errore di calcolo: $e');
          _showResult = true;
          _showExpression = true;
        }
      } else if (buttonText == 'RAD/DEG_TOGGLE') {
        _isRadians = !_isRadians;
      } else if (buttonText == 'Sci') {
        _showScientificButtons = !_showScientificButtons;
      } else if (['sin', 'cos', 'tan', '√', 'log', 'ln', 'π', 'e', 'e^x', '!'].contains(buttonText)) {
        String insertText;
        switch (buttonText) {
          case 'sin':
          case 'cos':
          case 'tan':
            insertText = '$buttonText(';
            break;
          case '√':
            insertText = 'sqrt(';
            break;
          case 'log':
            insertText = 'log(10,';
            break;
          case 'ln':
            insertText = 'ln(';
            break;
          case 'e^x':
            insertText = 'E^(';
            break;
          case 'π':
            insertText = 'pi';
            break;
          case 'e':
            insertText = 'E';
            break;
          case '!':
            insertText = '!';
            break;
          default:
            insertText = buttonText;
        }
        insertTextAtCursor(insertText);
      } else {
        insertTextAtCursor(buttonText);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<List<String>> buttonsLayout = _showScientificButtons ? _scientificButtonsLayout : _buttonsLayout;
    final bool smallScreen = _isSmallScreen();

    Widget buildDisplayArea() {
      final radDegWidget = Align(
        alignment: Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _isRadians ? 'RAD' : 'DEG',
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );

      if (!smallScreen) {
        return Stack(
          alignment: Alignment.bottomRight,
          children: [
            if (_showExpression)
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(top: _radDegHeight, bottom: _resultHeight),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: TextField(
                      controller: _expressionController,
                      focusNode: _focusNode,
                      autofocus: true,
                      readOnly: true,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: _expressionFontSize,
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w300,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: 1,
                      showCursor: true,
                      cursorColor: colorScheme.primary,
                      scrollController: _scrollController,
                    ),
                  ),
                ),
              ),

            Positioned(
              top: 0,
              right: 0,
              child: radDegWidget,
            ),

            if (_showResult)
              Positioned(
                bottom: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.bottomRight,
                    child: Text(
                      _result,
                      style: TextStyle(
                        fontSize: 38,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ),
          ],
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          radDegWidget,
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
              child: _showExpression
                  ? Align(
                key: const ValueKey('expr_small'),
                alignment: Alignment.bottomRight,
                child: TextField(
                  controller: _expressionController,
                  focusNode: _focusNode,
                  autofocus: true,
                  readOnly: true,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: _expressionFontSize,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w300,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  maxLines: 1,
                  showCursor: true,
                  cursorColor: colorScheme.primary,
                  scrollController: _scrollController,
                ),
              )
                  : _showResult
                  ? Align(
                key: const ValueKey('result_small'),
                alignment: Alignment.bottomRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _result,
                    style: TextStyle(
                      fontSize: _maxFontSize,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              )
                  : const SizedBox.shrink(key: ValueKey('empty_small')),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0, top: MediaQuery.of(context).viewPadding.top + 70),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.4),
              ),
              child: buildDisplayArea(),
            ),
          ),
          Divider(height: 1, color: colorScheme.outline.withOpacity(0.5)),
          Expanded(
            flex: 4,
            child: Container(
              color: colorScheme.surface,
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + 98, left: 8.0, right: 8.0, top: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: buttonsLayout.map((row) {
                  return Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: row.map((buttonText) {
                        int flex = 1;
                        if (!_showScientificButtons && buttonText == '0') {
                          flex = 2;
                        }

                        String displayedButtonText = buttonText;
                        if (buttonText == 'RAD/DEG_TOGGLE') {
                          displayedButtonText = _isRadians ? 'DEG' : 'RAD';
                        }
                        Color buttonColor = colorScheme.surfaceContainerHighest;
                        Color textColor = colorScheme.onSurface;
                        double currentFontSize = 24.0;
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
                        }
                        if (buttonText == 'RAD/DEG_TOGGLE' || buttonText == 'Sci') {
                          currentFontSize = 18.0;
                          buttonColor = colorScheme.tertiary;
                          textColor = colorScheme.onTertiary;
                        }

                        return _buildButton(displayedButtonText, buttonText, buttonColor, textColor, fontSize: currentFontSize, flex: flex);
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}