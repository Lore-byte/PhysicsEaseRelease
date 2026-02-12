import 'package:flutter/material.dart';
import 'package:physics_ease_release/theme/app_colors.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'dart:math';
import 'package:physics_ease_release/theme/app_theme.dart';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';

void main() {
  runApp(const VectorCalculatorApp());
}

class VectorCalculatorApp extends StatelessWidget {
  const VectorCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calcolo Vettoriale',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
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
  final TextEditingController _z1Controller = TextEditingController();
  final TextEditingController _x2Controller = TextEditingController();
  final TextEditingController _y2Controller = TextEditingController();
  final TextEditingController _z2Controller = TextEditingController();

  String _risultato = "";
  dynamic _v1;
  dynamic _v2;
  dynamic _resultVector;
  String? _selectedOperation;
  final TransformationController _transformationController =
      TransformationController();
  bool _is3D = false;

  final List<String> _operations2D = [
    'Somma',
    'Differenza',
    'Prodotto scalare',
    'Prodotto vettoriale',
    'Modulo V1',
    'Modulo V2',
    'Angolo tra V1 e V2',
  ];

  final List<String> _operations3D = [
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
    _clearFields();
    _updateVectors();
  }

  @override
  void dispose() {
    _x1Controller.dispose();
    _y1Controller.dispose();
    _z1Controller.dispose();
    _x2Controller.dispose();
    _y2Controller.dispose();
    _z2Controller.dispose();
    super.dispose();
  }

  void _updateVectors() {
    setState(() {
      if (_is3D) {
        _v1 = _parseVector3(
          _x1Controller.text,
          _y1Controller.text,
          _z1Controller.text,
        );
        _v2 = _parseVector3(
          _x2Controller.text,
          _y2Controller.text,
          _z2Controller.text,
        );
      } else {
        _v1 = _parseVector2(_x1Controller.text, _y1Controller.text);
        _v2 = _parseVector2(_x2Controller.text, _y2Controller.text);
      }
    });
  }

  Offset? _parseVector2(String x, String y) {
    final double? dx = double.tryParse(x);
    final double? dy = double.tryParse(y);
    if (dx != null && dy != null) {
      return Offset(dx, dy);
    }
    return null;
  }

  Vector3? _parseVector3(String x, String y, String z) {
    final double? dx = double.tryParse(x);
    final double? dy = double.tryParse(y);
    final double? dz = double.tryParse(z);
    if (dx != null && dy != null && dz != null) {
      return Vector3(dx, dy, dz);
    }
    return null;
  }

  void _onOperationSelected(String? operation) {
    if (operation == null) return;
    _updateVectors();
    setState(() {
      _selectedOperation = operation;
    });

    if (_is3D) {
      _calcola3D(operation);
    } else {
      _calcola2D(operation);
    }
  }

  void _calcola2D(String operation) {
    if (_v1 == null || _v2 == null) {
      _resetResult();
      return;
    }

    final v1 = _v1 as Offset;
    final v2 = _v2 as Offset;

    switch (operation) {
      case 'Somma':
        _resultVector = v1 + v2;
        final resultMagnitude = _resultVector!.distance.toStringAsFixed(2);
        _risultato =
            "Vettore risultante: (${_resultVector!.dx.toStringAsFixed(2)}, ${_resultVector!.dy.toStringAsFixed(2)})\nModulo: $resultMagnitude";
        break;
      case 'Differenza':
        _resultVector = v1 - v2;
        final resultMagnitude = _resultVector!.distance.toStringAsFixed(2);
        _risultato =
            "Vettore risultante: (${_resultVector!.dx.toStringAsFixed(2)}, ${_resultVector!.dy.toStringAsFixed(2)})\nModulo: $resultMagnitude";
        break;
      case 'Prodotto scalare':
        final result = v1.dx * v2.dx + v1.dy * v2.dy;
        _resultVector = null;
        _risultato = "Prodotto scalare: ${result.toStringAsFixed(2)}";
        break;
      case 'Prodotto vettoriale':
        final result = v1.dx * v2.dy - v1.dy * v2.dx;
        _resultVector = null;
        _risultato =
            "Prodotto vettoriale (componente z): ${result.toStringAsFixed(2)}";
        break;
      case 'Modulo V1':
        final result = v1.distance;
        _resultVector = null;
        _risultato = "Modulo V1: ${result.toStringAsFixed(2)}";
        break;
      case 'Modulo V2':
        final result = v2.distance;
        _resultVector = null;
        _risultato = "Modulo V2: ${result.toStringAsFixed(2)}";
        break;
      case 'Angolo tra V1 e V2':
        final dotProduct = v1.dx * v2.dx + v1.dy * v2.dy;
        final magnitude1 = v1.distance;
        final magnitude2 = v2.distance;
        if (magnitude1 != 0 && magnitude2 != 0) {
          final cosTheta = dotProduct / (magnitude1 * magnitude2);
          final angleRad = acos(cosTheta.clamp(-1.0, 1.0));
          final angleDeg = angleRad * 180 / pi;
          _resultVector = null;
          _risultato = "Angolo tra i vettori: ${angleDeg.toStringAsFixed(2)}°";
        } else {
          _resetResult();
        }
        break;
    }
    setState(() {});
  }

