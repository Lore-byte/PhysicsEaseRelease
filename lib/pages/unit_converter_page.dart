import 'package:flutter/material.dart';
//import 'dart:math' as math;
import 'package:physics_ease_release/widgets/floating_top_bar.dart';

class Unit {
  final String name;
  final String symbol;
  final double conversionFactor;

  Unit({required this.name, required this.symbol, required this.conversionFactor});
}

class UnitCategory {
  final String name;
  final List<Unit> units;
  final IconData icon;

  UnitCategory({required this.name, required this.units, required this.icon});
}

final List<UnitCategory> _unitCategories = [
  UnitCategory(
    name: 'Lunghezza',
    units: [
      Unit(name: 'Metro', symbol: 'm', conversionFactor: 1.0),
      Unit(name: 'Chilometro', symbol: 'km', conversionFactor: 1000.0),
      Unit(name: 'Centimetro', symbol: 'cm', conversionFactor: 0.01),
      Unit(name: 'Millimetro', symbol: 'mm', conversionFactor: 0.001),
      Unit(name: 'Micrometro', symbol: 'µm', conversionFactor: 1e-6),
      Unit(name: 'Nanometro', symbol: 'nm', conversionFactor: 1e-9),
      Unit(name: 'Miglio', symbol: 'mi', conversionFactor: 1609.34),
      Unit(name: 'Iarda', symbol: 'yd', conversionFactor: 0.9144),
      Unit(name: 'Piede', symbol: 'ft', conversionFactor: 0.3048),
      Unit(name: 'Pollice', symbol: 'in', conversionFactor: 0.0254),
      Unit(name: 'Miglia nautiche', symbol: 'NM', conversionFactor: 1852.0),
    ],
    icon: Icons.straighten,
  ),
  UnitCategory(
    name: 'Massa',
    units: [
      Unit(name: 'Chilogrammo', symbol: 'kg', conversionFactor: 1.0),
      Unit(name: 'Grammo', symbol: 'g', conversionFactor: 0.001),
      Unit(name: 'Milligrammo', symbol: 'mg', conversionFactor: 1e-6),
      Unit(name: 'Tonnellata metrica', symbol: 't', conversionFactor: 1000.0),
      Unit(name: 'Libbra', symbol: 'lb', conversionFactor: 0.453592),
      Unit(name: 'Oncia', symbol: 'oz', conversionFactor: 0.0283495),
      Unit(name: 'Carato', symbol: 'ct', conversionFactor: 0.0002),
    ],
    icon: Icons.scale,
  ),
  UnitCategory(
    name: 'Tempo',
    units: [
      Unit(name: 'Secondo', symbol: 's', conversionFactor: 1.0),
      Unit(name: 'Millisecondo', symbol: 'ms', conversionFactor: 0.001),
      Unit(name: 'Microsecondo', symbol: 'µs', conversionFactor: 1e-6),
      Unit(name: 'Minuto', symbol: 'min', conversionFactor: 60.0),
      Unit(name: 'Ora', symbol: 'hr', conversionFactor: 3600.0),
      Unit(name: 'Giorno', symbol: 'day', conversionFactor: 86400.0),
      Unit(name: 'Settimana', symbol: 'week', conversionFactor: 604800.0),
      Unit(name: 'Anno', symbol: 'yr', conversionFactor: 31536000.0),
    ],
    icon: Icons.access_time,
  ),
  UnitCategory(
    name: 'Temperatura',
    units: [
      Unit(name: 'Celsius', symbol: '°C', conversionFactor: 0.0),
      Unit(name: 'Fahrenheit', symbol: '°F', conversionFactor: 0.0),
      Unit(name: 'Kelvin', symbol: 'K', conversionFactor: 0.0),
    ],
    icon: Icons.thermostat,
  ),
  UnitCategory(
    name: 'Volume',
    units: [
      Unit(name: 'Metro Cubo', symbol: 'm³', conversionFactor: 1.0),
      Unit(name: 'Litro', symbol: 'L', conversionFactor: 0.001),
      Unit(name: 'Millilitro', symbol: 'ml', conversionFactor: 1e-6),
      Unit(name: 'Gallone (USA)', symbol: 'gal (US)', conversionFactor: 0.00378541),
      Unit(name: 'Piede Cubo', symbol: 'ft³', conversionFactor: 0.0283168),
      Unit(name: 'Pollice Cubo', symbol: 'in³', conversionFactor: 0.0000163871),
    ],
    icon: Icons.fitness_center,
  ),
  UnitCategory(
    name: 'Area',
    units: [
      Unit(name: 'Metro Quadrato', symbol: 'm²', conversionFactor: 1.0),
      Unit(name: 'Chilometro Quadrato', symbol: 'km²', conversionFactor: 1e6),
      Unit(name: 'Centimetro Quadrato', symbol: 'cm²', conversionFactor: 1e-4),
      Unit(name: 'Millimetro Quadrato', symbol: 'mm²', conversionFactor: 1e-6),
      Unit(name: 'Ettaro', symbol: 'ha', conversionFactor: 10000.0),
      Unit(name: 'Acri', symbol: 'ac', conversionFactor: 4046.86),
      Unit(name: 'Piede Quadrato', symbol: 'ft²', conversionFactor: 0.092903),
      Unit(name: 'Pollice Quadrato', symbol: 'in²', conversionFactor: 0.00064516),
    ],
    icon: Icons.square_foot,
  ),
  UnitCategory(
    name: 'Velocità',
    units: [
      Unit(name: 'Metri al Secondo', symbol: 'm/s', conversionFactor: 1.0),
      Unit(name: 'Chilometri all\'Ora', symbol: 'km/h', conversionFactor: 0.277778),
      Unit(name: 'Miglia all\'Ora', symbol: 'mph', conversionFactor: 0.44704),
      Unit(name: 'Nodi', symbol: 'kn', conversionFactor: 0.514444),
    ],
    icon: Icons.speed,
  ),
  UnitCategory(
    name: 'Pressione',
    units: [
      Unit(name: 'Pascal', symbol: 'Pa', conversionFactor: 1.0),
      Unit(name: 'Atmosfera', symbol: 'atm', conversionFactor: 101325.0),
      Unit(name: 'Bar', symbol: 'bar', conversionFactor: 100000.0),
      Unit(name: 'PSI', symbol: 'psi', conversionFactor: 6894.76),
    ],
    icon: Icons.compress,
  ),
  UnitCategory(
    name: 'Energia',
    units: [
      Unit(name: 'Joule', symbol: 'J', conversionFactor: 1.0),
      Unit(name: 'Chilojoule', symbol: 'kJ', conversionFactor: 1000.0),
      Unit(name: 'Caloria', symbol: 'cal', conversionFactor: 4.184),
      Unit(name: 'Chilocaloria', symbol: 'kcal', conversionFactor: 4184.0),
      Unit(name: 'Elettronvolt', symbol: 'eV', conversionFactor: 1.60218e-19),
    ],
    icon: Icons.flash_on,
  ),
  UnitCategory(
    name: 'Potenza',
    units: [
      Unit(name: 'Watt', symbol: 'W', conversionFactor: 1.0),
      Unit(name: 'Chilowatt', symbol: 'kW', conversionFactor: 1000.0),
      Unit(name: 'Cavallo Vapore (metrico)', symbol: 'CV', conversionFactor: 735.49875),
      Unit(name: 'Horsepower (UK/US)', symbol: 'hp', conversionFactor: 745.7),
    ],
    icon: Icons.power,
  ),
  UnitCategory(
    name: 'Frequenza',
    units: [
      Unit(name: 'Hertz', symbol: 'Hz', conversionFactor: 1.0),
      Unit(name: 'Chilohertz', symbol: 'kHz', conversionFactor: 1000.0),
      Unit(name: 'Megahertz', symbol: 'MHz', conversionFactor: 1e6),
      Unit(name: 'Gigahertz', symbol: 'GHz', conversionFactor: 1e9),
    ],
    icon: Icons.ssid_chart,
  ),
];

