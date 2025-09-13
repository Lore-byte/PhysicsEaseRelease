import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'dart:math';

void main() {
  runApp(const VectorCalculatorApp());
}

class VectorCalculatorApp extends StatelessWidget {
  const VectorCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calcolatore Vettoriale',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const VectorCalculatorPage(),
    );
  }
}

class VectorCalculatorPage extends StatefulWidget {
  const VectorCalculatorPage({super.key});

  @override
  State<VectorCalculatorPage> createState() => _VectorCalculatorPageState();
}

class _VectorCalculatorPageState extends State<VectorCalculatorPage> {
  final TextEditingController _x1Controller = TextEditingController();
  final TextEditingController _y1Controller = TextEditingController();
  final TextEditingController _x2Controller = TextEditingController();
  final TextEditingController _y2Controller = TextEditingController();
  String _risultato = "";
  Offset? _v1;
  Offset? _v2;
  Offset? _resultVector;
  String? _selectedOperation;
  final TransformationController _transformationController = TransformationController();

  final List<String> _operations = [
    'Somma',
    'Differenza',
    'Prodotto scalare',
    'Prodotto vettoriale',
    'Modulo V1',
    'Modulo V2',
    'Angolo tra V1 e V2',
  ];

  @override
  void initState() {
    super.initState();
    _x1Controller.text = "";
    _y1Controller.text = "";
    _x2Controller.text = "";
    _y2Controller.text = "";
    _updateVectors();
  }

  @override
  void dispose() {
    _x1Controller.clear();
    _y1Controller.clear();
    _x2Controller.clear();
    _y2Controller.clear();
    super.dispose();
  }

  void _updateVectors() {
    setState(() {
      _v1 = _parseVector(_x1Controller.text, _y1Controller.text);
      _v2 = _parseVector(_x2Controller.text, _y2Controller.text);
    });
  }

  Offset? _parseVector(String x, String y) {
    final double? dx = double.tryParse(x);
    final double? dy = double.tryParse(y);
    if (dx != null && dy != null) {
      return Offset(dx, dy);
    }
    return null;
  }

  void _onOperationSelected(String? operation) {
    if (operation == null) return;
    _updateVectors();
    setState(() {
      _selectedOperation = operation;
    });

    switch (operation) {
      case 'Somma':
        _calcolaSomma();
        break;
      case 'Differenza':
        _calcolaDifferenza();
        break;
      case 'Prodotto scalare':
        _calcolaProdottoScalare();
        break;
      case 'Prodotto vettoriale':
        _calcolaProdottoVettoriale();
        break;
      case 'Modulo V1':
        _calcolaModulo(1);
        break;
      case 'Modulo V2':
        _calcolaModulo(2);
        break;
      case 'Angolo tra V1 e V2':
        _calcolaAngolo();
        break;
      default:
        _resetResult();
    }
  }

  void _calcolaSomma() {
    if (_v1 != null && _v2 != null) {
      final x = _v1!.dx + _v2!.dx;
      final y = _v1!.dy + _v2!.dy;
      setState(() {
        _resultVector = Offset(x, y);
        _risultato = "Vettore risultante: (${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})";
      });
    } else {
      _resetResult();
    }
  }

  void _calcolaDifferenza() {
    if (_v1 != null && _v2 != null) {
      final x = _v1!.dx - _v2!.dx;
      final y = _v1!.dy - _v2!.dy;
      setState(() {
        _resultVector = Offset(x, y);
        _risultato = "Vettore risultante: (${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})";
      });
    } else {
      _resetResult();
    }
  }

  void _calcolaProdottoScalare() {
    if (_v1 != null && _v2 != null) {
      final result = _v1!.dx * _v2!.dx + _v1!.dy * _v2!.dy;
      setState(() {
        _resultVector = null;
        _risultato = "Prodotto scalare: ${result.toStringAsFixed(2)}";
      });
    } else {
      _resetResult();
    }
  }

  void _calcolaProdottoVettoriale() {
    if (_v1 != null && _v2 != null) {
      final result = _v1!.dx * _v2!.dy - _v1!.dy * _v2!.dx;
      setState(() {
        _resultVector = null;
        _risultato = "Prodotto vettoriale (componente z): ${result.toStringAsFixed(2)}";
      });
    } else {
      _resetResult();
    }
  }

  void _calcolaModulo(int vectorIndex) {
    Offset? v = (vectorIndex == 1) ? _v1 : _v2;
    if (v != null) {
      final result = sqrt(pow(v.dx, 2) + pow(v.dy, 2));
      setState(() {
        _resultVector = null;
        _risultato = "Modulo V$vectorIndex: ${result.toStringAsFixed(2)}";
      });
    } else {
      _resetResult();
    }
  }

  void _calcolaAngolo() {
    if (_v1 != null && _v2 != null) {
      final dotProduct = _v1!.dx * _v2!.dx + _v1!.dy * _v2!.dy;
      final magnitude1 = sqrt(pow(_v1!.dx, 2) + pow(_v1!.dy, 2));
      final magnitude2 = sqrt(pow(_v2!.dx, 2) + pow(_v2!.dy, 2));
      if (magnitude1 != 0 && magnitude2 != 0) {
        final cosTheta = dotProduct / (magnitude1 * magnitude2);
        final angleRad = acos(cosTheta.clamp(-1.0, 1.0));
        final angleDeg = angleRad * 180 / pi;
        setState(() {
          _resultVector = null;
          _risultato = "Angolo tra i vettori: ${angleDeg.toStringAsFixed(2)}°";
        });
      } else {
        _resetResult();
      }
    } else {
      _resetResult();
    }
  }

