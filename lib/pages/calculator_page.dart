import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;
import 'package:flutter_math_fork/flutter_math.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _result = '0';
  bool _isRadians = true;
  bool _showScientificButtons = false;
  bool _isResultMode = false;

  late TextEditingController _expressionController;
  late ScrollController _scrollController;
  late FocusNode _focusNode;

  double _expressionFontSize = 64;
  final double _minFontSize = 42;
  final double _maxFontSize = 64;

  final double _displayHorizontalSafety = 12.0;

  static const List<String> _scientificInputButtons = [
    'sin',
    'cos',
    'tan',
    '√',
    '³√',
    'log',
    'ln',
    'π',
    'e',
    'e^x',
    '10^x',
    'x^y',
    '!',
  ];
  static const List<String> _primaryOperators = ['÷', '×', '-', '+'];
  static const List<String> _secondaryOperators = ['%', '^', '(', ')'];

  @override
  void initState() {
    super.initState();
    _expressionController = TextEditingController();
    _scrollController = ScrollController();
    _focusNode = FocusNode();
    _expressionController.addListener(_onExpressionValueChanged);

    _expressionController.selection = TextSelection.collapsed(
      offset: _expressionController.text.length,
    );
  }

  void _onExpressionValueChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _expressionController.removeListener(_onExpressionValueChanged);
    _expressionController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _convertInputToLatex(String input) {
    if (input.isEmpty) return '';
    String latex = input;

    latex = latex.replaceAllMapped(RegExp(r'(\d+(\.\d*)?)e([+-]?\d+)'), (
      match,
    ) {
      String base = match.group(1)!;
      String exponent = match.group(3)!;
      if (exponent.startsWith('+')) exponent = exponent.substring(1);
      return '$base \\times 10^{$exponent}';
    });

    latex = latex.replaceAll('÷', r'\div ');
    latex = latex.replaceAll('×', r'\times ');
    latex = latex.replaceAll('π', r'\pi');
    latex = latex.replaceAll('%', r'\%');

    latex = latex.replaceAll('log₁₀', r'\log_{10}');

    latex = latex.replaceAllMapped(RegExp(r'(sin|cos|tan|ln)'), (match) {
      return r'\' + match.group(1)!;
    });

    while (latex.contains('√(')) {
      int start = latex.indexOf('√(');
      int openParens = 1;
      int end = -1;

      for (int i = start + 2; i < latex.length; i++) {
        if (latex[i] == '(') openParens++;
        if (latex[i] == ')') openParens--;

        if (openParens == 0) {
          end = i;
          break;
        }
      }

      if (end != -1) {
        String content = latex.substring(start + 2, end);
        latex = latex.replaceRange(start, end + 1, '\\sqrt{($content)}');
      } else {
        latex = latex.replaceFirst('√(', r'\sqrt{(');
        latex += '}';
      }
    }

    while (latex.contains('³√(')) {
      int start = latex.indexOf('³√(');
      int openParens = 1;
      int end = -1;
      for (int i = start + 3; i < latex.length; i++) {
        if (latex[i] == '(') openParens++;
        if (latex[i] == ')') openParens--;
        if (openParens == 0) {
          end = i;
          break;
        }
      }
      if (end != -1) {
        String content = latex.substring(start + 3, end);
        latex = latex.replaceRange(
          start,
          end + 1,
          '\\sqrt[3]{($content)}'
        );
      } else {
        latex = latex.replaceFirst('³√(', r'\sqrt[3]{(');
        latex += '}';
      }
    }

    while (latex.contains('^(')) {
      int start = latex.indexOf('^(');
      int openParens = 1;
      int end = -1;

      for (int i = start + 2; i < latex.length; i++) {
        if (latex[i] == '(') openParens++;
        if (latex[i] == ')') openParens--;

        if (openParens == 0) {
          end = i;
          break;
        }
      }

      if (end != -1) {
        String content = latex.substring(start + 2, end);
        latex = latex.replaceRange(start, end + 1, '^{($content)}');
      } else {
        latex = latex.replaceFirst('^(', r'^{(');
        latex += '}';
      }
    }

    return latex;
  }

  String _convertResultToLatex(String result) {
    if (result == 'Errore') return r'\text{Errore}';
    if (result == 'Infinity') return r'\infty';
    if (result == '-Infinity') return r'-\infty';
    if (result == 'NaN') return r'\text{NaN}';

    if (result.contains('e')) {
      final parts = result.split('e');
      final base = parts[0];
      String exponent = parts[1];

      if (exponent.startsWith('+')) {
        exponent = exponent.substring(1);
      }

      return '$base \\times 10^{$exponent}';
    }

    return result;
  }

  static const List<List<String>> _buttonsLayout = [
    ['AC', 'DL', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['Sci', '0', '.', '='],
  ];

  static const List<List<String>> _scientificExtraRows = [
    ['RAD/DEG_TOGGLE', 'sin', 'cos', 'tan'],
    ['ln', 'log', '10^x', 'e^x'],
    ['π', 'e', 'x^y', '!'],
    ['(', ')', '√', '³√'],
  ];

  Widget _buildButtonContent(
    String actionText,
    String displayedText,
    double fontSize,
    Color textColor,
  ) {
    if (actionText == 'DL') {
      return Icon(Icons.backspace_outlined, size: fontSize + 2);
    }

    final isNumberOrDot = RegExp(r'^[0-9.]$').hasMatch(actionText);

    if (['AC', 'Sci', 'RAD/DEG_TOGGLE'].contains(actionText) || isNumberOrDot) {
      return Text(displayedText);
    }

    String latex = displayedText;
    switch (actionText) {
      case '÷':
        latex = r'\div';
        break;
      case '×':
        latex = r'\times';
        break;
      case '-':
        latex = '-';
        break;
      case '+':
        latex = '+';
        break;
      case '%':
        latex = r'\%';
        break;
      case 'π':
        latex = r'\pi';
        break;
      case '√':
        latex = r'\sqrt{\square}';
        break;
      case '³√':
        latex = r'\sqrt[3]{\square}';
        break;
      case 'e^x':
        latex = r'e^x';
        break;
      case '10^x':
        latex = r'10^x';
        break;
      case 'x^y':
        latex = r'x^y';
        break;
      case '!':
        latex = r'x!';
        break;
      case 'log':
        latex = r'\log_{10}';
        break;
      case 'ln':
        latex = r'\ln';
        break;
      case 'sin':
        latex = r'\sin';
        break;
      case 'cos':
        latex = r'\cos';
        break;
      case 'tan':
        latex = r'\tan';
        break;
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Math.tex(
        latex,
        textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildButton(
    String displayedText,
    String actionText,
    Color gradientStart,
    Color gradientEnd,
    Color textColor, {
    required Color borderColor,
    double fontSize = 24.0,
    int flex = 1,
  }) {
    final double verticalPadding = _showScientificButtons ? 6.0 : 16.0;

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor, width: 1.1),
            gradient: LinearGradient(
              colors: [gradientStart, gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
              foregroundColor: WidgetStatePropertyAll(textColor),
              surfaceTintColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
              elevation: const WidgetStatePropertyAll(0),
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return textColor.withValues(alpha: 0.12);
                }
                if (states.contains(WidgetState.hovered)) {
                  return textColor.withValues(alpha: 0.07);
                }
                return null;
              }),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 2),
              ),
              textStyle: WidgetStatePropertyAll(
                TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            onPressed: actionText.isEmpty
                ? null
                : () => _onButtonPressed(actionText),
            child: _buildButtonContent(
              actionText,
              displayedText,
              fontSize,
              textColor,
            ),
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

  double _measureExpressionWidth(String text, double fontSize) {
    if (text.isEmpty) return 0;
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w300),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width;
  }

  void _updateDisplayMetrics({bool animateScroll = true}) {
    final text = _expressionController.text;
    final double maxWidth =
        MediaQuery.of(context).size.width - 32 - _displayHorizontalSafety;

    if (text.isEmpty) {
      _expressionFontSize = _maxFontSize;
      return;
    }

    final double widthAtMax = _measureExpressionWidth(text, _maxFontSize);
    double targetFontSize = _maxFontSize;

    if (widthAtMax > maxWidth) {
      final double scaleFactor = maxWidth / widthAtMax;
      targetFontSize = (_maxFontSize * scaleFactor).clamp(
        _minFontSize,
        _maxFontSize,
      );
    }

    _expressionFontSize = targetFontSize;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _setExpression(String value) {
    _expressionController.text = value;
    _expressionController.selection = TextSelection.collapsed(
      offset: value.length,
    );
    _updateDisplayMetrics();
  }

  void _prepareInputFromResultIfNeeded() {
    if (!_isResultMode) return;
    final String startingValue = _result == 'Errore' ? '' : _result;
    _isResultMode = false;
    _setExpression(startingValue);
  }

  void _insertTextAtCursor(String insertText) {
    final text = _expressionController.text;
    final selection = _expressionController.selection;

    int start = selection.start;
    if (start < 0) start = text.length;

    String textToInsert = insertText;

    if (start > 0) {
      final String prevChar = text[start - 1];

      final bool isPrevMultiplicative = RegExp(
        r'[0-9eπ!%)]',
      ).hasMatch(prevChar);

      final bool isNextMultiplicativeStart =
          RegExp(r'^[0-9eπ(sctl√]').hasMatch(textToInsert) ||
          textToInsert.startsWith('³√') ||
          textToInsert.startsWith('10^');

      final bool isPrevDigit = RegExp(r'[0-9]').hasMatch(prevChar);

      final bool isNextDigit = RegExp(r'^[0-9]+$').hasMatch(textToInsert);

      if (isPrevMultiplicative &&
          isNextMultiplicativeStart &&
          !(isPrevDigit && isNextDigit)) {
        textToInsert = '×$textToInsert';
      }
    }

    String newText;
    if (start >= text.length) {
      newText = text + textToInsert;
    } else {
      newText = text.replaceRange(start, selection.end, textToInsert);
    }

    _expressionController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + textToInsert.length),
    );

    _isResultMode = false;
    _updateDisplayMetrics();
  }

  void _deleteAtCursor() {
    final text = _expressionController.text;
    if (text.isEmpty) return;

    final selection = _expressionController.selection;
    int end = selection.end;
    if (end < 0) end = text.length;

    if (selection.start != selection.end && selection.start >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, '');
      _expressionController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start),
      );
      return;
    }

    if (end > 0) {
      final newText = text.replaceRange(end - 1, end, '');
      _expressionController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: end - 1),
      );
    }

    _updateDisplayMetrics();
  }

  String _normalizeExpression(String expression) {
    var normalized = expression;

    normalized = normalized.replaceAllMapped(
      RegExp(r'(\d+(\.\d*)?)e([+-]?\d+)'),
      (m) {
        String exponent = m.group(3)!;
        if (exponent.startsWith('+')) exponent = exponent.substring(1);
        return '(${m.group(1)}*10^($exponent))';
      },
    );

    normalized = normalized.replaceAll('÷', '/').replaceAll('×', '*');

    normalized = normalized.replaceAll('π', 'pi');

    normalized = normalized.replaceAllMapped(
      RegExp(r'log₁₀\((.*?)\)'),
      (match) => 'log(10,${match.group(1)})',
    );

    normalized = normalized.replaceAllMapped(
      RegExp(r'³√\((.*?)\)'),
      (match) => '(${match.group(1)})^(1/3)',
    );

    normalized = normalized.replaceAllMapped(
      RegExp(r'√\((.*?)\)'),
      (match) => 'sqrt(${match.group(1)})',
    );

    normalized = normalized.replaceAllMapped(RegExp(r'(\d+(\.\d*)?)%'), (
      match,
    ) {
      final numValue = double.parse(match.group(1)!);
      return (numValue / 100).toString();
    });

    if (normalized.contains('!')) {
      normalized = normalized.replaceAllMapped(RegExp(r'(\d+)!'), (match) {
        final numValue = int.parse(match.group(1)!);
        return _factorial(numValue).toString();
      });
    }

    if (!_isRadians) {
      normalized = normalized.replaceAllMapped(
        RegExp(r'(sin|cos|tan)\((-?\d+(\.\d*)?)\)'),
        (match) {
          final func = match.group(1)!;
          final angle = double.parse(match.group(2)!);
          final angleInRadians = angle * math.pi / 180.0;
          return '$func($angleInRadians)';
        },
      );
    }

    return normalized;
  }

  String _formatEvaluationResult(num evaluationResult) {
    final numericResultDouble = evaluationResult.toDouble();
    final absNumericResult = numericResultDouble.abs();

    const largeNumberThreshold = 1e10;
    const smallNumberThreshold = 1e-10;
    const displayPrecision = 8;

    if (absNumericResult >= largeNumberThreshold ||
        (absNumericResult > 0 && absNumericResult < smallNumberThreshold)) {
      var formattedResult = numericResultDouble.toStringAsExponential(
        displayPrecision - 1,
      );

      formattedResult = formattedResult.replaceAll(
        RegExp(r'0+(?=e[+-]\d+$)'),
        '',
      );

      if (formattedResult.contains('.') &&
          formattedResult.contains('e') &&
          formattedResult.split('e')[0].endsWith('.')) {
        formattedResult = formattedResult.replaceAllMapped(
          RegExp(r'\.(?=e[+-]\d+$)'),
          (match) => '',
        );
      }

      return formattedResult;
    }

    if (numericResultDouble == numericResultDouble.roundToDouble()) {
      return numericResultDouble.toInt().toString();
    }

    return _formatDecimal(numericResultDouble);
  }

  String _mapScientificInput(String buttonText) {
    switch (buttonText) {
      case 'sin':
      case 'cos':
      case 'tan':
        return '$buttonText(';
      case '√':
        return '√(';
      case '³√':
        return '³√(';
      case '10^x':
        return '10^(';
      case 'x^y':
        return '^(';
      case 'log':
        return 'log₁₀(';
      case 'ln':
        return 'ln(';
      case 'e^x':
        return 'e^(';
      case 'π':
        return 'π';
      case 'e':
        return 'e';
      case '!':
      default:
        return buttonText;
    }
  }

  int _buttonFlex(String buttonText) {
    return 1;
  }

  String _displayLabel(String buttonText) {
    if (buttonText == 'RAD/DEG_TOGGLE') {
      return _isRadians ? 'DEG' : 'RAD';
    }
    if (buttonText == 'Sci') {
      return _showScientificButtons ? '123' : 'Sci';
    }
    return buttonText;
  }

  ({
    Color gradientStart,
    Color gradientEnd,
    Color textColor,
    Color borderColor,
    double fontSize,
  })
  _buttonStyle(String buttonText, ColorScheme colorScheme) {
    var gradientStart = colorScheme.surfaceContainerHighest;
    var gradientEnd = colorScheme.surfaceContainerHigh;
    var textColor = colorScheme.onSurface;
    var borderColor = colorScheme.outlineVariant.withValues(alpha: 0.55);
    var fontSize = _showScientificButtons ? 24.0 : 36.0;

    if (buttonText == 'AC') {
      gradientStart = colorScheme.error;
      gradientEnd = colorScheme.error.withValues(alpha: 0.85);
      textColor = colorScheme.onError;
      borderColor = colorScheme.error.withValues(alpha: 0.28);
    } else if (buttonText == 'DL') {
      gradientStart = colorScheme.errorContainer;
      gradientEnd = colorScheme.errorContainer.withValues(alpha: 0.9);
      textColor = colorScheme.onErrorContainer;
      borderColor = colorScheme.error.withValues(alpha: 0.26);
    } else if (_primaryOperators.contains(buttonText)) {
      gradientStart = colorScheme.secondaryContainer;
      gradientEnd = colorScheme.secondaryContainer.withValues(alpha: 0.9);
      textColor = colorScheme.onSecondaryContainer;
      borderColor = colorScheme.secondary.withValues(alpha: 0.22);
    } else if (buttonText == '=') {
      gradientStart = colorScheme.primary;
      gradientEnd = colorScheme.primary.withValues(alpha: 0.85);
      textColor = colorScheme.onPrimary;
      borderColor = colorScheme.primary.withValues(alpha: 0.24);
    } else if (_secondaryOperators.contains(buttonText) ||
        _scientificInputButtons.contains(buttonText)) {
      gradientStart = colorScheme.secondaryContainer;
      gradientEnd = colorScheme.secondaryContainer.withValues(alpha: 0.9);
      textColor = colorScheme.onSecondaryContainer;
      borderColor = colorScheme.secondary.withValues(alpha: 0.22);
    }

    if (buttonText == 'RAD/DEG_TOGGLE') {
      fontSize = 18.0;
      gradientStart = colorScheme.primary;
      gradientEnd = colorScheme.primary.withValues(alpha: 0.86);
      textColor = colorScheme.onPrimary;
      borderColor = colorScheme.primary.withValues(alpha: 0.24);
    }

    if (buttonText == 'Sci') {
      gradientStart = colorScheme.primary;
      gradientEnd = colorScheme.primary.withValues(alpha: 0.86);
      textColor = colorScheme.onPrimary;
      borderColor = colorScheme.primary.withValues(alpha: 0.24);
    }

    return (
      gradientStart: gradientStart,
      gradientEnd: gradientEnd,
      textColor: textColor,
      borderColor: borderColor,
      fontSize: fontSize,
    );
  }

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'AC') {
        _setExpression('');
        _result = '0';
        _isResultMode = false;
        _expressionFontSize = _maxFontSize;
        _updateDisplayMetrics(animateScroll: false);
      } else if (buttonText == 'DL') {
        _prepareInputFromResultIfNeeded();

        _deleteAtCursor();
        if (_expressionController.text.isEmpty) {
          _result = '0';
          _expressionFontSize = _maxFontSize;
        }

        _isResultMode = false;
        _updateDisplayMetrics();
      } else if (buttonText == '=') {
        try {
          final rawExpression = _expressionController.text;
          if (rawExpression.trim().isEmpty) {
            return;
          }

          final finalExpression = _normalizeExpression(rawExpression);

          final p = GrammarParser();
          final exp = p.parse(finalExpression);
          final cm = ContextModel();
          cm.bindVariable(Variable('e'), Number(math.e));
          cm.bindVariable(Variable('pi'), Number(math.pi));

          final evaluationResult = exp.evaluate(EvaluationType.REAL, cm);
          _result = _formatEvaluationResult(evaluationResult);
          _isResultMode = true;
          _focusNode.unfocus();
        } catch (e) {
          _result = 'Errore';
          debugPrint('Errore di calcolo: $e');
          _isResultMode = true;
          _focusNode.unfocus();
        }
      } else if (buttonText == 'RAD/DEG_TOGGLE') {
        _isRadians = !_isRadians;
      } else if (buttonText == 'Sci') {
        _showScientificButtons = !_showScientificButtons;
      } else if (_scientificInputButtons.contains(buttonText)) {
        _prepareInputFromResultIfNeeded();
        _insertTextAtCursor(_mapScientificInput(buttonText));
      } else {
        _prepareInputFromResultIfNeeded();
        _insertTextAtCursor(buttonText);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final List<List<String>> buttonsLayout = [
      if (_showScientificButtons) ..._scientificExtraRows,
      ..._buttonsLayout,
    ];

    Widget buildExpressionField() {
      final latexExpression = _convertInputToLatex(_expressionController.text);

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
        child: Math.tex(
          latexExpression.isEmpty ? '0' : latexExpression,
          textStyle: TextStyle(
            fontSize: _expressionFontSize,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w300,
          ),
          mathStyle: MathStyle.display,
        ),
      );
    }

    Widget buildDisplayArea() {
      final radDegWidget = Align(
        alignment: Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _isRadians ? 'RAD' : 'DEG',
            style: TextStyle(fontSize: 18, color: colorScheme.primary),
          ),
        ),
      );

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          radDegWidget,
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_isResultMode) ...[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _isResultMode = false;
                        _updateDisplayMetrics(animateScroll: false);
                      });
                    },
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final latexExpression = _convertInputToLatex(
                          _expressionController.text,
                        );

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2.0,
                            vertical: 2.0,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Math.tex(
                                latexExpression.isEmpty ? '0' : latexExpression,
                                textStyle: TextStyle(
                                  fontSize: 28,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.72,
                                  ),
                                  fontWeight: FontWeight.w300,
                                ),
                                mathStyle: MathStyle.display,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                !_isResultMode
                    ? Align(
                        key: const ValueKey('input_mode'),
                        alignment: Alignment.bottomRight,
                        child: buildExpressionField(),
                      )
                    : Align(
                        key: const ValueKey('result_mode'),
                        alignment: Alignment.bottomRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Math.tex(
                            _convertResultToLatex(_result),
                            textStyle: TextStyle(
                              fontSize: _maxFontSize,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? colorScheme.surface : colorScheme.onPrimary,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(
                bottom: 24.0,
                left: 16.0,
                right: 16.0,
                top: MediaQuery.of(context).viewPadding.top + 70,
              ),
              color: Theme.of(context).brightness == Brightness.dark ? colorScheme.surface : colorScheme.onPrimary,
              child: buildDisplayArea(),
            ),
          ),
          Expanded(
            flex: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.surfaceContainerLow,
                    colorScheme.surface,
                  ],
                ),
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.28),
                    width: 1,
                  ),
                ),
              ),
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewPadding.bottom + 98,
                  left: 10.0,
                  right: 10.0,
                  top: 10.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: buttonsLayout.map((row) {
                    return Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(4, (index) {
                          if (index >= row.length) {
                            return const Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: SizedBox.shrink(),
                              ),
                            );
                          }

                          final buttonText = row[index];
                          final flex = _buttonFlex(buttonText);
                          final displayedButtonText = _displayLabel(buttonText);
                          final style = _buttonStyle(buttonText, colorScheme);

                          return _buildButton(
                            displayedButtonText,
                            buttonText,
                            style.gradientStart,
                            style.gradientEnd,
                            style.textColor,
                            borderColor: style.borderColor,
                            fontSize: style.fontSize,
                            flex: flex,
                          );
                        }),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}