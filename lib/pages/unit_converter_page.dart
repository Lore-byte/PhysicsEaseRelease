// lib/pages/unit_converter_page.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Unit {
  final String name;
  final String symbol;
  final double conversionFactor;

  Unit({required this.name, required this.symbol, required this.conversionFactor});
}

class UnitCategory {
  final String name;
  final List<Unit> units;

  UnitCategory({required this.name, required this.units});
}

final List<UnitCategory> _unitCategories = [
  UnitCategory(
    name: 'Lunghezza',
    units: [
      Unit(name: 'Metro', symbol: 'm', conversionFactor: 1.0),
      Unit(name: 'Chilometro', symbol: 'km', conversionFactor: 1000.0),
      Unit(name: 'Centimetro', symbol: 'cm', conversionFactor: 0.01),
      Unit(name: 'Millimetro', symbol: 'mm', conversionFactor: 0.001),
      Unit(name: 'Miglio', symbol: 'mi', conversionFactor: 1609.34),
      Unit(name: 'Iarda', symbol: 'yd', conversionFactor: 0.9144),
      Unit(name: 'Piede', symbol: 'ft', conversionFactor: 0.3048),
      Unit(name: 'Pollice', symbol: 'in', conversionFactor: 0.0254),
    ],
  ),
  UnitCategory(
    name: 'Massa',
    units: [
      Unit(name: 'Chilogrammo', symbol: 'kg', conversionFactor: 1.0),
      Unit(name: 'Grammo', symbol: 'g', conversionFactor: 0.001),
      Unit(name: 'Libbra', symbol: 'lb', conversionFactor: 0.453592),
      Unit(name: 'Oncia', symbol: 'oz', conversionFactor: 0.0283495),
    ],
  ),
  UnitCategory(
    name: 'Tempo',
    units: [
      Unit(name: 'Secondo', symbol: 's', conversionFactor: 1.0),
      Unit(name: 'Minuto', symbol: 'min', conversionFactor: 60.0),
      Unit(name: 'Ora', symbol: 'hr', conversionFactor: 3600.0),
      Unit(name: 'Giorno', symbol: 'day', conversionFactor: 86400.0),
      Unit(name: 'Anno', symbol: 'yr', conversionFactor: 31536000.0), // --> anno medio
    ],
  ),
  UnitCategory(
    name: 'Temperatura',
    units: [
      Unit(name: 'Celsius', symbol: '°C', conversionFactor: 0.0),
      Unit(name: 'Fahrenheit', symbol: '°F', conversionFactor: 0.0),
      Unit(name: 'Kelvin', symbol: 'K', conversionFactor: 0.0),
    ],
  ),
];

class UnitConverterPage extends StatefulWidget {

  @override
  State<UnitConverterPage> createState() => _UnitConverterPageState();
}

class _UnitConverterPageState extends State<UnitConverterPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  late UnitCategory _selectedCategory;
  late Unit _fromUnit;
  late Unit _toUnit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });

    _selectedCategory = _unitCategories.first;
    _fromUnit = _selectedCategory.units.first;
    _toUnit = _selectedCategory.units.length > 1
        ? _selectedCategory.units[1]
        : _selectedCategory.units.first;

    _inputController.addListener(_convert);
  }

  @override
  void dispose() {
    _inputController.removeListener(_convert);
    _inputController.dispose();
    _outputController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
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
        _outputController.text = result.toStringAsFixed(6);
        if (_outputController.text.contains('.') && _outputController.text.endsWith('0')) {
          _outputController.text = _outputController.text.replaceAll(RegExp(r'0*$'), '');
          if (_outputController.text.endsWith('.')) {
            _outputController.text = _outputController.text.substring(0, _outputController.text.length - 1);
          }
        }
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
    _convert();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Convertitore Unità'),
        backgroundColor: colorScheme.primaryContainer,
        iconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                        child: Text(category.name, style: TextStyle(fontSize: 18, color: colorScheme.onSurface)),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // Campo di Input
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
                          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                        ),
                        onChanged: (_) => _convert(),
                      ),
                    ),
                    DropdownButtonHideUnderline(
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
                  ],
                ),
              ),
            ),

            Align(
              alignment: Alignment.center,
              child: IconButton(
                icon: Icon(Icons.swap_vert, size: 36, color: colorScheme.secondary),
                onPressed: _swapUnits,
                tooltip: 'Scambia unità',
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
                          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                        ),
                      ),
                    ),
                    DropdownButtonHideUnderline(
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}