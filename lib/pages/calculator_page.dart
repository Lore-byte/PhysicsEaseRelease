import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;

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
    'log',
    'ln',
    'π',
    'e',
    'e^x',
    '!',
  ];
  static const List<String> _primaryOperators = ['÷', '×', '-', '+'];
  static const List<String> _secondaryOperators = ['%', '^', '(', ')'];

  bool get _shouldShowCursor {
    if (_isResultMode || !_focusNode.hasFocus) {
      return false;
    }

    final selection = _expressionController.selection;
    if (!selection.isValid) {
      return false;
    }

    final int textLength = _expressionController.text.length;
    final bool isCaretAtRightEnd =
        selection.isCollapsed && selection.extentOffset == textLength;

    return !isCaretAtRightEnd;
  }

  @override
  void initState() {
    super.initState();
    _expressionController = TextEditingController();
    _scrollController = ScrollController();
    _focusNode = FocusNode();
    _expressionController.addListener(_onExpressionValueChanged);
    _focusNode.addListener(_onFocusChanged);

    _expressionController.selection = TextSelection.collapsed(
      offset: _expressionController.text.length,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _isResultMode = false;
    });
  }

  void _onExpressionValueChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onFocusChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _expressionController.removeListener(_onExpressionValueChanged);
    _focusNode.removeListener(_onFocusChanged);
    _expressionController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  static const List<List<String>> _buttonsLayout = [
    ['AC', 'DL', '%', '÷', 'Sci'],
    ['7', '8', '9', '×', '('],
    ['4', '5', '6', '-', ')'],
    ['1', '2', '3', '+', '^'],
    ['0', '.', '='],
  ];

  static const List<List<String>> _scientificButtonsLayout = [
    ['AC', 'DL', 'RAD/DEG_TOGGLE', 'Sci'],
    ['sin', 'cos', 'tan', 'π'],
    ['log', 'ln', '√', 'e'],
    ['!', 'e^x', '(', ')'],
    ['='],
  ];

  Widget _buildButton(
    String displayedText,
    String actionText,
    Color buttonColor,
    Color textColor, {
    double fontSize = 24.0,
    int flex = 1,
  }) {
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
            textStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: actionText.isEmpty
              ? null
              : () => _onButtonPressed(actionText),
          child: FittedBox(fit: BoxFit.scaleDown, child: Text(displayedText)),
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

  double _calculateAdaptiveFontSize(
    String text,
    double availableWidth, {
    double? minFontSize,
    double? maxFontSize,
  }) {
    final double minSize = minFontSize ?? _minFontSize;
    final double maxSize = maxFontSize ?? _maxFontSize;

    if (text.isEmpty || availableWidth <= 0) {
      return maxSize;
    }

    final double widthAtMax = _measureExpressionWidth(text, maxSize);
    if (widthAtMax <= availableWidth) {
      return maxSize;
    }

    final double scaleFactor = availableWidth / widthAtMax;
    return (maxSize * scaleFactor).clamp(minSize, maxSize);
  }

  void _updateDisplayMetrics({bool animateScroll = true}) {
    final text = _expressionController.text;
    final double maxWidth =
        MediaQuery.of(context).size.width - 32 - _displayHorizontalSafety;

    if (text.isEmpty) {
      _expressionFontSize = _maxFontSize;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
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
      if (!_scrollController.hasClients) return;

      final double maxExtent = _scrollController.position.maxScrollExtent;
      final double targetOffset = maxExtent > 0 ? maxExtent : 0;

      if ((targetOffset - _scrollController.offset).abs() < 0.5) return;

      if (animateScroll) {
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(targetOffset);
      }
    });
  }

  void _setExpression(String value, {bool focusInput = true}) {
    _expressionController.text = value;
    _expressionController.selection = TextSelection.collapsed(
      offset: value.length,
    );
    if (focusInput) {
      _focusNode.requestFocus();
    }
    _updateDisplayMetrics();
  }

  void _prepareInputFromResultIfNeeded() {
    if (!_isResultMode) return;
    final String startingValue = _result == 'Errore' ? '' : _result;
    _isResultMode = false;
    _setExpression(startingValue);
  }

  TextSelection _getValidSelection(String text) {
    final selection = _expressionController.selection;
    final bool isValid =
        selection.isValid &&
        selection.start >= 0 &&
        selection.end >= 0 &&
        selection.start <= text.length &&
        selection.end <= text.length;

    if (isValid) {
      return selection;
    }

    final fallback = TextSelection.collapsed(offset: text.length);
    _expressionController.selection = fallback;
    return fallback;
  }

  void _insertTextAtCursor(String insertText) {
    final text = _expressionController.text;
    final selection = _getValidSelection(text);

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      insertText,
    );
    _expressionController.text = newText;
    _isResultMode = false;

    final newCursorPosition = selection.start + insertText.length;
    _expressionController.selection = TextSelection.collapsed(
      offset: newCursorPosition,
    );

    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }

    _updateDisplayMetrics();
  }

  void _deleteAtCursor() {
    final text = _expressionController.text;
    final selection = _getValidSelection(text);

    if (selection.start <= 0) {
      return;
    }

    final newText = text.replaceRange(selection.start - 1, selection.start, '');
    _expressionController.text = newText;
    _expressionController.selection = TextSelection.collapsed(
      offset: selection.start - 1,
    );
  }

  String _normalizeExpression(String expression) {
    var normalized = expression;
    normalized = normalized.replaceAll('÷', '/').replaceAll('×', '*');

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
        return 'sqrt(';
      case 'log':
        return 'log(10,';
      case 'ln':
        return 'ln(';
      case 'e^x':
        return 'E^(';
      case 'π':
        return 'pi';
      case 'e':
        return 'E';
      case '!':
      default:
        return buttonText;
    }
  }

  int _buttonFlex(String buttonText) {
    if (!_showScientificButtons && buttonText == '0') {
      return 2;
    }
    return 1;
  }

  String _displayLabel(String buttonText) {
    if (buttonText == 'RAD/DEG_TOGGLE') {
      return _isRadians ? 'DEG' : 'RAD';
    }
    return buttonText;
  }

  ({Color buttonColor, Color textColor, double fontSize}) _buttonStyle(
    String buttonText,
    ColorScheme colorScheme,
  ) {
    var buttonColor = colorScheme.surfaceContainerHighest;
    var textColor = colorScheme.onSurface;
    var fontSize = 24.0;

    if (buttonText == 'AC') {
      buttonColor = colorScheme.error;
      textColor = colorScheme.onError;
    } else if (buttonText == 'DL') {
      buttonColor = colorScheme.errorContainer;
      textColor = colorScheme.onErrorContainer;
    } else if (_primaryOperators.contains(buttonText)) {
      buttonColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
    } else if (buttonText == '=') {
      buttonColor = colorScheme.tertiary;
      textColor = colorScheme.onTertiary;
    } else if (_secondaryOperators.contains(buttonText) ||
        (_showScientificButtons &&
            _scientificInputButtons.contains(buttonText))) {
      buttonColor = colorScheme.secondaryContainer;
      textColor = colorScheme.onSecondaryContainer;
    }

    if (buttonText == 'RAD/DEG_TOGGLE' || buttonText == 'Sci') {
      fontSize = 18.0;
      buttonColor = colorScheme.tertiary;
      textColor = colorScheme.onTertiary;
    }

    return (buttonColor: buttonColor, textColor: textColor, fontSize: fontSize);
  }

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'AC') {
        _setExpression('', focusInput: true);
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
        _focusNode.requestFocus();

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
          cm.bindVariable(Variable('E'), Number(math.e));
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
    final List<List<String>> buttonsLayout = _showScientificButtons
        ? _scientificButtonsLayout
        : _buttonsLayout;

    Widget buildExpressionField() {
      return TextField(
        controller: _expressionController,
        focusNode: _focusNode,
        autofocus: true,
        readOnly: true,
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {});
          });
        },
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
          hintText: '0',
        ),
        maxLines: 1,
        showCursor: _shouldShowCursor,
        cursorColor: colorScheme.primary,
        scrollController: _scrollController,
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
                if (_isResultMode)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _isResultMode = false;
                        _expressionController.selection =
                            TextSelection.collapsed(
                              offset: _expressionController.text.length,
                            );
                        _focusNode.requestFocus();
                        _updateDisplayMetrics(animateScroll: false);
                      });
                    },
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _expressionController.text.isEmpty
                                    ? '0'
                                    : _expressionController.text,
                                style: TextStyle(
                                  fontSize: 28,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.72,
                                  ),
                                  fontWeight: FontWeight.w300,
                                ),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.visible,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                !_isResultMode
                    ? Align(
                        key: const ValueKey('input_mode'),
                        alignment: Alignment.bottomRight,
                        child: buildExpressionField(),
                      )
                    : Align(
                        key: const ValueKey('result_mode'),
                        alignment: Alignment.bottomRight,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final double resultFontSize =
                                _calculateAdaptiveFontSize(
                                  _result,
                                  constraints.maxWidth,
                                );

                            return Text(
                              _result,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: resultFontSize,
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.right,
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(
                bottom: 16.0,
                left: 16.0,
                right: 16.0,
                top: MediaQuery.of(context).viewPadding.top + 70,
              ),
              color: colorScheme.surface,
              child: buildDisplayArea(),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              color: colorScheme.surface,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewPadding.bottom + 98,
                left: 8.0,
                right: 8.0,
                top: 8.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: buttonsLayout.map((row) {
                  return Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: row.map((buttonText) {
                        final flex = _buttonFlex(buttonText);
                        final displayedButtonText = _displayLabel(buttonText);
                        final style = _buttonStyle(buttonText, colorScheme);

                        return _buildButton(
                          displayedButtonText,
                          buttonText,
                          style.buttonColor,
                          style.textColor,
                          fontSize: style.fontSize,
                          flex: flex,
                        );
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
