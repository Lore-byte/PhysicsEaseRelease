// lib/pages/sensor_tool_page.dart
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:permission_handler/permission_handler.dart';

class SensorToolPage extends StatefulWidget {
  const SensorToolPage({super.key});

  @override
  State<SensorToolPage> createState() => _SensorToolPageState();
}

class _SensorToolPageState extends State<SensorToolPage> {

  UserAccelerometerEvent? _userAccelerometerEvent;
  AccelerometerEvent? _accelerometerEvent;
  GyroscopeEvent? _gyroscopeEvent;
  MagnetometerEvent? _magnetometerEvent;


  final List<FlSpot> _userAccelXSpots = [];
  final List<FlSpot> _userAccelYSpots = [];
  final List<FlSpot> _userAccelZSpots = [];

  final List<FlSpot> _accelXSpots = [];
  final List<FlSpot> _accelYSpots = [];
  final List<FlSpot> _accelZSpots = [];

  final List<FlSpot> _gyroXSpots = [];
  final List<FlSpot> _gyroYSpots = [];
  final List<FlSpot> _gyroZSpots = [];

  final List<FlSpot> _magXSpots = [];
  final List<FlSpot> _magYSpots = [];
  final List<FlSpot> _magZSpots = [];


  int _currentXIndex = 0;

  Timer? _xIndexTimer;

  static const int _maxDataPoints = 100;

  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  bool _showGraphs = false;

  bool _sensorsInitialized = false;

  @override
  void initState() {
    super.initState();

    _requestSensorPermissions();
  }


  Future<void> _requestSensorPermissions() async {

    var status = await Permission.activityRecognition.status;

    if (status.isDenied) {

      status = await Permission.activityRecognition.request();
    }

    if (status.isGranted || status.isLimited) {

      _initSensorStreams();
    } else if (status.isPermanentlyDenied) {

      _showErrorSnackBar(
          'Permesso di rilevamento attività fisica negato permanentemente. Abilitalo dalle impostazioni dell\'app.'
      );

      if (await openAppSettings()) {

        debugPrint('Impostazioni app aperte.');
      }
      _initSensorStreams();
    } else {

      _showErrorSnackBar(
          'Impossibile ottenere il permesso di rilevamento attività fisica. Verifica le impostazioni.'
      );
      _initSensorStreams();
    }
  }


