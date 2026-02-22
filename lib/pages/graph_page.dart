import 'package:flutter/material.dart';
import 'package:physics_ease_release/theme/app_colors.dart';
import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  final List<TextEditingController> _functionControllers = [];
  final List<FocusNode> _focusNodes = [];
  final List<ScrollController> _fieldScrollControllers = [];
  final List<String> _currentFunctions = [];
  final List<String> _errorMessages = [];
  final List<Color> _functionColors = [];
  final List<bool> _isPlaceholder = [];
  final List<bool> _showCursorAtIndex = [];

  TextEditingController? _focusedController;
  final ScrollController _scrollController = ScrollController();

  final double xMin = -10.0;
  final double xMax = 10.0;
  final double yMin = -5.0;
  final double yMax = 5.0;

  GrammarParser p = GrammarParser();
  ContextModel cm = ContextModel();

  final List<Color> _predefinedColors = [
    AppColors.red.shade700,
    AppColors.blue.shade700,
    AppColors.green.shade700,
    AppColors.purple.shade700,
    AppColors.orange.shade700,
    AppColors.teal.shade700,
    AppColors.pink.shade700,
    AppColors.brown.shade700,
    AppColors.indigo.shade700,
  ];

  final List<String> _exampleFunctions = [
    'sin(x)',
    'x^(2)',
    'x^(2) - 4',
    'cos(x)',
    'e^(x)',
    '|x|',
    'log(x)',
    'ln(x)',
    '√(x)',
    'x^3 - 6x^2 + 11x - 6',
  ];
  final math.Random _random = math.Random();

  static const List<List<String>> _keypadLayout = [
    ['AC', 'DL', '√', '^', '|x|'],
    ['sin', '7', '8', '9', '÷'],
    ['cos', '4', '5', '6', '×'],
    ['tan', '1', '2', '3', '-'],
    ['ln', 'x', '0', '.', '+'],
    ['log', '(', ')', 'e', 'π'],
  ];

  @override
  void initState() {
    super.initState();
    _addFunctionField(
      initialText: _exampleFunctions[_random.nextInt(_exampleFunctions.length)],
      isPlaceholder: true,
    );
    cm.bindVariable(Variable('x'), Number(0));
  }

  @override
  void dispose() {
    for (var controller in _functionControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    for (var scrollCtrl in _fieldScrollControllers) {
      scrollCtrl.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _addFunctionField({
    String initialText = '',
    bool isPlaceholder = false,
  }) {
    setState(() {
      final newController = TextEditingController(text: initialText);
      final newFocusNode = FocusNode();
      final newScrollController = ScrollController();
      final int newIndex = _functionControllers.length;

      newController.addListener(() => _updateFunction(newIndex));
      newFocusNode.addListener(() {
        if (!mounted) return;
        if (newFocusNode.hasFocus) {
          setState(() {
            _focusedController = newController;
          });
        }
      });
      _functionControllers.add(newController);
      _focusNodes.add(newFocusNode);
      _fieldScrollControllers.add(newScrollController);
      _currentFunctions.add(initialText);
      _errorMessages.add('');
      _functionColors.add(
        _predefinedColors[newIndex % _predefinedColors.length],
      );
      _isPlaceholder.add(isPlaceholder);
      _showCursorAtIndex.add(false);
      _focusedController = newController;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _focusNodes.isEmpty) return;
      _focusNodes.last.requestFocus();
    });
  }

  void _removeFunctionField(int index) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma eliminazione'),
          content: const Text('Vuoi eliminare questa funzione?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _functionControllers[index].dispose();
        _focusNodes[index].dispose();
        _fieldScrollControllers[index].dispose();
        _functionControllers.removeAt(index);
        _focusNodes.removeAt(index);
        _fieldScrollControllers.removeAt(index);
        _currentFunctions.removeAt(index);
        _errorMessages.removeAt(index);
        _functionColors.removeAt(index);
        _isPlaceholder.removeAt(index);
        _showCursorAtIndex.removeAt(index);

        if (_functionControllers.isEmpty) {
          _addFunctionField(
            initialText:
                _exampleFunctions[_random.nextInt(_exampleFunctions.length)],
            isPlaceholder: true,
          );
        } else {
          if (_focusedController == null ||
              !_functionControllers.contains(_focusedController)) {
            _focusedController = _functionControllers.last;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _focusNodes.isEmpty) return;
              _focusNodes.last.requestFocus();
            });
          }
        }
      });
    }
  }

  void _updateFunction(int index) {
    if (!mounted) return;
    setState(() {
      if (_isPlaceholder[index] &&
          _functionControllers[index].text != _currentFunctions[index]) {
        _isPlaceholder[index] = false;
      }
      _currentFunctions[index] = _functionControllers[index].text;
      _errorMessages[index] = '';
    });
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
      RegExp(r'log\((.*?)\)'),
      (match) => 'log(10,${match.group(1)})',
    );
    normalized = normalized.replaceAll('√', 'sqrt');

    while (normalized.contains('|')) {
      int firstPipe = normalized.indexOf('|');
      int secondPipe = normalized.indexOf('|', firstPipe + 1);
      if (secondPipe != -1) {
        String content = normalized.substring(firstPipe + 1, secondPipe);
        normalized = normalized.replaceRange(
          firstPipe,
          secondPipe + 1,
          'abs($content)',
        );
      } else {
        break;
      }
    }

    normalized = normalized.replaceAllMapped(
      RegExp(r'(\d)([a-zA-Z(πe])'),
      (match) => '${match.group(1)}*${match.group(2)}',
    );
    normalized = normalized.replaceAllMapped(
      RegExp(r'(\))([a-zAZ(πe])'),
      (match) => '${match.group(1)}*${match.group(2)}',
    );
    normalized = normalized.replaceAllMapped(
      RegExp(r'([xπe])(sin|cos|tan|ln|sqrt|abs|log|\()'),
      (match) => '${match.group(1)}*${match.group(2)}',
    );

    return normalized;
  }

  double? _evaluateFunction(String function, double xValue) {
    if (function.trim().isEmpty) return null;
    try {
      cm.bindVariable(Variable('x'), Number(xValue));
      cm.bindVariable(Variable('e'), Number(math.e));
      cm.bindVariable(Variable('pi'), Number(math.pi));

      String normalized = _normalizeExpression(function);
      Expression exp = p.parse(normalized);
      double result = exp.evaluate(EvaluationType.REAL, cm);
      if (result.isNaN || result.isInfinite) return null;
      return result;
    } catch (e) {
      return null;
    }
  }

  String _convertInputToLatex(String input) {
    if (input.isEmpty) return '';
    String latex = input;

    latex = latex.replaceAll('÷', r'\div ');
    latex = latex.replaceAll('×', r'\times ');
    latex = latex.replaceAll('π', r'\pi');
    latex = latex.replaceAll('log', r'\log_{10}');
    latex = latex.replaceAll('ln', r'\ln');

    latex = latex.replaceAllMapped(RegExp(r'(sin|cos|tan)'), (match) {
      return r'\' + match.group(1)!;
    });

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
        latex = latex.replaceRange(start, end + 1, '^{$content}');
      } else {
        latex = latex.replaceFirst('^(', '^{');
        latex += '}';
      }
    }

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
        latex = latex.replaceRange(start, end + 1, r'\sqrt{(' + content + ')}');
      } else {
        latex = latex.replaceFirst('√(', r'\sqrt{(');
        latex += '}';
      }
    }
    latex = latex.replaceAll('√', r'\sqrt');

    latex = latex.replaceAll('|', '|');

    return latex;
  }

  void _onKeyPress(String key) {
    if (_focusedController == null) {
      final int focusedIndex = _focusNodes.indexWhere((node) => node.hasFocus);
      if (focusedIndex != -1) {
        _focusedController = _functionControllers[focusedIndex];
      } else if (_functionControllers.isNotEmpty) {
        _focusedController = _functionControllers.last;
        _focusNodes.last.requestFocus();
      } else {
        return;
      }
    }

    final TextEditingController controller = _focusedController!;
    final int idx = _functionControllers.indexOf(controller);

    if (idx != -1 && !_focusNodes[idx].hasFocus) {
      _focusNodes[idx].requestFocus();
    }

    if (idx != -1 && _isPlaceholder[idx]) {
      controller.clear();
      _isPlaceholder[idx] = false;
      _updateFunction(idx);
    }

    final text = controller.text;
    final selection = controller.selection;
    int start = selection.start;
    int end = selection.end;
    if (start < 0) start = text.length;
    if (end < 0) end = text.length;

    if (key == 'AC') {
      controller.clear();
      _updateFunction(idx);
      return;
    }

    if (key == 'DL') {
      if (text.isEmpty) return;
      String newText = '';
      int newOffset = 0;

      if (start != end) {
        newText = text.replaceRange(start, end, '');
        newOffset = start;
      } else if (start > 0) {
        newText = text.replaceRange(start - 1, start, '');
        newOffset = start - 1;
      } else {
        return;
      }
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newOffset),
      );
      _updateFunction(idx);
      _autoScrollToCursor(idx);
      return;
    }

    String textToInsert = key;
    int cursorMove = 0;

    switch (key) {
      case 'sin':
      case 'cos':
      case 'tan':
      case 'log':
      case 'ln':
        textToInsert = '$key(';
        break;
      case '√':
        textToInsert = '√(';
        break;
      case '^':
        textToInsert = '^(';
        break;
      case '|x|':
        textToInsert = '||';
        cursorMove = -1;
        break;
      default:
        textToInsert = key;
    }

    if (start > 0) {
      final String prevChar = text[start - 1];
      final bool isPrevDigit = RegExp(r'[0-9]').hasMatch(prevChar);
      final bool isPrevMultiplicative = RegExp(r'[0-9eπx)%]').hasMatch(prevChar);

      final bool isNextMultiplicativeStart =
          RegExp(r'^[0-9eπx(sctl√]').hasMatch(textToInsert) ||
          textToInsert.startsWith('|');

      final bool isNextDigit = RegExp(r'^[0-9]+$').hasMatch(textToInsert);

      if (isPrevMultiplicative && isNextMultiplicativeStart && !(isPrevDigit && isNextDigit)) {
      }
    }

    String newText;
    if (start >= text.length) {
      newText = text + textToInsert;
    } else {
      newText = text.replaceRange(start, end, textToInsert);
    }

    int newSelectionIndex = start + textToInsert.length + cursorMove;

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
    _updateFunction(idx);
    
    _autoScrollToCursor(idx);
  }

  void _autoScrollToCursor(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (index < _fieldScrollControllers.length && 
          _fieldScrollControllers[index].hasClients) {
        
        final controller = _fieldScrollControllers[index];
        final textController = _functionControllers[index];
        
        if (textController.selection.baseOffset >= textController.text.length) {
           controller.jumpTo(controller.position.maxScrollExtent);
        }
      }
    });
  }


  Widget _buildButtonContent(String text, double fontSize, Color color) {
    if (text == 'DL') {
      return Icon(Icons.backspace_outlined, size: fontSize + 2, color: color);
    }

    String latex = text;
    FontWeight fontWeight = FontWeight.w600;

    switch (text) {
      case '÷':
        latex = r'\div';
        break;
      case '×':
        latex = r'\times';
        break;
      case 'π':
        latex = r'\pi';
        break;
      case '√':
        latex = r'\sqrt{\square}';
        break;
      case '^':
        latex = r'\square^n';
        break;
      case '|x|':
        latex = r'|\square|';
        break;
      case 'log':
        latex = r'\log';
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
      case 'x':
        latex = 'x'; 
        fontWeight = FontWeight.normal; 
        break;
    }

    if (!['√', 'π', '÷', '×', '^', '|x|', 'log', 'ln', 'sin', 'cos', 'tan', 'x'].contains(text)) {
       return Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Math.tex(
        latex,
        textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight, 
          color: color,
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String key, ColorScheme colorScheme) {
    Color gradientStart = colorScheme.surfaceContainerHighest;
    Color gradientEnd = colorScheme.surfaceContainerHigh;
    Color textColor = colorScheme.onSurface;
    Color borderColor = colorScheme.outlineVariant.withValues(alpha: 0.55);
    double fontSize = 22.0;

    if (key == 'AC') {
      gradientStart = colorScheme.error;
      gradientEnd = colorScheme.error.withValues(alpha: 0.85);
      textColor = colorScheme.onError;
      borderColor = colorScheme.error.withValues(alpha: 0.28);
    } else if (key == 'DL') {
      gradientStart = colorScheme.errorContainer;
      gradientEnd = colorScheme.errorContainer.withValues(alpha: 0.9);
      textColor = colorScheme.onErrorContainer;
      borderColor = colorScheme.error.withValues(alpha: 0.26);
    } else if (['÷', '×', '-', '+', '=', 'x^2', '^', '|x|', '√'].contains(key)) {
      gradientStart = colorScheme.secondaryContainer;
      gradientEnd = colorScheme.secondaryContainer.withValues(alpha: 0.9);
      textColor = colorScheme.onSecondaryContainer;
      borderColor = colorScheme.secondary.withValues(alpha: 0.22);
    } else if (['sin', 'cos', 'tan', 'log', 'ln', 'e', 'π', '(', ')'].contains(key)) {
      fontSize = 18.0;
    }
    else if (key == 'x') {
      gradientStart = colorScheme.primary;
      gradientEnd = colorScheme.primary.withValues(alpha: 0.85);
      textColor = colorScheme.onPrimary;
      borderColor = colorScheme.primary.withValues(alpha: 0.24);
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _onKeyPress(key),
              overlayColor: WidgetStateProperty.all(textColor.withValues(alpha: 0.1)),
              child: Center(
                child: _buildButtonContent(key, fontSize, textColor),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    List<String> functionsToPlot = [];
    List<Color> colorsToPlot = [];
    for (int i = 0; i < _currentFunctions.length; i++) {
      String fn = _currentFunctions[i].trim();
      if (fn.isNotEmpty && _errorMessages[i].isEmpty) {
        functionsToPlot.add(fn);
        colorsToPlot.add(_functionColors[i]);
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? colorScheme.surface : colorScheme.onPrimary,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() {
            _focusedController = null;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                Expanded(
                  flex: 4,
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: MediaQuery.of(context).viewPadding.top + 70,
                            bottom: 12,
                          ),
                          child: Column(
                            children: [
                              ..._functionControllers.asMap().entries.map((entry) {
                                int idx = entry.key;
                                TextEditingController controller = entry.value;
                                bool hasFocus = _focusNodes[idx].hasFocus;
  
                                String latexPreview = _convertInputToLatex(controller.text);
  
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: _functionColors[idx].withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: _functionColors[idx], width: 2),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'f${idx + 1}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: _functionColors[idx],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: TextField(
                                              controller: controller,
                                              focusNode: _focusNodes[idx],
                                              scrollController: _fieldScrollControllers[idx],
                                              readOnly: false,
                                              keyboardType: TextInputType.none,
                                              showCursor: true,
                                              autocorrect: false,
                                              enableSuggestions: false,
                                              onTap: () {
                                                setState(() {
                                                  _focusNodes[idx].requestFocus();
                                                  _focusedController = controller;
                                                  if (_isPlaceholder[idx]) {
                                                    controller.clear();
                                                    _isPlaceholder[idx] = false;
                                                    _updateFunction(idx);
                                                  }
                                                });
                                              },
                                              decoration: InputDecoration(
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                                                ),
                                                filled: true,
                                                fillColor: hasFocus
                                                    ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                                                    : Colors.transparent,
                                                suffixIcon: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    if (idx == _functionControllers.length - 1)
                                                      IconButton(
                                                        icon: Icon(Icons.add, color: colorScheme.primary),
                                                        onPressed: () => _addFunctionField(),
                                                        tooltip: 'Nuova funzione',
                                                      ),
                                                    if (_functionControllers.length > 1)
                                                      IconButton(
                                                        icon: Icon(Icons.close, size: 20, color: colorScheme.outline),
                                                        onPressed: () => _removeFunctionField(idx),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              style: TextStyle(
                                                color: colorScheme.onSurface,
                                                fontSize: 18,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (controller.text.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8, top: 8),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Math.tex(
                                                'f_{${idx + 1}}(x) = $latexPreview',
                                                textStyle: TextStyle(
                                                  fontSize: 18,
                                                  color: colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (_errorMessages[idx].isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 52, top: 4),
                                          child: Text(
                                            _errorMessages[idx],
                                            style: TextStyle(color: colorScheme.error, fontSize: 12),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 180),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? colorScheme.surface : colorScheme.onPrimary,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colorScheme.outline),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (functionsToPlot.isNotEmpty) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (ctx) => FullScreenGraphPage(
                                                functionStrings: functionsToPlot,
                                                functionColors: colorsToPlot,
                                                evaluateFunction: _evaluateFunction,
                                                xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax,
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Inserisci una funzione valida.')),
                                          );
                                        }
                                      },
                                      child: CustomPaint(
                                        painter: GraphPainter(
                                          functionStrings: functionsToPlot,
                                          evaluateFunction: _evaluateFunction,
                                          xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax,
                                          axisColor: colorScheme.onSurfaceVariant,
                                          lineColors: colorsToPlot,
                                          gridColor: colorScheme.onSurface.withValues(alpha: 0.2),
                                          textColor: colorScheme.onSurface,
                                          hideGridAndNumbers: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.fullscreen, color: Colors.white, size: 16),
                                          SizedBox(width: 4),
                                          Text('Tocca per ingrandire', style: TextStyle(color: Colors.white, fontSize: 10)),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
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
                        bottom: MediaQuery.of(context).viewPadding.bottom + 92,
                        top: 10.0,
                        left: 10.0,
                        right: 10.0,
                      ),
                      child: Column(
                        children: _keypadLayout.map((row) {
                          return Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: row.map((key) => _buildKeypadButton(key, colorScheme)).toList(),
                            ),
                          );
                        }).toList(),
                      ),
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
                title: 'Grafici',
                leading: FloatingTopBarLeading.back,
                onBackPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenGraphPage extends StatefulWidget {
  final List<String> functionStrings;
  final Function(String, double) evaluateFunction;
  final double xMin, xMax, yMin, yMax;
  final List<Color> functionColors;

  const FullScreenGraphPage({
    super.key,
    required this.functionStrings,
    required this.evaluateFunction,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
    required this.functionColors,
  });

  @override
  State<FullScreenGraphPage> createState() => _FullScreenGraphPageState();
}

class _FullScreenGraphPageState extends State<FullScreenGraphPage> {
  late double _xMin, _xMax, _yMin, _yMax;
  final double _initialXMin = -10.0;
  final double _initialXMax = 10.0;
  final double _initialYMin = -5.0;
  final double _initialYMax = 5.0;

  @override
  void initState() {
    super.initState();
    _xMin = widget.xMin;
    _xMax = widget.xMax;
    _yMin = widget.yMin;
    _yMax = widget.yMax;
    WidgetsBinding.instance.addPostFrameCallback((_) => _setProportionalYRange());
  }

  void _setProportionalYRange() {
    if (!mounted) return;
    final Size screenSize = MediaQuery.of(context).size;
    final double aspectRatio = screenSize.height / screenSize.width;
    final double xRange = _xMax - _xMin;
    final double yRange = xRange * aspectRatio;

    final double yCenter = (_yMin + _yMax) / 2;
    setState(() {
      _yMin = yCenter - yRange / 2;
      _yMax = yCenter + yRange / 2;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      final double xRange = _xMax - _xMin;
      final double yRange = _yMax - _yMin;
      final panX = details.delta.dx / context.size!.width * xRange;
      final panY = details.delta.dy / context.size!.height * yRange;
      _xMin -= panX;
      _xMax -= panX;
      _yMin += panY;
      _yMax += panY;
    });
  }

  void _zoom(double factor) {
    setState(() {
      final w = _xMax - _xMin;
      final h = _yMax - _yMin;
      final nw = w * factor;
      final nh = h * factor;
      final dx = (w - nw) / 2;
      final dy = (h - nh) / 2;
      _xMin += dx; _xMax -= dx;
      _yMin += dy; _yMax -= dy;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    final bool isZoomedOut = (_xMax - _xMin) > 150.0;
    
    final bgColor = (Theme.of(context).brightness == Brightness.dark ? colorScheme.surface : colorScheme.onPrimary);
        
    final axisColor = colorScheme.onSurfaceVariant;
        
    final textColor = colorScheme.onSurface;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Container(
              color: bgColor,
              child: GestureDetector(
                onPanUpdate: _onPanUpdate,
                child: CustomPaint(
                  painter: GraphPainter(
                    functionStrings: widget.functionStrings,
                    evaluateFunction: widget.evaluateFunction,
                    xMin: _xMin, xMax: _xMax, yMin: _yMin, yMax: _yMax,
                    axisColor: axisColor,
                    lineColors: widget.functionColors,
                    gridColor: colorScheme.onSurface.withValues(alpha: 0.2),
                    textColor: textColor,
                    hideGridAndNumbers: isZoomedOut,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 130,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  heroTag: 'zoom_in',
                  mini: true,
                  onPressed: () => _zoom(0.8),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  heroTag: 'zoom_out',
                  mini: true,
                  onPressed: () => _zoom(1.25),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  heroTag: 'center',
                  mini: true,
                  onPressed: () {
                    setState(() {
                      _xMin = _initialXMin; _xMax = _initialXMax;
                      _yMin = _initialYMin; _yMax = _initialYMax;
                      _setProportionalYRange();
                    });
                  },
                  child: const Icon(Icons.center_focus_strong),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).viewPadding.top,
            left: 16,
            right: 16,
            child: FloatingTopBar(
              title: 'Visualizzazione Intera',
              leading: FloatingTopBarLeading.back,
              onBackPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  final List<String> functionStrings;
  final Function(String, double) evaluateFunction;
  final double xMin, xMax, yMin, yMax;
  final Color axisColor;
  final List<Color> lineColors;
  final Color gridColor;
  final Color textColor;
  final bool hideGridAndNumbers;

  GraphPainter({
    required this.functionStrings,
    required this.evaluateFunction,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
    required this.axisColor,
    required this.lineColors,
    required this.gridColor,
    required this.textColor,
    required this.hideGridAndNumbers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint axisPaint = Paint()..color = axisColor..strokeWidth = 2.0;
    final Paint gridPaint = Paint()..color = gridColor..strokeWidth = 1.0;

    double toCanvasX(double x) => (x - xMin) * size.width / (xMax - xMin);
    double toCanvasY(double y) => size.height - ((y - yMin) * size.height / (yMax - yMin));

    final zeroX = toCanvasX(0);
    final zeroY = toCanvasY(0);

    final tickStyle = TextStyle(
      color: textColor.withValues(alpha: 0.5), 
      fontSize: 10,
    );

    double xRange = xMax - xMin;
    double gridStep;
    switch (xRange) {
      case double n when n > 80:
        gridStep = 10.0;
        break;
      case double n when n > 32:
        gridStep = 5.0;
        break;
      case double n when n > 20:
        gridStep = 2.0;
        break;
      default:
        gridStep = 1.0;
    }

    if (!hideGridAndNumbers) {
      double startX = (xMin / gridStep).ceil() * gridStep;
      for (double i = startX; i <= xMax; i += gridStep) {
        if (i == 0) continue;
        final x = toCanvasX(i);
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
      
      double startY = (yMin / gridStep).ceil() * gridStep;
      for (double i = startY; i <= yMax; i += gridStep) {
        if (i == 0) continue;
        final y = toCanvasY(i);
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }

    if (zeroX >= 0 && zeroX <= size.width) {
      canvas.drawLine(Offset(zeroX, 0), Offset(zeroX, size.height), axisPaint);
    }
    if (zeroY >= 0 && zeroY <= size.height) {
      canvas.drawLine(Offset(0, zeroY), Offset(size.width, zeroY), axisPaint);
    }

    if (!hideGridAndNumbers) {
      double startX = (xMin / gridStep).ceil() * gridStep;
      for (double i = startX; i <= xMax; i += gridStep) {
        if (i == 0) continue;
        _drawText(canvas, i.toInt().toString(), Offset(toCanvasX(i) - 5, zeroY + 5), tickStyle);
      }

      double startY = (yMin / gridStep).ceil() * gridStep;
      for (double i = startY; i <= yMax; i += gridStep) {
        if (i == 0) continue;
        _drawText(canvas, i.toInt().toString(), Offset(zeroX + 5, toCanvasY(i) - 10), tickStyle);
      }

      _drawText(canvas, "0", Offset(zeroX + 5, zeroY + 5), tickStyle);
    }

    for (int i = 0; i < functionStrings.length; i++) {
      final paint = Paint()
        ..color = lineColors[i % lineColors.length]
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      bool isFirst = true;
      final step = (xMax - xMin) / size.width;

      for (double x = xMin; x <= xMax; x += step) {
        final y = evaluateFunction(functionStrings[i], x);
        if (y != null && y.isFinite) {
          final cx = toCanvasX(x);
          final cy = toCanvasY(y);

          if (cy >= -size.height && cy <= size.height * 2) {
            if (isFirst) {
              path.moveTo(cx, cy);
              isFirst = false;
            } else {
              path.lineTo(cx, cy);
            }
          } else {
            isFirst = true;
          }
        } else {
          isFirst = true;
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) => true;
}