  void _resetResult() {
    setState(() {
      _risultato = "Inserisci valori validi.";
      _resultVector = null;
    });
  }

  void _clearFields() {
    setState(() {
      _x1Controller.clear();
      _y1Controller.clear();
      _x2Controller.clear();
      _y2Controller.clear();
      _v1 = null;
      _v2 = null;
      _resultVector = null;
      _risultato = "";
      _selectedOperation = null;
    });
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calcolatore Vettoriale'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildVectorInput(
              'Vettore 1',
              _x1Controller,
              _y1Controller,
              _updateVectors,
            ),
            const SizedBox(height: 16.0),
            _buildVectorInput(
              'Vettore 2',
              _x2Controller,
              _y2Controller,
              _updateVectors,
            ),

            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _clearFields,
                    icon: const Icon(Icons.clear),
                    label: const Text("Pulisci campi"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16.0),
            _buildOperationDropdown(),
            const SizedBox(height: 16.0),
            _buildResultDisplay(),
            const SizedBox(height: 24.0),
            _buildGraphSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildVectorInput(String title, TextEditingController xController, TextEditingController yController, VoidCallback onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: xController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Componente X',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => onChanged(),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: TextField(
                controller: yController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Componente Y',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => onChanged(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOperationDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Seleziona operazione',
        border: OutlineInputBorder(),
      ),
      value: _selectedOperation,
      items: _operations.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: _onOperationSelected,
    );
  }

  Widget _buildResultDisplay() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).primaryColor),
      ),
      child: Center(
        child: Text(
          _risultato,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildGraphSection() {
    return GestureDetector(
      onTap: () {
        _showFullScreenGraph(context);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fullscreen, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Visualizza Grafico',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenGraph(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerGraph();
    });

    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Grafico'),
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
          ),
          body: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.1,
            maxScale: 4.0,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            child: SizedBox(
              width: 4000,
              height: 4000,
              child: CustomPaint(
                painter: VectorPainter(
                  v1: _v1,
                  v2: _v2,
                  resultVector: _resultVector,
                  lastOperation: _selectedOperation ?? '',
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _centerGraph,
            child: const Icon(Icons.center_focus_strong),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      },
    ));
  }

  void _centerGraph() {
    final Size size = MediaQuery.of(context).size;
    final Matrix4 matrix = Matrix4.identity();
    matrix.translate(size.width / 2, size.height / 2);
    _transformationController.value = matrix;
  }
}

class VectorPainter extends CustomPainter {
  final Offset? v1;
  final Offset? v2;
  final Offset? resultVector;
  final String lastOperation;

  VectorPainter({
    this.v1,
    this.v2,
    this.resultVector,
    required this.lastOperation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double gridStep = 40.0;

    final Paint gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1.0;

    for (double i = -2000; i <= 2000; i += gridStep) {
      canvas.drawLine(Offset(i, -2000), Offset(i, 2000), gridPaint);
      canvas.drawLine(Offset(-2000, i), Offset(2000, i), gridPaint);
    }

    final Paint axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

    canvas.drawLine(const Offset(-2000, 0), const Offset(2000, 0), axisPaint);
    canvas.drawLine(const Offset(0, -2000), const Offset(0, 2000), axisPaint);

    _drawArrowHead(canvas, const Offset(1950, 0), const Offset(2000, 0), axisPaint);
    _drawArrowHead(canvas, const Offset(0, -1950), const Offset(0, -2000), axisPaint);

    final textPainterX = TextPainter(
      text: const TextSpan(
        text: 'X',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainterX.paint(canvas, const Offset(1960, 10));

    final textPainterY = TextPainter(
      text: const TextSpan(
        text: 'Y',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainterY.paint(canvas, const Offset(10, -1990));

    _drawVector(canvas, v1, gridStep, Colors.blue, 'V1');
    _drawVector(canvas, v2, gridStep, Colors.red, 'V2');

    if (lastOperation == 'Somma' || lastOperation == 'Differenza') {
      _drawVector(canvas, resultVector, gridStep, Colors.green, 'Risultato');
    }
  }

  void _drawVector(Canvas canvas, Offset? vector, double gridStep, Color color, String label) {
    if (vector == null) return;

    final end = Offset(vector.dx * gridStep, -vector.dy * gridStep);

    final Paint vectorPaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset.zero, end, vectorPaint);

    _drawArrowHead(canvas, Offset.zero, end, vectorPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '$label\n(${vector.dx.toStringAsFixed(1)}, ${vector.dy.toStringAsFixed(1)})',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          shadows: [
            Shadow(
              blurRadius: 2.0,
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(1, 1),
            )
          ],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final textOffset = Offset(end.dx + 5, end.dy - textPainter.height / 2);
    textPainter.paint(canvas, textOffset);
  }

  void _drawArrowHead(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double arrowSize = 10.0;
    final double angle = atan2(end.dy - start.dy, end.dx - start.dx);
    final path = Path();
    path.moveTo(end.dx, end.dy);
    path.lineTo(
      end.dx - arrowSize * cos(angle - pi / 6),
      end.dy - arrowSize * sin(angle - pi / 6),
    );
    path.lineTo(
      end.dx - arrowSize * cos(angle + pi / 6),
      end.dy - arrowSize * sin(angle + pi / 6),
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant VectorPainter oldDelegate) {
    return oldDelegate.v1 != v1 ||
        oldDelegate.v2 != v2 ||
        oldDelegate.resultVector != resultVector ||
        oldDelegate.lastOperation != lastOperation;
  }
}