  void _initSensorStreams() {
    if (_sensorsInitialized) return;

    _sensorsInitialized = true;


    void addSpot(List<FlSpot> spots, double value, int xIndex) {
      if (spots.length >= _maxDataPoints) {
        spots.removeAt(0);
      }
      spots.add(FlSpot(xIndex.toDouble(), value));
    }

    _xIndexTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _currentXIndex++;
        });
      }
    });


    _streamSubscriptions.add(userAccelerometerEventStream(samplingPeriod: SensorInterval.uiInterval).listen(
          (UserAccelerometerEvent event) {
        setState(() {
          _userAccelerometerEvent = event;
          addSpot(_userAccelXSpots, event.x, _currentXIndex);
          addSpot(_userAccelYSpots, event.y, _currentXIndex);
          addSpot(_userAccelZSpots, event.z, _currentXIndex);
        });
      },
      onError: (e) {
        debugPrint('Errore Accelerometro Utente: $e');
        _showErrorSnackBar('Accelerometro utente non disponibile o errore.');
      },
      cancelOnError: true,
    ));


    _streamSubscriptions.add(accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval).listen(
          (AccelerometerEvent event) {
        setState(() {
          _accelerometerEvent = event;
          addSpot(_accelXSpots, event.x, _currentXIndex);
          addSpot(_accelYSpots, event.y, _currentXIndex);
          addSpot(_accelZSpots, event.z, _currentXIndex);
        });
      },
      onError: (e) {
        debugPrint('Errore Accelerometro: $e');
        _showErrorSnackBar('Accelerometro non disponibile o errore.');
      },
      cancelOnError: true,
    ));


    _streamSubscriptions.add(gyroscopeEventStream(samplingPeriod: SensorInterval.uiInterval).listen(
          (GyroscopeEvent event) {
        setState(() {
          _gyroscopeEvent = event;
          addSpot(_gyroXSpots, event.x, _currentXIndex);
          addSpot(_gyroYSpots, event.y, _currentXIndex);
          addSpot(_gyroZSpots, event.z, _currentXIndex);
        });
      },
      onError: (e) {
        debugPrint('Errore Giroscopio: $e');
        _showErrorSnackBar('Giroscopio non disponibile o errore.');
      },
      cancelOnError: true,
    ));


    _streamSubscriptions.add(magnetometerEventStream(samplingPeriod: SensorInterval.uiInterval).listen(
          (MagnetometerEvent event) {
        setState(() {
          _magnetometerEvent = event;
          addSpot(_magXSpots, event.x, _currentXIndex);
          addSpot(_magYSpots, event.y, _currentXIndex);
          addSpot(_magZSpots, event.z, _currentXIndex);
        });
      },
      onError: (e) {
        debugPrint('Errore Magnetometro: $e');
        _showErrorSnackBar('Magnetometro non disponibile o errore.');
      },
      cancelOnError: true,
    ));
  }


  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {

    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _xIndexTimer?.cancel();
    _userAccelXSpots.clear();
    _userAccelYSpots.clear();
    _userAccelZSpots.clear();
    _accelXSpots.clear();
    _accelYSpots.clear();
    _accelZSpots.clear();
    _gyroXSpots.clear();
    _gyroYSpots.clear();
    _gyroZSpots.clear();
    _magXSpots.clear();
    _magYSpots.clear();
    _magZSpots.clear();
    _currentXIndex = 0;
    _sensorsInitialized = false;
    super.dispose();
  }


  String _formatValue(double? value) {
    if (value == null) return 'N/A';
    return value.toStringAsFixed(3);
  }


  Widget _buildSensorCard({
    required Color cardColor,
    required Color textColor,
    required String title,
    required String xValue,
    required String yValue,
    required String zValue,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: cardColor,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 15),
            _buildDataRow('X:', xValue, textColor),
            _buildDataRow('Y:', yValue, textColor),
            _buildDataRow('Z:', zValue, textColor),
          ],
        ),
      ),
    );
  }


  Widget _buildDataRow(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 18, color: textColor.withOpacity(0.8)),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart({
    required String title,
    required List<FlSpot> xSpots,
    required List<FlSpot> ySpots,
    required List<FlSpot> zSpots,
    required Color lineColorX,
    required Color lineColorY,
    required Color lineColorZ,
    required Color textColor,
    required Color gridColor,
    String? unit,
  }) {

    double minY = 0, maxY = 0;
    if (xSpots.isNotEmpty || ySpots.isNotEmpty || zSpots.isNotEmpty) {
      final allValues = [
        ...xSpots.map((s) => s.y),
        ...ySpots.map((s) => s.y),
        ...zSpots.map((s) => s.y),
      ];
      minY = allValues.reduce((curr, next) => curr < next ? curr : next);
      maxY = allValues.reduce((curr, next) => curr > next ? curr : next);

      final padding = (maxY - minY).abs() * 0.1;
      minY -= padding;
      maxY += padding;

      if (maxY == minY) {
        maxY = minY + 1.0;
        minY = minY - 1.0;
      }
    } else {
      minY = -1.0;
      maxY = 1.0;
    }

    double chartMinX = 0;
    double chartMaxX = _maxDataPoints.toDouble();

    if (xSpots.isNotEmpty) {
      chartMinX = xSpots.first.x;
      chartMaxX = xSpots.last.x + 1.0;
    }

    double intervalX = (_maxDataPoints / 5).floorToDouble();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title ${unit != null ? '($unit)' : ''}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 15),
            AspectRatio(
              aspectRatio: 1.7,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: gridColor.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: gridColor.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: intervalX,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(value.toInt().toString(), style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(value.toStringAsFixed(1), style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12)),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: gridColor.withOpacity(0.3), width: 1),
                  ),
                  minX: chartMinX,
                  maxX: chartMaxX,
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: xSpots,
                      isCurved: true,
                      color: lineColorX,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: ySpots,
                      isCurved: true,
                      color: lineColorY,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: zSpots,
                      isCurved: true,
                      color: lineColorZ,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('X', lineColorX),
                _buildLegendItem('Y', lineColorY),
                _buildLegendItem('Z', lineColorZ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Strumento Sensori'),
        backgroundColor: colorScheme.primaryContainer,
        iconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            if (_showGraphs) ...[
              _buildLineChart(
                title: 'Accelerometro Lineare',
                xSpots: _userAccelXSpots,
                ySpots: _userAccelYSpots,
                zSpots: _userAccelZSpots,
                lineColorX: Colors.redAccent,
                lineColorY: Colors.greenAccent,
                lineColorZ: Colors.blueAccent,
                textColor: colorScheme.onSurface,
                gridColor: colorScheme.onSurface,
                unit: 'm/s²',
              ),
              _buildLineChart(
                title: 'Accelerometro (con gravità)',
                xSpots: _accelXSpots,
                ySpots: _accelYSpots,
                zSpots: _accelZSpots,
                lineColorX: Colors.red,
                lineColorY: Colors.green,
                lineColorZ: Colors.blue,
                textColor: colorScheme.onSurface,
                gridColor: colorScheme.onSurface,
                unit: 'm/s²',
              ),
              _buildLineChart(
                title: 'Giroscopio',
                xSpots: _gyroXSpots,
                ySpots: _gyroYSpots,
                zSpots: _gyroZSpots,
                lineColorX: Colors.purpleAccent,
                lineColorY: Colors.orangeAccent,
                lineColorZ: Colors.cyanAccent,
                textColor: colorScheme.onSurface,
                gridColor: colorScheme.onSurface,
                unit: 'rad/s',
              ),
              _buildLineChart(
                title: 'Magnetometro',
                xSpots: _magXSpots,
                ySpots: _magYSpots,
                zSpots: _magZSpots,
                lineColorX: Colors.teal,
                lineColorY: Colors.amber,
                lineColorZ: Colors.indigo,
                textColor: colorScheme.onSurface,
                gridColor: colorScheme.onSurface,
                unit: 'µT',
              ),
            ] else ...[
              _buildSensorCard(
                cardColor: colorScheme.tertiaryContainer,
                textColor: colorScheme.onTertiaryContainer,
                title: 'Accelerometro Lineare',
                xValue: _formatValue(_userAccelerometerEvent?.x),
                yValue: _formatValue(_userAccelerometerEvent?.y),
                zValue: _formatValue(_userAccelerometerEvent?.z),
              ),
              _buildSensorCard(
                cardColor: colorScheme.primaryContainer,
                textColor: colorScheme.onPrimaryContainer,
                title: 'Accelerometro (con gravità)',
                xValue: _formatValue(_accelerometerEvent?.x),
                yValue: _formatValue(_accelerometerEvent?.y),
                zValue: _formatValue(_accelerometerEvent?.z),
              ),
              _buildSensorCard(
                cardColor: colorScheme.secondaryContainer,
                textColor: colorScheme.onSecondaryContainer,
                title: 'Giroscopio (rad/s)',
                xValue: _formatValue(_gyroscopeEvent?.x),
                yValue: _formatValue(_gyroscopeEvent?.y),
                zValue: _formatValue(_gyroscopeEvent?.z),
              ),
              _buildSensorCard(
                cardColor: colorScheme.errorContainer,
                textColor: colorScheme.onErrorContainer,
                title: 'Magnetometro (µT)',
                xValue: _formatValue(_magnetometerEvent?.x),
                yValue: _formatValue(_magnetometerEvent?.y),
                zValue: _formatValue(_magnetometerEvent?.z),
              ),
            ],
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Nota: Potrebbe essere necessario concedere il permesso "Riconoscimento attività fisica" dalle impostazioni dell\'app se i dati non vengono visualizzati.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showGraphs = !_showGraphs;
          });
        },
        backgroundColor: colorScheme.tertiary,
        foregroundColor: colorScheme.onTertiary,
        child: Icon(_showGraphs ? Icons.list : Icons.auto_graph),
      ),
    );
  }
}