class UnitConverterPage extends StatefulWidget {
  const UnitConverterPage({super.key});

  @override
  State<UnitConverterPage> createState() => _UnitConverterPageState();
}

class _UnitConverterPageState extends State<UnitConverterPage> with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  late UnitCategory _selectedCategory;
  late Unit _fromUnit;
  late Unit _toUnit;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _unitCategories.first;
    _fromUnit = _selectedCategory.units.first;
    _toUnit = _selectedCategory.units.length > 1
        ? _selectedCategory.units[1]
        : _selectedCategory.units.first;

    _inputController.addListener(_convert);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _inputController.removeListener(_convert);
    _inputController.dispose();
    _outputController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _convert() {
    if (_inputController.text.isEmpty) {
      setState(() {
        _outputController.text = '';
      });
      return;
    }

    final double? inputValue = double.tryParse(_inputController.text);
    if (inputValue == null) {
      setState(() {
        _outputController.text = 'Input non valido';
      });
      return;
    }

    double result;
    if (_selectedCategory.name == 'Temperatura') {
      result = _convertTemperature(inputValue, _fromUnit, _toUnit);
    } else {
      double valueInBaseUnit = inputValue * _fromUnit.conversionFactor;
      result = valueInBaseUnit / _toUnit.conversionFactor;
    }

    setState(() {
      if (result == result.roundToDouble()) {
        _outputController.text = result.toInt().toString();
      } else {
        String formattedResult = result.toStringAsFixed(10);
        formattedResult = formattedResult.replaceAll(RegExp(r'\.?0+$'), '');
        _outputController.text = formattedResult;
      }
    });
  }

  double _convertTemperature(double value, Unit from, Unit to) {
    double celsiusValue;

    if (from.symbol == '°C') {
      celsiusValue = value;
    } else if (from.symbol == '°F') {
      celsiusValue = (value - 32) * 5 / 9;
    } else if (from.symbol == 'K') {
      celsiusValue = value - 273.15;
    } else {
      return double.nan;
    }

    if (to.symbol == '°C') {
      return celsiusValue;
    } else if (to.symbol == '°F') {
      return (celsiusValue * 9 / 5) + 32;
    } else if (to.symbol == 'K') {
      return celsiusValue + 273.15;
    } else {
      return double.nan;
    }
  }

  void _swapUnits() {
    setState(() {
      final tempUnit = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = tempUnit;

      final tempInputValue = _inputController.text;
      _inputController.text = _outputController.text;
      _outputController.text = tempInputValue;
    });

    _animationController.forward(from: 0.0);
    _convert();
  }

  void _clearFields() {
    setState(() {
      _inputController.clear();
      _outputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + 98, left: 16, right: 16, top: MediaQuery.of(context).viewPadding.top + 70),
            child: Column(
              children: [
                Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<UnitCategory>(
                        value: _selectedCategory,
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                        onChanged: (UnitCategory? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCategory = newValue;
                              _fromUnit = newValue.units.first;
                              _toUnit = newValue.units.length > 1 ? newValue.units[1] : newValue.units.first;
                              _convert();
                            });
                          }
                        },
                        items: _unitCategories.map<DropdownMenuItem<UnitCategory>>((UnitCategory category) {
                          return DropdownMenuItem<UnitCategory>(
                            value: category,
                            child: Row(
                              children: [
                                Icon(category.icon, color: colorScheme.secondary, size: 24),
                                const SizedBox(width: 10),
                                Text(category.name, style: TextStyle(fontSize: 18, color: colorScheme.onSurface)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(fontSize: 24, color: colorScheme.onSurface),
                            decoration: InputDecoration(
                              hintText: 'Inserisci valore',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                            ),
                            onChanged: (_) => _convert(),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3), width: 1.0),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Unit>(
                              value: _fromUnit,
                              icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                              onChanged: (Unit? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _fromUnit = newValue;
                                  });
                                  _convert();
                                }
                              },
                              items: _selectedCategory.units.map<DropdownMenuItem<Unit>>((Unit unit) {
                                return DropdownMenuItem<Unit>(
                                  value: unit,
                                  child: Text(unit.symbol, style: TextStyle(fontSize: 18, color: colorScheme.onSurface)),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: RotationTransition(
                    turns: _animation,
                    child: IconButton(
                      icon: Icon(Icons.swap_vert, size: 36, color: colorScheme.secondary),
                      onPressed: _swapUnits,
                      tooltip: 'Scambia unità',
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(top: 8.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _outputController,
                            readOnly: true,
                            style: TextStyle(fontSize: 24, color: colorScheme.onSurface),
                            decoration: InputDecoration(
                              hintText: 'Risultato',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3), width: 1.0),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Unit>(
                              value: _toUnit,
                              icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                              onChanged: (Unit? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _toUnit = newValue;
                                  });
                                  _convert();
                                }
                              },
                              items: _selectedCategory.units.map<DropdownMenuItem<Unit>>((Unit unit) {
                                return DropdownMenuItem<Unit>(
                                  value: unit,
                                  child: Text(unit.symbol, style: TextStyle(fontSize: 18, color: colorScheme.onSurface)),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _clearFields,
                  icon: Icon(Icons.clear_all, color: colorScheme.onPrimary),
                  label: Text(
                    'Cancella',
                    style: TextStyle(color: colorScheme.onPrimary),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ConversionTable(
                      selectedCategory: _selectedCategory,
                      fromUnit: _fromUnit,
                      toUnit: _toUnit,
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
              title: 'Convertitore Unità',
              leading: FloatingTopBarLeading.back,
              onBackPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      )
    );
  }
}

class ConversionTable extends StatelessWidget {
  final UnitCategory selectedCategory;
  final Unit fromUnit;
  final Unit toUnit;

  const ConversionTable({super.key,
    required this.selectedCategory,
    required this.fromUnit,
    required this.toUnit,
  });

  String _convertValueForTable(double value, Unit from, Unit to) {
    if (selectedCategory.name == 'Temperatura') {
      double celsiusValue;
      if (from.symbol == '°C') {
        celsiusValue = value;
      } else if (from.symbol == '°F') {
        celsiusValue = (value - 32) * 5 / 9;
      } else if (from.symbol == 'K') {
        celsiusValue = value - 273.15;
      } else {
        return 'N/A';
      }

      if (to.symbol == '°C') {
        return _formatResult(celsiusValue);
      } else if (to.symbol == '°F') {
        return _formatResult((celsiusValue * 9 / 5) + 32);
      } else if (to.symbol == 'K') {
        return _formatResult(celsiusValue + 273.15);
      } else {
        return 'N/A';
      }
    } else {
      double valueInBaseUnit = value * from.conversionFactor;
      double result = valueInBaseUnit / to.conversionFactor;
      return _formatResult(result);
    }
  }

  String _getConversionFactorText() {
    if (selectedCategory.name == 'Temperatura') {
      return 'Le conversioni di temperatura seguono formule specifiche.';
    } else {
      double factor = fromUnit.conversionFactor / toUnit.conversionFactor;
      String formattedFactor = _formatResult(factor);
      return '1 ${fromUnit.symbol} = $formattedFactor ${toUnit.symbol}';
    }
  }


  String _formatResult(double result) {
    if (result == 0.0) {
      return '0';
    }

    if (result.abs() < 0.0001 || result.abs() >= 1000000) {
      return result.toStringAsExponential(5);
    } else {
      String formattedResult = result.toStringAsPrecision(7);

      if (formattedResult.contains('.')) {
        formattedResult = formattedResult.replaceAll(RegExp(r'\.?0+$'), '');
      }
      return formattedResult;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<double> exampleValues = [1, 10, 100, 1000];

    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                selectedCategory.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getConversionFactorText(),
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20,
                      dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return colorScheme.primary.withValues(alpha: 0.08);
                          }
                          return null;
                        },
                      ),
                      headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                          return colorScheme.primaryContainer.withValues(alpha: 0.5);
                        },
                      ),
                      columns: [
                        DataColumn(
                          label: Text(
                            fromUnit.symbol,
                            style: TextStyle(fontStyle: FontStyle.italic, color: colorScheme.onSurface),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            toUnit.symbol,
                            style: TextStyle(fontStyle: FontStyle.italic, color: colorScheme.onSurface),
                          ),
                        ),
                      ],
                      rows: exampleValues.map((value) {
                        return DataRow(
                          cells: [
                            DataCell(Text(
                              _formatResult(value),
                              style: TextStyle(color: colorScheme.onSurface),
                            )),
                            DataCell(Text(
                              _convertValueForTable(value, fromUnit, toUnit),
                              style: TextStyle(color: colorScheme.onSurface),
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}