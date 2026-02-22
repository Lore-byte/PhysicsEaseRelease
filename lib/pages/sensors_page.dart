// lib/pages/sensors_page.dart
import 'package:flutter/material.dart';
import 'package:physics_ease_release/theme/app_colors.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math' as math; 
import 'dart:ui'; // Necessario per FontFeature
import 'package:fl_chart/fl_chart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';

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
  final List<FlSpot> _userAccelMSpots = []; 

  final List<FlSpot> _accelXSpots = [];
  final List<FlSpot> _accelYSpots = [];
  final List<FlSpot> _accelZSpots = [];
  final List<FlSpot> _accelMSpots = []; 

  final List<FlSpot> _gyroXSpots = [];
  final List<FlSpot> _gyroYSpots = [];
  final List<FlSpot> _gyroZSpots = [];
  final List<FlSpot> _gyroMSpots = []; 

  final List<FlSpot> _magXSpots = [];
  final List<FlSpot> _magYSpots = [];
  final List<FlSpot> _magZSpots = [];
  final List<FlSpot> _magMSpots = []; 

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
    } else {
      _initSensorStreams();
    }
  }

  double _calculateMagnitude(double x, double y, double z) {
    return math.sqrt(x * x + y * y + z * z);
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

    _streamSubscriptions.add(
      userAccelerometerEventStream(
        samplingPeriod: SensorInterval.uiInterval,
      ).listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _userAccelerometerEvent = event;
            addSpot(_userAccelXSpots, event.x, _currentXIndex);
            addSpot(_userAccelYSpots, event.y, _currentXIndex);
            addSpot(_userAccelZSpots, event.z, _currentXIndex);
            addSpot(_userAccelMSpots, _calculateMagnitude(event.x, event.y, event.z), _currentXIndex);
          });
        },
        onError: (e) {
          debugPrint('Errore Accelerometro Utente: $e');
          _showErrorSnackBar('Accelerometro utente non disponibile o errore.');
        },
        cancelOnError: true,
      ),
    );

    _streamSubscriptions.add(
      accelerometerEventStream(
        samplingPeriod: SensorInterval.uiInterval,
      ).listen(
        (AccelerometerEvent event) {
          setState(() {
            _accelerometerEvent = event;
            addSpot(_accelXSpots, event.x, _currentXIndex);
            addSpot(_accelYSpots, event.y, _currentXIndex);
            addSpot(_accelZSpots, event.z, _currentXIndex);
            addSpot(_accelMSpots, _calculateMagnitude(event.x, event.y, event.z), _currentXIndex);
          });
        },
        onError: (e) {
          debugPrint('Errore Accelerometro: $e');
          _showErrorSnackBar('Accelerometro non disponibile o errore.');
        },
        cancelOnError: true,
      ),
    );

    _streamSubscriptions.add(
      gyroscopeEventStream(samplingPeriod: SensorInterval.uiInterval).listen(
        (GyroscopeEvent event) {
          setState(() {
            _gyroscopeEvent = event;
            addSpot(_gyroXSpots, event.x, _currentXIndex);
            addSpot(_gyroYSpots, event.y, _currentXIndex);
            addSpot(_gyroZSpots, event.z, _currentXIndex);
            addSpot(_gyroMSpots, _calculateMagnitude(event.x, event.y, event.z), _currentXIndex);
          });
        },
        onError: (e) {
          debugPrint('Errore Giroscopio: $e');
          _showErrorSnackBar('Giroscopio non disponibile o errore.');
        },
        cancelOnError: true,
      ),
    );

    _streamSubscriptions.add(
      magnetometerEventStream(samplingPeriod: SensorInterval.uiInterval).listen(
        (MagnetometerEvent event) {
          setState(() {
            _magnetometerEvent = event;
            addSpot(_magXSpots, event.x, _currentXIndex);
            addSpot(_magYSpots, event.y, _currentXIndex);
            addSpot(_magZSpots, event.z, _currentXIndex);
            addSpot(_magMSpots, _calculateMagnitude(event.x, event.y, event.z), _currentXIndex);
          });
        },
        onError: (e) {
          debugPrint('Errore Magnetometro: $e');
          _showErrorSnackBar('Magnetometro non disponibile o errore.');
        },
        cancelOnError: true,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
    _userAccelMSpots.clear();
    
    _accelXSpots.clear();
    _accelYSpots.clear();
    _accelZSpots.clear();
    _accelMSpots.clear();
    
    _gyroXSpots.clear();
    _gyroYSpots.clear();
    _gyroZSpots.clear();
    _gyroMSpots.clear();
    
    _magXSpots.clear();
    _magYSpots.clear();
    _magZSpots.clear();
    _magMSpots.clear();
    
    _currentXIndex = 0;
    _sensorsInitialized = false;
    super.dispose();
  }

  String _formatValue(double? value) {
    if (value == null) return 'N/A';
    // Formattazione a 3 decimali mantenendo un padding visivo se necessario, 
    // ma la FontFeature.tabularFigures farà il lavoro grosso per evitare tremolii.
    return value.toStringAsFixed(3).padLeft(7, ' ');
  }

  // --- NUOVA GRAFICA CARD MODERNA ---
  Widget _buildModernSensorCard({
    required String title,
    required IconData icon,
    required String unit,
    required Color accentColor,
    required double? xVal,
    required double? yVal,
    required double? zVal,
    required double? mVal,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        //side: BorderSide(color: accentColor.withValues(alpha: 0.2), width: 1.5),
      ),
      color: colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icona + Titolo + Unità
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accentColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          unit,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Valore Modulo centrale in evidenza
            Center(
              child: Column(
                children: [
                  Text(
                    'MODULO TOTALE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatValue(mVal),
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Griglia Componenti X Y Z
            Row(
              children: [
                Expanded(child: _buildAxisPill('X', xVal, AppColors.red, isDark)),
                const SizedBox(width: 8),
                Expanded(child: _buildAxisPill('Y', yVal, AppColors.green, isDark)),
                const SizedBox(width: 8),
                Expanded(child: _buildAxisPill('Z', zVal, AppColors.blue, isDark)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAxisPill(String label, double? value, MaterialColor baseColor, bool isDark) {
    final bgColor = isDark ? baseColor.shade900.withValues(alpha: 0.3) : baseColor.shade100.withValues(alpha: 0.5);
    final textColor = isDark ? baseColor.shade200 : baseColor.shade800;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: baseColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatValue(value),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()], // Evita il tremolio dei numeri
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // --- NUOVA GRAFICA GRAFICI MODERNI ---
  Widget _buildModernLineChart({
    required String title,
    required IconData icon,
    required String unit,
    required Color accentColor,
    required List<FlSpot> xSpots,
    required List<FlSpot> ySpots,
    required List<FlSpot> zSpots,
    required List<FlSpot> mSpots,
    required Color lineColorX,
    required Color lineColorY,
    required Color lineColorZ,
    required Color lineColorM,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    double minY = 0, maxY = 0;
    if (xSpots.isNotEmpty || ySpots.isNotEmpty || zSpots.isNotEmpty || mSpots.isNotEmpty) {
      final allValues = [
        ...xSpots.map((s) => s.y),
        ...ySpots.map((s) => s.y),
        ...zSpots.map((s) => s.y),
        ...mSpots.map((s) => s.y),
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

    // Helper per creare le linee con effetto area moderno
    LineChartBarData createBarData(List<FlSpot> spots, Color color, {double width = 2.0}) {
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: width,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        //side: BorderSide(color: accentColor.withValues(alpha: 0.2), width: 1.5),
      ),
      color: colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Header: Icona + Titolo + Unità (Uguale alle card dei valori)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accentColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          unit,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1.5,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false, // Rimuoviamo linee verticali per pulizia
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                      strokeWidth: 1,
                      dashArray: [5, 5], // Griglia tratteggiata elegante
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
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              value.toStringAsFixed(1),
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false), // Rimuoviamo il bordo rigido del grafico
                  minX: chartMinX,
                  maxX: chartMaxX,
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    createBarData(xSpots, lineColorX),
                    createBarData(ySpots, lineColorY),
                    createBarData(zSpots, lineColorZ),
                    createBarData(mSpots, lineColorM, width: 3.0), // Modulo più spesso
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModernLegendPill('X', lineColorX),
                _buildModernLegendPill('Y', lineColorY),
                _buildModernLegendPill('Z', lineColorZ),
                _buildModernLegendPill('Modulo', lineColorM),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernLegendPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
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
              top: MediaQuery.of(context).viewPadding.top + 70, // Aggiustato top padding
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                if (_showGraphs) ...[
                  _buildModernLineChart(
                    title: 'Accelerometro Lineare',
                    icon: Icons.directions_run_rounded,
                    unit: 'm/s²',
                    accentColor: AppColors.orange,
                    xSpots: _userAccelXSpots,
                    ySpots: _userAccelYSpots,
                    zSpots: _userAccelZSpots,
                    mSpots: _userAccelMSpots,
                    lineColorX: AppColors.red,
                    lineColorY: AppColors.green,
                    lineColorZ: AppColors.blue,
                    lineColorM: AppColors.purple,
                  ),
                  _buildModernLineChart(
                    title: 'Accelerometro (con gravità)',
                    icon: Icons.download_rounded,
                    unit: 'm/s²',
                    accentColor: AppColors.blue,
                    xSpots: _accelXSpots,
                    ySpots: _accelYSpots,
                    zSpots: _accelZSpots,
                    mSpots: _accelMSpots,
                    lineColorX: AppColors.red,
                    lineColorY: AppColors.green,
                    lineColorZ: AppColors.blue,
                    lineColorM: AppColors.purple,
                  ),
                  _buildModernLineChart(
                    title: 'Giroscopio',
                    icon: Icons.threed_rotation_rounded,
                    unit: 'rad/s',
                    accentColor: AppColors.green,
                    xSpots: _gyroXSpots,
                    ySpots: _gyroYSpots,
                    zSpots: _gyroZSpots,
                    mSpots: _gyroMSpots,
                    lineColorX: AppColors.red,
                    lineColorY: AppColors.green,
                    lineColorZ: AppColors.blue,
                    lineColorM: AppColors.purple,
                  ),
                  _buildModernLineChart(
                    title: 'Magnetometro',
                    icon: Icons.explore_rounded,
                    unit: 'µT',
                    accentColor: AppColors.purple,
                    xSpots: _magXSpots,
                    ySpots: _magYSpots,
                    zSpots: _magZSpots,
                    mSpots: _magMSpots,
                    lineColorX: AppColors.red,
                    lineColorY: AppColors.green,
                    lineColorZ: AppColors.blue,
                    lineColorM: AppColors.purple,
                  ),
                ] else ...[
                  _buildModernSensorCard(
                    title: 'Accelerometro Lineare',
                    icon: Icons.directions_run_rounded,
                    unit: 'm/s²',
                    accentColor: AppColors.orange,
                    xVal: _userAccelerometerEvent?.x,
                    yVal: _userAccelerometerEvent?.y,
                    zVal: _userAccelerometerEvent?.z,
                    mVal: _userAccelerometerEvent != null 
                        ? _calculateMagnitude(_userAccelerometerEvent!.x, _userAccelerometerEvent!.y, _userAccelerometerEvent!.z) 
                        : null,
                  ),
                  _buildModernSensorCard(
                    title: 'Accelerometro (con gravità)',
                    icon: Icons.download_rounded,
                    unit: 'm/s²',
                    accentColor: AppColors.blue,
                    xVal: _accelerometerEvent?.x,
                    yVal: _accelerometerEvent?.y,
                    zVal: _accelerometerEvent?.z,
                    mVal: _accelerometerEvent != null 
                        ? _calculateMagnitude(_accelerometerEvent!.x, _accelerometerEvent!.y, _accelerometerEvent!.z) 
                        : null,
                  ),
                  _buildModernSensorCard(
                    title: 'Giroscopio',
                    icon: Icons.threed_rotation_rounded,
                    unit: 'rad/s',
                    accentColor: AppColors.green,
                    xVal: _gyroscopeEvent?.x,
                    yVal: _gyroscopeEvent?.y,
                    zVal: _gyroscopeEvent?.z,
                    mVal: _gyroscopeEvent != null 
                        ? _calculateMagnitude(_gyroscopeEvent!.x, _gyroscopeEvent!.y, _gyroscopeEvent!.z) 
                        : null,
                  ),
                  _buildModernSensorCard(
                    title: 'Magnetometro',
                    icon: Icons.explore_rounded,
                    unit: 'µT',
                    accentColor: AppColors.purple,
                    xVal: _magnetometerEvent?.x,
                    yVal: _magnetometerEvent?.y,
                    zVal: _magnetometerEvent?.z,
                    mVal: _magnetometerEvent != null 
                        ? _calculateMagnitude(_magnetometerEvent!.x, _magnetometerEvent!.y, _magnetometerEvent!.z) 
                        : null,
                  ),
                ],
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Nota: La disponibilità e la precisione dei sensori dipendono dal dispositivo hardware.',
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
          Positioned(
            top: MediaQuery.of(context).viewPadding.top,
            left: 16,
            right: 16,
            child: FloatingTopBar(
              title: 'Sensori',
              leading: FloatingTopBarLeading.back,
              onBackPressed: () => Navigator.of(context).maybePop(),
              showCharts: true,
              isChartsVisible: _showGraphs,
              onChartsPressed: () {
                setState(() {
                  _showGraphs = !_showGraphs;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}