  void _calcola3D(String operation) {
    if (_v1 == null || _v2 == null) {
      _resetResult();
      return;
    }

    final v1 = _v1 as Vector3;
    final v2 = _v2 as Vector3;

    switch (operation) {
      case 'Somma':
        _resultVector = v1 + v2;
        final resultMagnitude = _resultVector!.length.toStringAsFixed(2);
        _risultato =
            "Vettore risultante: (${_resultVector!.x.toStringAsFixed(2)}, ${_resultVector!.y.toStringAsFixed(2)}, ${_resultVector!.z.toStringAsFixed(2)})\nModulo: $resultMagnitude";
        break;
      case 'Differenza':
        _resultVector = v1 - v2;
        final resultMagnitude = _resultVector!.length.toStringAsFixed(2);
        _risultato =
            "Vettore risultante: (${_resultVector!.x.toStringAsFixed(2)}, ${_resultVector!.y.toStringAsFixed(2)}, ${_resultVector!.z.toStringAsFixed(2)})\nModulo: $resultMagnitude";
        break;
      case 'Prodotto scalare':
        final result = v1.dot(v2);
        _resultVector = null;
        _risultato = "Prodotto scalare: ${result.toStringAsFixed(2)}";
        break;
      case 'Prodotto vettoriale':
        _resultVector = v1.cross(v2);
        final resultMagnitude = _resultVector!.length.toStringAsFixed(2);
        _risultato =
            "Prodotto vettoriale: (${_resultVector!.x.toStringAsFixed(2)}, ${_resultVector!.y.toStringAsFixed(2)}, ${_resultVector!.z.toStringAsFixed(2)})\nModulo: $resultMagnitude";
        break;
      case 'Modulo V1':
        final result = v1.length;
        _resultVector = null;
        _risultato = "Modulo V1: ${result.toStringAsFixed(2)}";
        break;
      case 'Modulo V2':
        final result = v2.length;
        _resultVector = null;
        _risultato = "Modulo V2: ${result.toStringAsFixed(2)}";
        break;
      case 'Angolo tra V1 e V2':
        final dotProduct = v1.dot(v2);
        final magnitude1 = v1.length;
        final magnitude2 = v2.length;
        if (magnitude1 != 0 && magnitude2 != 0) {
          final cosTheta = dotProduct / (magnitude1 * magnitude2);
          final angleRad = acos(cosTheta.clamp(-1.0, 1.0));
          final angleDeg = angleRad * 180 / pi;
          _resultVector = null;
          _risultato = "Angolo tra i vettori: ${angleDeg.toStringAsFixed(2)}°";
        } else {
          _resetResult();
        }
        break;
    }
    setState(() {});
  }

  void _resetResult() {
    setState(() {
      _risultato = "Inserisci valori validi.";
      _resultVector = null;
    });
  }

  void _clearFields() {
    _x1Controller.clear();
    _y1Controller.clear();
    _z1Controller.clear();
    _x2Controller.clear();
    _y2Controller.clear();
    _z2Controller.clear();
    _v1 = null;
    _v2 = null;
    _resultVector = null;
    _risultato = "";
    _selectedOperation = null;
    _updateVectors();
  }

