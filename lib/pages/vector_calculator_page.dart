import 'package:flutter/material.dart';
import 'package:physics_ease_release/theme/app_colors.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'dart:math';
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

  String _risultato = "Inserisci valori validi.";
  dynamic _v1;
  dynamic _v2;
  dynamic _resultVector;
  String? _selectedOperation;
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
    setState(() {
      _selectedOperation = operation;
    });
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

  void _solveVectorOperation() {
    _updateVectors();

    if (_selectedOperation == null) {
      setState(() {
        _risultato = "Seleziona un'operazione per procedere.";
      });
      return;
    }

    if (_v1 == null || _v2 == null) {
      _resetResult();
      return;
    }

    if (_is3D) {
      _calcola3D(_selectedOperation!);
    } else {
      _calcola2D(_selectedOperation!);
    }
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
    _risultato = "Inserisci valori validi.";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
                const SizedBox(height: 32.0),
                _buildOperationDropdown(),
                const SizedBox(height: 32.0),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _solveVectorOperation,
                        icon: const Icon(Icons.check),
                        label: const Text('Risolvi'),
                        style: ElevatedButton.styleFrom(
                          iconSize: 26,
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _clearFields,
                        icon: const Icon(Icons.delete_sweep_outlined),
                        label: const Text('Azzera'),
                        style: ElevatedButton.styleFrom(
                          iconSize: 26,
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                decoration: InputDecoration(
                  labelText: 'Componente X',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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
                decoration: InputDecoration(
                  labelText: 'Componente Y',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
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
                  decoration: InputDecoration(
                    labelText: 'Componente Z',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: DropdownButtonFormField<String>(
        isExpanded: false,

        borderRadius: BorderRadius.circular(28),

        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelText: 'Seleziona operazione',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),

        value: _selectedOperation,
        menuMaxHeight: 360,

        alignment: AlignmentDirectional.centerStart,

        items: operations.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(value),
            ),
          );
        }).toList(),
        onChanged: _onOperationSelected,
      ),
    );
  }

  Widget _buildResultDisplay() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fullscreen, color: Theme.of(context).colorScheme.onSurface),
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return FullScreenVectorGraphPage(
            v1: _v1,
            v2: _v2,
            resultVector: _resultVector,
            lastOperation: _selectedOperation ?? '',
          );
        },
      ),
    );
  }
}

class FullScreenVectorGraphPage extends StatefulWidget {
  final Offset? v1;
  final Offset? v2;
  final Offset? resultVector;
  final String lastOperation;

  const FullScreenVectorGraphPage({
    super.key,
    required this.v1,
    required this.v2,
    required this.resultVector,
    required this.lastOperation,
  });

  @override
  State<FullScreenVectorGraphPage> createState() => _FullScreenVectorGraphPageState();
}

class _FullScreenVectorGraphPageState extends State<FullScreenVectorGraphPage> {
  late double _xMin, _xMax, _yMin, _yMax;

  @override
  void initState() {
    super.initState();
    _adjustInitialRange();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setProportionalYRange());
  }

  void _adjustInitialRange() {
    double maxCoord = 10.0;
    void checkOffset(Offset? v) {
      if (v != null) {
        if (v.dx.abs() > maxCoord) maxCoord = v.dx.abs();
        if (v.dy.abs() > maxCoord) maxCoord = v.dy.abs();
      }
    }
    checkOffset(widget.v1);
    checkOffset(widget.v2);
    checkOffset(widget.resultVector);
    
    maxCoord += 5.0; // padding extra
    _xMin = -maxCoord;
    _xMax = maxCoord;
    _yMin = -maxCoord;
    _yMax = maxCoord;
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
    
    final bgColor = isZoomedOut 
        ? Colors.white 
        : (Theme.of(context).brightness == Brightness.dark ? colorScheme.surface : colorScheme.onPrimary);
        
    final axisColor = isZoomedOut 
        ? AppColors.black87 
        : colorScheme.onSurfaceVariant;
        
    final textColor = isZoomedOut 
        ? AppColors.black87 
        : colorScheme.onSurface;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Container(
              color: bgColor,
              child: GestureDetector(
                onPanUpdate: _onPanUpdate,
                child: CustomPaint(
                  painter: VectorPainter(
                    v1: widget.v1,
                    v2: widget.v2,
                    resultVector: widget.resultVector,
                    lastOperation: widget.lastOperation,
                    xMin: _xMin,
                    xMax: _xMax,
                    yMin: _yMin,
                    yMax: _yMax,
                    axisColor: axisColor,
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
                  heroTag: 'zoom_in_vec',
                  mini: true,
                  onPressed: () => _zoom(0.8),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  heroTag: 'zoom_out_vec',
                  mini: true,
                  onPressed: () => _zoom(1.25),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  heroTag: 'center_vec',
                  mini: true,
                  onPressed: () {
                    setState(() {
                      _adjustInitialRange();
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
              title: 'Grafico Vettoriale',
              leading: FloatingTopBarLeading.back,
              onBackPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }
}

class VectorPainter extends CustomPainter {
  final Offset? v1;
  final Offset? v2;
  final Offset? resultVector;
  final String lastOperation;
  
  final double xMin, xMax, yMin, yMax;
  final Color axisColor;
  final Color gridColor;
  final Color textColor;
  final bool hideGridAndNumbers;

  VectorPainter({
    required this.v1,
    required this.v2,
    required this.resultVector,
    required this.lastOperation,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
    required this.axisColor,
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
      case double n when n > 300:
        gridStep = 50.0;
        break;
      case double n when n > 150:
        gridStep = 20.0;
        break;
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

    void drawVector(Offset? vector, Color color, String label) {
      if (vector == null) return;
      final endX = toCanvasX(vector.dx);
      final endY = toCanvasY(vector.dy);
      
      final Paint vectorPaint = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(zeroX, zeroY), Offset(endX, endY), vectorPaint);
      _drawArrowHead(canvas, Offset(zeroX, zeroY), Offset(endX, endY), vectorPaint);

      _drawText(
        canvas, 
        '$label (${vector.dx.toStringAsFixed(1)}, ${vector.dy.toStringAsFixed(1)})', 
        Offset(endX + 8, endY - 10),
        TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)
      );
    }

    drawVector(v1, AppColors.blue, 'V1');
    drawVector(v2, AppColors.red, 'V2');

    if (lastOperation == 'Somma' || lastOperation == 'Differenza') {
      drawVector(resultVector, AppColors.green, 'Risultato');
    }
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, position);
  }

  void _drawArrowHead(Canvas canvas, Offset start, Offset end, Paint paint) {
    final double arrowSize = 10.0;
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
  bool shouldRepaint(covariant VectorPainter oldDelegate) => true;
}