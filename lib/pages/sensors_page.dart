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
  // Variabili per i dati dei sensori in tempo reale
  UserAccelerometerEvent? _userAccelerometerEvent;
  AccelerometerEvent? _accelerometerEvent;
  GyroscopeEvent? _gyroscopeEvent;
  MagnetometerEvent? _magnetometerEvent;

  // Liste per i dati storici dei grafici
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

  // Variabile per contare i punti dati sull'asse X dei grafici in modo globale
  int _currentXIndex = 0;
  // Timer per incrementare _currentXIndex uniformemente
  Timer? _xIndexTimer;
  // Limite massimo di punti da mantenere nel grafico per performance
  static const int _maxDataPoints = 100; // 100 punti visibili sul grafico

  // Lista delle sottoscrizioni agli stream dei sensori
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  // Variabile per controllare la vista (Cards o Grafici)
  bool _showGraphs = false;
  // Variabile per indicare se i sensori sono stati inizializzati con successo
  bool _sensorsInitialized = false;

  @override
  void initState() {
    super.initState();
    // Inizializza l'ascolto dei sensori dopo aver richiesto i permessi
    _requestSensorPermissions();
  }

  /// Richiede i permessi necessari per i sensori.
  /// La permissione ACTIVITY_RECOGNITION è la più comune per i sensori di movimento.
  Future<void> _requestSensorPermissions() async {
    // Controlla e richiede il permesso per il riconoscimento attività fisica
    var status = await Permission.activityRecognition.status;

    if (status.isDenied) {
      // Se il permesso è negato, richiederlo all'utente
      status = await Permission.activityRecognition.request();
    }

    if (status.isGranted || status.isLimited) { // isLimited è per iOS 14+
      // Permesso concesso o limitato (sufficiente per procedere)
      _initSensorStreams();
    } else if (status.isPermanentlyDenied) {
      // Permesso negato permanentemente, indirizza l'utente alle impostazioni dell'app
      _showErrorSnackBar(
          'Permesso di rilevamento attività fisica negato permanentemente. Abilitalo dalle impostazioni dell\'app.'
      );
      // Offri all'utente di aprire le impostazioni dell'app
      if (await openAppSettings()) {
        // App impostazioni aperte, l'utente potrebbe tornare e riprovare
        debugPrint('Impostazioni app aperte.');
      }
      _initSensorStreams(); // Prova comunque a inizializzare, alcuni sensori potrebbero funzionare
    } else {
      // Altri stati (ristretto, ecc.)
      _showErrorSnackBar(
          'Impossibile ottenere il permesso di rilevamento attività fisica. Verifica le impostazioni.'
      );
      _initSensorStreams(); // Prova comunque a inizializzare
    }
  }

  /// Inizializza l'ascolto dei dati dai sensori e popola le liste per i grafici.
  /// Questa funzione viene chiamata DOPO la gestione dei permessi.
  void _initSensorStreams() {
    if (_sensorsInitialized) return; // Evita di inizializzare più volte

    _sensorsInitialized = true; // Marca i sensori come inizializzati

    // Funzione helper per aggiungere un punto ai dati del grafico e gestire il limite
    void addSpot(List<FlSpot> spots, double value, int xIndex) {
      if (spots.length >= _maxDataPoints) {
        spots.removeAt(0); // Rimuovi il punto più vecchio
      }
      spots.add(FlSpot(xIndex.toDouble(), value));
    }

    // Timer per incrementare l'indice X globalmente ogni 100ms
    _xIndexTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) { // Assicurati che il widget sia montato prima di chiamare setState
        setState(() {
          _currentXIndex++;
        });
      }
    });

    // Sottoscrizione all'accelerometro lineare (senza gravità)
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

    // Sottoscrizione all'accelerometro (con gravità)
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

    // Sottoscrizione al giroscopio
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

    // Sottoscrizione al magnetometro
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

  /// Mostra una Snackbar per gli errori.
  void _showErrorSnackBar(String message) {
    if (mounted) { // Controlla se il widget è ancora montato prima di mostrare la Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    // Annulla tutte le sottoscrizioni e il timer, poi resetta i dati quando il widget viene eliminato
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _xIndexTimer?.cancel(); // Annulla il timer
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
    _currentXIndex = 0; // Resetta l'indice X
    _sensorsInitialized = false; // Resetta lo stato di inizializzazione
    super.dispose();
  }

  /// Funzione di utilità per formattare i valori float in stringhe.
  String _formatValue(double? value) {
    if (value == null) return 'N/A';
    return value.toStringAsFixed(3); // Formatta a 3 cifre decimali
  }

  /// Costruisce un widget Card per visualizzare i dati di un singolo sensore.
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

  /// Costruisce una riga per un singolo valore di dato (es. "X: 1.234").
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

  /// Costruisce un widget LineChart per un sensore specifico.
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
    // Determina i valori min/max per l'asse Y (adattivo)
    double minY = 0, maxY = 0;
    if (xSpots.isNotEmpty || ySpots.isNotEmpty || zSpots.isNotEmpty) {
      final allValues = [
        ...xSpots.map((s) => s.y),
        ...ySpots.map((s) => s.y),
        ...zSpots.map((s) => s.y),
      ];
      minY = allValues.reduce((curr, next) => curr < next ? curr : next);
      maxY = allValues.reduce((curr, next) => curr > next ? curr : next);

      // Aggiungi un piccolo padding ai limiti Y
      final padding = (maxY - minY).abs() * 0.1;
      minY -= padding;
      maxY += padding;

      // Gestisci il caso in cui maxY e minY sono uguali (es. dati costanti a 0)
      if (maxY == minY) {
        maxY = minY + 1.0;
        minY = minY - 1.0;
      }
    } else {
      minY = -1.0;
      maxY = 1.0;
    }

    // Calcolo dinamico di minX e maxX per la finestra scorrevole
    // minX è il valore X del primo punto visibile nella lista
    // maxX è il valore X dell'ultimo punto visibile nella lista, più un piccolo buffer
    double chartMinX = 0;
    double chartMaxX = _maxDataPoints.toDouble(); // Default per i primi _maxDataPoints

    if (xSpots.isNotEmpty) {
      chartMinX = xSpots.first.x;
      chartMaxX = xSpots.last.x + 1.0; // Aggiungi un piccolo buffer per evitare che l'ultima linea sia tagliata
    }


    // Calcola l'intervallo per i tick sull'asse X
    double intervalX = (_maxDataPoints / 5).floorToDouble(); // Ad esempio, 5 tick principali

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
              aspectRatio: 1.7, // Proporzioni del grafico per mobile
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
                        interval: intervalX, // Usa l'intervallo calcolato
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
                  minX: chartMinX, // Usa il minX calcolato
                  maxX: chartMaxX, // Usa il maxX calcolato
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
            // Legenda per i colori del grafico
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

  /// Costruisce un elemento della legenda del grafico.
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
            // Se _showGraphs è true, mostra i grafici, altrimenti le card
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
              // Le card esistenti
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
                'Nota: La disponibilità e la precisione dei sensori dipendono dal dispositivo. Potrebbe essere necessario concedere il permesso "Riconoscimento attività fisica" dalle impostazioni dell\'app se i dati non vengono visualizzati.',
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
      // Pulsante Floating Action per cambiare vista
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showGraphs = !_showGraphs; // Inverti lo stato della vista
          });
        },
        backgroundColor: colorScheme.tertiary,
        foregroundColor: colorScheme.onTertiary,
        child: Icon(_showGraphs ? Icons.list : Icons.auto_graph), // Icona cambia in base alla vista
      ),
    );
  }
}