  @override
  Widget build(BuildContext context) {
    //final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewPadding.bottom + 98,
              left: 16.0,
              right: 16.0,
              top: MediaQuery.of(context).viewPadding.top + 70,
            ),
            child: Column(
              children: [
                _buildModeSwitch(),
                _buildVectorInput(
                  'Vettore 1',
                  _x1Controller,
                  _y1Controller,
                  _z1Controller,
                  _is3D,
                  _updateVectors,
                ),
                const SizedBox(height: 16.0),
                _buildVectorInput(
                  'Vettore 2',
                  _x2Controller,
                  _y2Controller,
                  _z2Controller,
                  _is3D,
                  _updateVectors,
                ),
                const SizedBox(height: 16.0),
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
                if (!_is3D) _buildGraphSection(),
              ],
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).viewPadding.top,
            left: 16,
            right: 16,
            child: FloatingTopBar(
              title: 'Calcolo Vettoriale',
              leading: FloatingTopBarLeading.back,
              onBackPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSwitch() {
    return SwitchListTile(
      title: const Text('Modalità 3D'),
      secondary: const Icon(Icons.threed_rotation),
      value: _is3D,
      onChanged: (bool value) {
        setState(() {
          _is3D = value;
          _clearFields();
          _selectedOperation = null;
        });
      },
    );
  }

  Widget _buildVectorInput(
    String title,
    TextEditingController xController,
    TextEditingController yController,
    TextEditingController zController,
    bool is3D,
    VoidCallback onChanged,
  ) {
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Componente Y',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => onChanged(),
              ),
            ),
            if (is3D) ...[
              const SizedBox(width: 8.0),
              Expanded(
                child: TextField(
                  controller: zController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Componente Z',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildOperationDropdown() {
    final operations = _is3D ? _operations3D : _operations2D;
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Seleziona operazione',
        border: OutlineInputBorder(),
      ),
      value: _selectedOperation,
      menuMaxHeight: 350,
      items: operations.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: _onOperationSelected,
    );
  }

  Widget _buildResultDisplay() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary),
      ),
      child: Center(
        child: Text(
          _risultato,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final colorScheme = Theme.of(context).colorScheme;
          return Scaffold(
            appBar: null,
            body: Stack(
              children: [
                InteractiveViewer(
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
                        context: context,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: MediaQuery.of(context).viewPadding.top,
                  left: 16,
                  right: 16,
                  child: FloatingTopBar(
                    title: 'Grafico',
                    leading: FloatingTopBarLeading.back,
                    onBackPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ],
            ),
            floatingActionButton: Padding(
              padding: EdgeInsets.only(bottom: 80),
              child: FloatingActionButton(
                onPressed: _centerGraph,
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                child: const Icon(Icons.center_focus_strong),
              ),
            ),
          );
        },
      ),
    );
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
  final BuildContext context;

  VectorPainter({
    this.v1,
    this.v2,
    this.resultVector,
    required this.lastOperation,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double gridStep = 40.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final axisColor = isDark ? AppColors.white : AppColors.black;
    final gridColor = isDark
        ? AppColors.white.withValues(alpha: 0.2)
        : AppColors.grey.withValues(alpha: 0.3);

    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    for (double i = -2000; i <= 2000; i += gridStep) {
      canvas.drawLine(Offset(i, -2000), Offset(i, 2000), gridPaint);
      canvas.drawLine(Offset(-2000, i), Offset(2000, i), gridPaint);
    }

    final Paint axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 2.0;

    canvas.drawLine(const Offset(-2000, 0), const Offset(2000, 0), axisPaint);
    canvas.drawLine(const Offset(0, -2000), const Offset(0, 2000), axisPaint);

    _drawArrowHead(
      canvas,
      const Offset(1950, 0),
      const Offset(2000, 0),
      axisPaint,
    );
    _drawArrowHead(
      canvas,
      const Offset(0, -1950),
      const Offset(0, -2000),
      axisPaint,
    );

    final textStyle = TextStyle(color: axisColor, fontWeight: FontWeight.bold);

    final textPainterX = TextPainter(
      text: TextSpan(text: 'X', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainterX.paint(canvas, const Offset(1960, 10));

    final textPainterY = TextPainter(
      text: TextSpan(text: 'Y', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainterY.paint(canvas, const Offset(10, -1990));

    _drawVector(canvas, v1, gridStep, AppColors.blue, 'V1');
    _drawVector(canvas, v2, gridStep, AppColors.red, 'V2');

    if (lastOperation == 'Somma' || lastOperation == 'Differenza') {
      _drawVector(canvas, resultVector, gridStep, AppColors.green, 'Risultato');
    }
  }

  void _drawVector(
    Canvas canvas,
    Offset? vector,
    double gridStep,
    Color color,
    String label,
  ) {
    if (vector == null) return;

    final end = Offset(vector.dx * gridStep, -vector.dy * gridStep);

    final Paint vectorPaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset.zero, end, vectorPaint);

    _drawArrowHead(canvas, Offset.zero, end, vectorPaint);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textPainter = TextPainter(
      text: TextSpan(
        text:
            '$label\n(${vector.dx.toStringAsFixed(1)}, ${vector.dy.toStringAsFixed(1)})',
        style: TextStyle(
          color: isDark ? AppColors.white : color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          shadows: [
            Shadow(
              blurRadius: 2.0,
              color: isDark
                  ? AppColors.black.withValues(alpha: 0.5)
                  : AppColors.black.withValues(alpha: 0.5),
              offset: const Offset(1, 1),
            ),
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
        oldDelegate.lastOperation != lastOperation ||
        oldDelegate.context != context;
  }
}
