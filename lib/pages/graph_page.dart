// lib/pages/graph_page.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:math_expressions/math_expressions.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  final List<TextEditingController> _functionControllers = [];
  final List<String> _currentFunctions = [];
  final List<String> _errorMessages = [];
  final List<Color> _functionColors = [];
  final List<bool> _isPlaceholder = [];

  TextEditingController? _focusedController;

  bool _showScientificKeys = false;

  final double xMin = -10.0;
  final double xMax = 10.0;
  final double yMin = -5.0;
  final double yMax = 5.0;

  Parser p = Parser();
  ContextModel cm = ContextModel();

  final List<String> _basicKeypadKeys = [
    '7', '8', '9', '/',
    '4', '5', '6', '*',
    '1', '2', '3', '-',
    '0', '.', '^', '+',
    '(', ')', 'x', 'C',
    '⌫', 'Sci', 'Plot',
  ];

  final List<String> _scientificKeypadKeys = [
    'sin', 'cos', 'tan', 'log',
    'ln', 'exp', 'sqrt', 'abs',
    '(', ')', '^', '/',
    '*', '-', '+',
    'π', 'e', '!',
    'x', 'C', '⌫', 'Basic',
    'Plot',
  ];

  final List<Color> _predefinedColors = [
    Colors.red.shade700,
    Colors.blue.shade700,
    Colors.green.shade700,
    Colors.purple.shade700,
    Colors.orange.shade700,
    Colors.teal.shade700,
    Colors.pink.shade700,
    Colors.brown.shade700,
    Colors.indigo.shade700,
  ];

  final List<String> _exampleFunctions = [
    'sin(x)',
    'cos(x)',
    'x^2',
    'log10(x)',
    'e^x',
    'abs(x)',
    'x^3 - 2*x',
    'tan(x)',
    'sqrt(x)',
    'ln(x)',
    '2*sin(x) + cos(2*x)',
    '(x-1)^2 + 3',
  ];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _addFunctionField(initialText: _exampleFunctions[_random.nextInt(_exampleFunctions.length)], isPlaceholder: true);
    cm.bindVariable(Variable('x'), Number(0));
  }

  void _addFunctionField({String initialText = '', bool isPlaceholder = false}) {
    setState(() {
      final newController = TextEditingController(text: initialText);
      final int newIndex = _functionControllers.length;

      newController.addListener(() => _updateFunction(newIndex));
      _functionControllers.add(newController);
      _currentFunctions.add(initialText);
      _errorMessages.add('');
      _functionColors.add(_predefinedColors[newIndex % _predefinedColors.length]);
      _isPlaceholder.add(isPlaceholder);
      _focusedController = newController;
    });
  }

  void _removeFunctionField(int index) {
    setState(() {
      _functionControllers[index].dispose();
      _functionControllers.removeAt(index);
      _currentFunctions.removeAt(index);
      _errorMessages.removeAt(index);
      _functionColors.removeAt(index);
      _isPlaceholder.removeAt(index);

      if (_functionControllers.isEmpty) {
        _addFunctionField(initialText: _exampleFunctions[_random.nextInt(_exampleFunctions.length)], isPlaceholder: true);
      } else {
        if (_focusedController == null || !_functionControllers.contains(_focusedController)) {
          _focusedController = _functionControllers.first;
        }
      }
      _plotGraph();
    });
  }

  void _updateFunction(int index) {
    setState(() {
      if (_isPlaceholder[index] && _functionControllers[index].text != _currentFunctions[index]) {
        _isPlaceholder[index] = false;
      }
      _currentFunctions[index] = _functionControllers[index].text;
      _errorMessages[index] = '';
    });
  }

  String _preprocessFunction(String function) {
    String processedFunction = function
        .replaceAll('exp(', 'e^(')
        .replaceAll('pi', pi.toString())
        .replaceAll('e', e.toString())
        .replaceAll('abs(', 'abs(')
        .replaceAll('!', '!');

    processedFunction = processedFunction.replaceAllMapped(RegExp(r'log10\(([^)]*)\)'), (match) {
      return 'ln(${match.group(1)})/ln(10)';
    });

    processedFunction = processedFunction.replaceAllMapped(RegExp(r'(\d)([a-zA-Z(πe])'), (match) => '${match.group(1)}*${match.group(2)}');
    processedFunction = processedFunction.replaceAllMapped(RegExp(r'(\))([a-zAZ(πe])'), (match) => '${match.group(1)}*${match.group(2)}');
    processedFunction = processedFunction.replaceAllMapped(RegExp(r'([xπe])(sin|cos|tan|ln|exp|sqrt|abs|\()'), (match) => '${match.group(1)}*${match.group(2)}');

    return processedFunction;
  }

  double? _evaluateFunction(String function, double xValue) {
    if (function.trim().isEmpty) {
      return null;
    }
    try {
      cm.bindVariable(Variable('x'), Number(xValue));
      String processedFunction = _preprocessFunction(function);
      Expression exp = p.parse(processedFunction);
      double result = exp.evaluate(EvaluationType.REAL, cm);
      if (result.isNaN || result.isInfinite) {
        return null;
      }
      return result;
    } catch (e) {
      return null;
    }
  }

  void _plotGraph() {
    setState(() {
      bool anyFunctionHasError = false;
      for (int i = 0; i < _functionControllers.length; i++) {
        _errorMessages[i] = '';
        String functionText = _functionControllers[i].text.trim();

        if (functionText.isEmpty) {
          _errorMessages[i] = 'Inserisci una funzione.';
          continue;
        }

        try {
          String processedFunction = _preprocessFunction(functionText);
          p.parse(processedFunction);
        } catch (e) {
          String error = e.toString().replaceAll('Exception: ', '').replaceAll('ParserException: ', '');
          if (error.contains('Invalid syntax')) {
            _errorMessages[i] = 'Errore di sintassi: Controlla il formato. Usa * per la moltiplicazione esplicita (es. 2*x, x*sin(x)).';
          } else if (error.contains('Undefined variable')) {
            _errorMessages[i] = 'Variabile non definita. Assicurati di usare solo \'x\'.';
          } else if (error.contains('Undefined function')) {
            _errorMessages[i] = 'Funzione non definita o formato errato (es. sin(x), ln(x), log10(x)).';
          } else {
            _errorMessages[i] = 'Errore nel formato della funzione: $error.';
          }
          anyFunctionHasError = true;
        }
      }
      if (anyFunctionHasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correggi gli errori nelle funzioni per visualizzare tutti i grafici.')),
        );
      }
    });
  }

  void _onKeyPress(String key) {
    if (_focusedController == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona una casella di testo per inserire la funzione.')),
      );
      return;
    }

    final TextEditingController controller = _focusedController!;
    final String currentText = controller.text;
    final TextSelection selection = controller.selection;
    int start = selection.start;
    int end = selection.end;

    if (start < 0) start = 0;
    if (end < 0) end = 0;
    if (start > currentText.length) start = currentText.length;
    if (end > currentText.length) end = currentText.length;

    setState(() {
      String newText = currentText;
      TextSelection newSelection = selection;

      final int focusedIndex = _functionControllers.indexOf(controller);

      if (focusedIndex != -1 && _isPlaceholder[focusedIndex]) {
        controller.text = '';
        _isPlaceholder[focusedIndex] = false;
        start = 0;
        end = 0;
      }

      switch (key) {
        case 'C':
          newText = '';
          newSelection = TextSelection.collapsed(offset: 0);
          break;
        case '⌫':
          if (start != end) {
            newText = currentText.replaceRange(start, end, '');
            newSelection = TextSelection.collapsed(offset: start);
          } else if (start > 0) {
            newText = currentText.replaceRange(start - 1, start, '');
            newSelection = TextSelection.collapsed(offset: start - 1);
          } else {
            return;
          }
          break;
        case 'Plot':
          _plotGraph();
          return;
        case 'Sci':
          _showScientificKeys = true;
          break;
        case 'Basic':
          _showScientificKeys = false;
          break;
        case 'log':
          newText = currentText.replaceRange(start, end, 'log10(');
          newSelection = TextSelection.collapsed(offset: start + 'log10('.length);
          break;
        case 'exp':
          newText = currentText.replaceRange(start, end, 'e^(');
          newSelection = TextSelection.collapsed(offset: start + 'e^('.length);
          break;
        case 'ln':
        case 'sqrt':
        case 'sin':
        case 'cos':
        case 'tan':
        case 'abs':
          newText = currentText.replaceRange(start, end, '$key(');
          newSelection = TextSelection.collapsed(offset: start + '$key('.length);
          break;
        case 'π':
          newText = currentText.replaceRange(start, end, 'pi');
          newSelection = TextSelection.collapsed(offset: start + 'pi'.length);
          break;
        case 'e':
          newText = currentText.replaceRange(start, end, 'e');
          newSelection = TextSelection.collapsed(offset: start + 'e'.length);
          break;
        default:
          newText = currentText.replaceRange(start, end, key);
          newSelection = TextSelection.collapsed(offset: start + key.length);
          break;
      }

      controller.value = TextEditingValue(
        text: newText,
        selection: newSelection,
      );
      if (focusedIndex != -1) {
        _updateFunction(focusedIndex);
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _functionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<String> currentKeypadKeys = _showScientificKeys ? _scientificKeypadKeys : _basicKeypadKeys;

    Color getButtonColor(String key) {
      if (key == 'C' || key == '⌫') {
        return colorScheme.error;
      } else if (key == 'Plot') {
        return colorScheme.primary;
      } else if (key == 'Sci' || key == 'Basic') {
        return colorScheme.tertiary;
      } else if (key == 'x') {
        return colorScheme.errorContainer;
      }
      else if (['sin', 'cos', 'tan', 'log', 'ln', 'exp', 'sqrt', 'abs', '!', 'π', 'e'].contains(key) && _showScientificKeys) {
        return colorScheme.surfaceTint;
      }
      else if (['/', '*', '-', '+', '^', '(', ')'].contains(key)) {
        return colorScheme.secondary;
      }
      else {
        return colorScheme.primaryContainer;
      }
    }

    Color getButtonTextColor(String key) {
      if (key == 'C' || key == '⌫') {
        return colorScheme.onError;
      } else if (key == 'Plot') {
        return colorScheme.onPrimary;
      } else if (key == 'Sci' || key == 'Basic') {
        return colorScheme.onTertiary;
      } else if (key == 'x') {
        return colorScheme.onErrorContainer;
      }
      else if (['sin', 'cos', 'tan', 'log', 'ln', 'exp', 'sqrt', 'abs', '!', 'π', 'e'].contains(key) && _showScientificKeys) {
        return colorScheme.onSecondaryContainer;
      }
      else if (['/', '*', '-', '+', '^', '(', ')'].contains(key)) {
        return colorScheme.onSecondary;
      } else {
        return colorScheme.onPrimaryContainer;
      }
    }

    List<String> functionsToPlot = [];
    List<Color> colorsToPlot = [];
    for (int i = 0; i < _currentFunctions.length; i++) {
      if (_currentFunctions[i].trim().isNotEmpty && _errorMessages[i].isEmpty) {
        functionsToPlot.add(_currentFunctions[i]);
        colorsToPlot.add(_functionColors[i]);
      }
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizzatore Grafici'),
        backgroundColor: colorScheme.primaryContainer,
        iconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  ..._functionControllers.asMap().entries.map((entry) {
                    int idx = entry.key;
                    TextEditingController controller = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: controller,
                            readOnly: true,
                            onTap: () {
                              setState(() {
                                _focusedController = controller;
                                if (_isPlaceholder[idx]) {
                                  controller.clear();
                                  _isPlaceholder[idx] = false;
                                  _updateFunction(idx);
                                }
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'f${idx + 1}(x)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _focusedController == controller
                                      ? colorScheme.primary
                                      : colorScheme.outline,
                                  width: 2.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
                              ),
                              prefixIcon: Icon(Icons.show_chart, color: _functionColors[idx]),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (idx == _functionControllers.length - 1)
                                    IconButton(
                                      icon: Icon(Icons.add, color: colorScheme.primary),
                                      onPressed: () => _addFunctionField(initialText: '', isPlaceholder: false),
                                      tooltip: 'Aggiungi funzione',
                                    ),
                                  if (_functionControllers.length > 1)
                                    IconButton(
                                      icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                                      onPressed: () => _removeFunctionField(idx),
                                      tooltip: 'Rimuovi funzione',
                                    ),
                                ],
                              ),
                            ),
                            style: TextStyle(color: colorScheme.onSurface, fontSize: 20),
                            textAlign: TextAlign.end,
                          ),
                          if (_errorMessages[idx].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Card(
                                color: colorScheme.errorContainer,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    _errorMessages[idx],
                                    style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      bool hasPlotableFunctions = functionsToPlot.isNotEmpty;
                      if (hasPlotableFunctions) {
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
                          const SnackBar(content: Text('Inserisci almeno una funzione valida da visualizzare.')),
                        );
                      }
                    },
                    child: AspectRatio(
                      aspectRatio: 1.5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outline, width: 1),
                        ),
                        child: CustomPaint(
                          painter: GraphPainter(
                            functionStrings: functionsToPlot,
                            evaluateFunction: _evaluateFunction,
                            xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax,
                            axisColor: colorScheme.onSurfaceVariant,
                            lineColors: colorsToPlot,
                            gridColor: colorScheme.outlineVariant,
                            textColor: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2.2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 4,
              ),
              itemCount: currentKeypadKeys.length,
              itemBuilder: (context, index) {
                final k = currentKeypadKeys[index];
                return ElevatedButton(
                  onPressed: () => _onKeyPress(k),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getButtonColor(k),
                    foregroundColor: getButtonTextColor(k),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: Text(k),
                );
              },
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
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 2.0;

    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    double toCanvasX(double x) => (x - xMin) * size.width / (xMax - xMin);
    double toCanvasY(double y) => size.height - ((y - yMin) * size.height / (yMax - yMin));

    for (double i = xMin.ceilToDouble(); i <= xMax.floorToDouble(); i++) {
      if (i != 0) {
        canvas.drawLine(Offset(toCanvasX(i), 0), Offset(toCanvasX(i), size.height), gridPaint);
      }
    }
    for (double i = yMin.ceilToDouble(); i <= yMax.floorToDouble(); i++) {
      if (i != 0) {
        canvas.drawLine(Offset(0, toCanvasY(i)), Offset(size.width, toCanvasY(i)), gridPaint);
      }
    }

    canvas.drawLine(Offset(toCanvasX(0), 0), Offset(toCanvasX(0), size.height), axisPaint);
    canvas.drawLine(Offset(0, toCanvasY(0)), Offset(size.width, toCanvasY(0)), axisPaint);

    final textStyle = TextStyle(color: textColor, fontSize: 10);
    void drawText(Canvas canvas, String text, Offset offset) {
      final textSpan = TextSpan(text: text, style: textStyle);
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, offset);
    }

    for (double i = xMin.ceilToDouble(); i <= xMax.floorToDouble(); i += 1) {
      if (i != 0) {
        drawText(canvas, i.toInt().toString(), Offset(toCanvasX(i) - 5, toCanvasY(0) + 5));
      }
    }

    for (double i = yMin.ceilToDouble(); i <= yMax.floorToDouble(); i += 1) {
      if (i != 0) {
        drawText(canvas, i.toInt().toString(), Offset(toCanvasX(0) + 5, toCanvasY(i) - 5));
      }
    }

    for (int i = 0; i < functionStrings.length; i++) {
      final String funcString = functionStrings[i];
      final Color lineColor = lineColors[i % lineColors.length];

      final Paint linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;

      final Path path = Path();
      bool firstPoint = true;
      for (double x = xMin; x <= xMax; x += (xMax - xMin) / size.width / 2) {
        final y = evaluateFunction(funcString, x);
        if (y != null && y >= yMin && y <= yMax) {
          final px = toCanvasX(x);
          final py = toCanvasY(y);
          if (firstPoint) {
            path.moveTo(px, py);
            firstPoint = false;
          } else {
            path.lineTo(px, py);
          }
        } else {
          firstPoint = true;
        }
      }
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    GraphPainter oldPainter = oldDelegate as GraphPainter;
    if (oldPainter.functionStrings.length != functionStrings.length ||
        oldPainter.lineColors.length != lineColors.length) {
      return true;
    }
    for (int i = 0; i < functionStrings.length; i++) {
      if (oldPainter.functionStrings[i] != functionStrings[i] ||
          oldPainter.lineColors[i] != lineColors[i]) {
        return true;
      }
    }
    return false;
  }
}

class FullScreenGraphPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    String titleText = 'Grafici: ';
    List<String> validFunctions = functionStrings.where((f) => f.trim().isNotEmpty).toList();
    if (validFunctions.isNotEmpty) {
      titleText += validFunctions.map((f) => 'f(x) = $f').join(', ');
      if (titleText.length > 50) {
        titleText = 'Grafici Multipli';
      }
    } else {
      titleText = 'Grafico';
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        backgroundColor: colorScheme.primaryContainer,
        iconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
      ),
      body: SizedBox.expand(
        child: Container(
          color: colorScheme.surfaceVariant,
          child: CustomPaint(
            painter: GraphPainter(
              functionStrings: functionStrings,
              evaluateFunction: evaluateFunction,
              xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax,
              axisColor: colorScheme.onSurfaceVariant,
              lineColors: functionColors,
              gridColor: colorScheme.outlineVariant,
              textColor: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}