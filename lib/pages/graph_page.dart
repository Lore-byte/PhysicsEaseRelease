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
  final TextEditingController _functionController = TextEditingController(text: 'sin(x)');
  String _currentFunction = 'sin(x)';
  String _errorMessage = '';

  bool _showScientificKeys = false;

  // Range del grafico
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
    'asin', 'acos', 'atan',
    'π', 'e', '!',
    'Deg', 'Rad',
    'x', 'C', '⌫', 'Basic',
    'Plot',
  ];

  @override
  void initState() {
    super.initState();
    _functionController.addListener(_updateFunction);
    cm.bindVariable(Variable('x'), Number(0));
  }

  void _updateFunction() {
    setState(() {
      _currentFunction = _functionController.text;
      _errorMessage = '';
    });
  }

  String _preprocessFunction(String function) {
    String processedFunction = function
        .replaceAll('log(', 'log10(')
        .replaceAll('exp(', 'e^(')
        .replaceAll('pi', 'pi')
        .replaceAll('abs(', 'abs(')
        .replaceAll('!', '!');


    processedFunction = processedFunction.replaceAllMapped(RegExp(r'(\d)([a-zA-Z(])'), (match) => '${match.group(1)}*${match.group(2)}');

    processedFunction = processedFunction.replaceAllMapped(RegExp(r'(\))([a-zA-Z(])'), (match) => '${match.group(1)}*${match.group(2)}');

    processedFunction = processedFunction.replaceAllMapped(RegExp(r'(x)(sin|cos|tan|log10|ln|e\^|sqrt|abs|asin|acos|atan)'), (match) => '${match.group(1)}*${match.group(2)}');


    return processedFunction;
  }

  double? _evaluateFunction(String function, double xValue) {
    if (function.trim().isEmpty) {
      return null;
    }
    try {

      cm.bindVariable(Variable('x'), Number(xValue));

      String processedFunction = _preprocessFunction(function);


      processedFunction = processedFunction.replaceAll('π', pi.toString());
      processedFunction = processedFunction.replaceAll('e', e.toString());

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
      _errorMessage = '';
      if (_functionController.text.trim().isEmpty) {
        _errorMessage = 'Inserisci una funzione da plottare.';
        return;
      }
      try {
        String processedFunction = _preprocessFunction(_functionController.text);

        p.parse(processedFunction);
      } catch (e) {
        String error = e.toString().replaceAll('Exception: ', '').replaceAll('ParserException: ', '');
        if (error.contains('Invalid syntax')) {
          _errorMessage = 'Errore di sintassi: Controlla il formato. Usa * per la moltiplicazione esplicita tra termini non numerici (es. x*y, 2*x).';
        } else if (error.contains('Undefined variable')) {
          _errorMessage = 'Variabile non definita. Assicurati di usare solo \'x\'.';
        } else if (error.contains('Undefined function')) {
          _errorMessage = 'Funzione non definita o formato errato (es. log(x) o ln(x)).';
        }
        else {
          _errorMessage = 'Errore nel formato della funzione: $error. Controlla il formato.';
        }
        return;
      }
    });
  }

  void _onKeyPress(String key) {
    final TextEditingController controller = _functionController;
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
        case 'Basic': // Torna ai tasti base
          _showScientificKeys = false;
          break;
        case 'Deg':
        case 'Rad':

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Le funzioni trigonometriche usano i radianti.')),
          );
          return;
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
        case 'asin':
        case 'acos':
        case 'atan':
          newText = currentText.replaceRange(start, end, '$key(');
          newSelection = TextSelection.collapsed(offset: start + '$key('.length);
          break;
        default: // Inserisci altri tasti alla posizione del cursore
          newText = currentText.replaceRange(start, end, key);
          newSelection = TextSelection.collapsed(offset: start + key.length);
          break;
      }


      controller.value = TextEditingValue(
        text: newText,
        selection: newSelection,
      );
    });
  }


  @override
  void dispose() {
    _functionController.removeListener(_updateFunction);
    _functionController.dispose();
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
        return colorScheme.primary; // Plot button
      } else if (key == 'Sci' || key == 'Basic') {
        return colorScheme.tertiary;
      } else if (key == 'x') {
        return colorScheme.errorContainer;
      }
      else if (['/', '*', '-', '+', '^', '(', ')', 'sin', 'cos', 'tan', 'log', 'ln', 'exp', 'sqrt', 'abs', 'asin', 'acos', 'atan', '!', 'π', 'e', 'Deg', 'Rad'].contains(key)) {
        return colorScheme.secondary;
      } else {
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
        return colorScheme.onErrorContainer; // Highlight 'x'
      }
      else if (['/', '*', '-', '+', '^', '(', ')', 'sin', 'cos', 'tan', 'log', 'ln', 'exp', 'sqrt', 'abs', 'asin', 'acos', 'atan', '!', 'π', 'e', 'Deg', 'Rad'].contains(key)) {
        return colorScheme.onSecondary;
      } else {
        return colorScheme.onPrimaryContainer;
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
                  TextField(
                    controller: _functionController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Funzione f(x)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.auto_graph, color: colorScheme.primary),
                      suffixIcon: _functionController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                        onPressed: () {
                          _functionController.clear();
                          setState(() {
                            _errorMessage = '';
                            _currentFunction = '';
                          });
                        },
                      )
                          : null,
                    ),
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 20),
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      if (_currentFunction.isNotEmpty && _errorMessage.isEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => FullScreenGraphPage(
                              functionString: _currentFunction,
                              evaluateFunction: _evaluateFunction,
                              xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax,
                            ),
                          ),
                        );
                      } else if (_errorMessage.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Correggi l\'errore nella funzione prima di visualizzare a schermo intero.')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Inserisci una funzione per visualizzare il grafico a schermo intero.')),
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
                            functionString: _currentFunction,
                            evaluateFunction: _evaluateFunction,
                            xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax,
                            axisColor: colorScheme.onSurfaceVariant,
                            lineColor: colorScheme.primary,
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
          // Tastierino
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
  final String functionString;
  final Function(String, double) evaluateFunction;
  final double xMin, xMax, yMin, yMax;
  final Color axisColor;
  final Color lineColor;
  final Color gridColor;
  final Color textColor;

  GraphPainter({
    required this.functionString,
    required this.evaluateFunction,
    required this.xMin, required this.xMax,
    required this.yMin, required this.yMax,
    required this.axisColor,
    required this.lineColor,
    required this.gridColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 2.0;

    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

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


    canvas.drawLine(Offset(toCanvasX(0), 0), Offset(toCanvasX(0), size.height), axisPaint); // Asse Y
    canvas.drawLine(Offset(0, toCanvasY(0)), Offset(size.width, toCanvasY(0)), axisPaint); // Asse X


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


    final Path path = Path();
    bool firstPoint = true;
    for (double x = xMin; x <= xMax; x += (xMax - xMin) / size.width / 2) {
      final y = evaluateFunction(functionString, x);
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return (oldDelegate as GraphPainter).functionString != functionString;
  }
}

class FullScreenGraphPage extends StatelessWidget {
  final String functionString;
  final Function(String, double) evaluateFunction;
  final double xMin, xMax, yMin, yMax;

  const FullScreenGraphPage({
    super.key,
    required this.functionString,
    required this.evaluateFunction,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Grafico: f(x) = $functionString'),
        backgroundColor: colorScheme.primaryContainer,
        iconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
      ),
      body: SizedBox.expand(
        child: Container(
          color: colorScheme.surfaceVariant,
          child: CustomPaint(
            painter: GraphPainter(
              functionString: functionString,
              evaluateFunction: evaluateFunction,
              xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax,
              axisColor: colorScheme.onSurfaceVariant,
              lineColor: colorScheme.primary,
              gridColor: colorScheme.outlineVariant,
              textColor: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}