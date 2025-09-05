// lib/pages/units_list_page.dart
import 'package:flutter/material.dart';

class UnitsListPage extends StatefulWidget {
  const UnitsListPage({super.key});

  @override
  State<UnitsListPage> createState() => _UnitsListPageState();
}

class _UnitsListPageState extends State<UnitsListPage> {
  bool _showFundamentalOnly = false;

  final Map<String, List<Map<String, String>>> units = {
    'Lunghezza': [
      {'name': 'Metro', 'symbol': 'm', 'description': 'Unità SI fondamentale', 'isFundamental': 'true'},
      {'name': 'Chilometro', 'symbol': 'km', 'description': '1000 metri', 'isFundamental': 'false'},
      {'name': 'Centimetro', 'symbol': 'cm', 'description': '0.01 metri', 'isFundamental': 'false'},
      {'name': 'Millimetro', 'symbol': 'mm', 'description': '0.001 metri', 'isFundamental': 'false'},
      {'name': 'Micrometro', 'symbol': 'µm', 'description': '10⁻⁶ metri', 'isFundamental': 'false'},
      {'name': 'Nanometro', 'symbol': 'nm', 'description': '10⁻⁹ metri', 'isFundamental': 'false'},
      {'name': 'Pollice', 'symbol': 'in', 'description': '2.54 cm', 'isFundamental': 'false'},
      {'name': 'Piede', 'symbol': 'ft', 'description': '12 pollici', 'isFundamental': 'false'},
    ],
    'Massa': [
      {'name': 'Chilogrammo', 'symbol': 'kg', 'description': 'Unità SI fondamentale', 'isFundamental': 'true'},
      {'name': 'Grammo', 'symbol': 'g', 'description': '0.001 chilogrammi', 'isFundamental': 'false'},
      {'name': 'Milligrammo', 'symbol': 'mg', 'description': '10⁻³ grammi', 'isFundamental': 'false'},
      {'name': 'Tonnellata', 'symbol': 't', 'description': '1000 chilogrammi', 'isFundamental': 'false'},
      {'name': 'Libbra', 'symbol': 'lb', 'description': '0.453592 kg', 'isFundamental': 'false'},
      {'name': 'Oncia', 'symbol': 'oz', 'description': '1/16 di libbra ≈ 28.35 g', 'isFundamental': 'false'},
    ],
    'Tempo': [
      {'name': 'Secondo', 'symbol': 's', 'description': 'Unità SI fondamentale', 'isFundamental': 'true'},
      {'name': 'Millisecondo', 'symbol': 'ms', 'description': '10⁻³ secondi', 'isFundamental': 'false'},
      {'name': 'Minuto', 'symbol': 'min', 'description': '60 secondi', 'isFundamental': 'false'},
      {'name': 'Ora', 'symbol': 'h', 'description': '3600 secondi', 'isFundamental': 'false'},
      {'name': 'Giorno', 'symbol': 'd', 'description': '24 ore', 'isFundamental': 'false'},
    ],
    'Temperatura': [
      {'name': 'Kelvin', 'symbol': 'K', 'description': 'Unità SI fondamentale', 'isFundamental': 'true'},
      {'name': 'Celsius', 'symbol': '°C', 'description': 'K - 273.15', 'isFundamental': 'false'},
      {'name': 'Fahrenheit', 'symbol': '°F', 'description': '(°C × 9/5) + 32', 'isFundamental': 'false'},
    ],
    'Elettricità': [
      {'name': 'Ampere', 'symbol': 'A', 'description': 'Unità SI fondamentale per la corrente elettrica', 'isFundamental': 'true'},
      {'name': 'Milliampere', 'symbol': 'mA', 'description': '0.001 Ampere', 'isFundamental': 'false'},
      {'name': 'Volt', 'symbol': 'V', 'description': 'Unità SI per la tensione elettrica (J/C)', 'isFundamental': 'false'},
      {'name': 'Ohm', 'symbol': 'Ω', 'description': 'Unità SI per la resistenza elettrica (V/A)', 'isFundamental': 'false'},
      {'name': 'Farad', 'symbol': 'F', 'description': 'Unità SI per la capacità elettrica (C/V)', 'isFundamental': 'false'},
      {'name': 'Wattora', 'symbol': 'Wh', 'description': 'Unità comune di energia elettrica', 'isFundamental': 'false'},
    ],
    'Intensità Luminosa': [
      {'name': 'Candela', 'symbol': 'cd', 'description': 'Unità SI fondamentale', 'isFundamental': 'true'},
      {'name': 'Lumen', 'symbol': 'lm', 'description': 'Unità SI per il flusso luminoso', 'isFundamental': 'false'},
      {'name': 'Lux', 'symbol': 'lx', 'description': 'lm/m²', 'isFundamental': 'false'},
    ],
    'Quantità di Sostanza': [
      {'name': 'Mole', 'symbol': 'mol', 'description': 'Unità SI fondamentale', 'isFundamental': 'true'},
    ],
    'Velocità': [
      {'name': 'Metro al secondo', 'symbol': 'm/s', 'description': 'Unità SI derivata', 'isFundamental': 'false'},
      {'name': 'Chilometro orario', 'symbol': 'km/h', 'description': 'Unità comune', 'isFundamental': 'false'},
      {'name': 'Nodo', 'symbol': 'kn', 'description': '1.852 km/h', 'isFundamental': 'false'},
      {'name': 'Mach', 'symbol': 'Ma', 'description': 'Velocità del suono', 'isFundamental': 'false'},
    ],
    'Forza': [
      {'name': 'Newton', 'symbol': 'N', 'description': 'kg·m/s²', 'isFundamental': 'false'},
      {'name': 'Kilogrammo forza', 'symbol': 'kgf', 'description': '9.80665 N', 'isFundamental': 'false'},
    ],
    'Energia': [
      {'name': 'Joule', 'symbol': 'J', 'description': 'N·m', 'isFundamental': 'false'},
      {'name': 'Caloria', 'symbol': 'cal', 'description': '4.184 Joule', 'isFundamental': 'false'},
      {'name': 'Elettronvolt', 'symbol': 'eV', 'description': '1.602×10⁻¹⁹ J', 'isFundamental': 'false'},
      {'name': 'Kilowattora', 'symbol': 'kWh', 'description': '3.6×10⁶ J', 'isFundamental': 'false'},
    ],
    'Potenza': [
      {'name': 'Watt', 'symbol': 'W', 'description': 'J/s', 'isFundamental': 'false'},
      {'name': 'Cavallo vapore', 'symbol': 'CV', 'description': '≈ 735.5 W', 'isFundamental': 'false'},
    ],
    'Pressione': [
      {'name': 'Pascal', 'symbol': 'Pa', 'description': 'N/m²', 'isFundamental': 'false'},
      {'name': 'Bar', 'symbol': 'bar', 'description': '10⁵ Pa', 'isFundamental': 'false'},
      {'name': 'Millimetro di mercurio', 'symbol': 'mmHg', 'description': '133.322 Pa', 'isFundamental': 'false'},
      {'name': 'PSI', 'symbol': 'psi', 'description': 'Pound per square inch ≈ 6894.76 Pa', 'isFundamental': 'false'},
      {'name': 'Atmosfera', 'symbol': 'atm', 'description': '101325 Pa', 'isFundamental': 'false'},
    ],
    'Frequenza': [
      {'name': 'Hertz', 'symbol': 'Hz', 'description': 'Cicli al secondo', 'isFundamental': 'false'},
    ],
  };

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        final colorScheme = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Opzioni di Filtro',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mostra solo Unità SI Fondamentali',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Switch(
                        value: _showFundamentalOnly,
                        onChanged: (bool value) {
                          setStateModal(() {
                            _showFundamentalOnly = value;
                          });
                          setState(() {});
                        },
                        activeColor: colorScheme.secondary,
                        inactiveThumbColor: colorScheme.onSurface.withOpacity(0.5),
                        inactiveTrackColor: colorScheme.onSurface.withOpacity(0.2),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Map<String, List<Map<String, String>>> filteredUnits = _showFundamentalOnly
        ? Map.fromEntries(units.entries.map((entry) {
      final fundamentalUnitsInCategory = entry.value
          .where((unit) => unit['isFundamental'] == 'true')
          .toList();
      return MapEntry(entry.key, fundamentalUnitsInCategory);
    }).where((entry) => entry.value.isNotEmpty))
        : units;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) {
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Unità di Misura'),
          backgroundColor: colorScheme.primaryContainer,
          iconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
          actions: [
            IconButton(
              icon: Icon(
                _showFundamentalOnly ? Icons.filter_alt_off : Icons.filter_alt,
                color: colorScheme.onPrimaryContainer,
              ),
              onPressed: () => _showFilterOptions(context),
            ),
          ],
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: filteredUnits.keys.length,
          itemBuilder: (context, categoryIndex) {
            final categoryName = filteredUnits.keys.elementAt(categoryIndex);
            final unitList = filteredUnits[categoryName]!;

            if (unitList.isEmpty) {
              return const SizedBox.shrink();
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: ExpansionTile(
                initiallyExpanded: false,
                title: Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                children: unitList.map((unit) {
                  final isFundamental = unit['isFundamental'] == 'true';
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              unit['name']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isFundamental ? FontWeight.w900 : FontWeight.w600,
                                color: isFundamental ? colorScheme.secondary : colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${unit['symbol']!})',
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: isFundamental ? colorScheme.secondary : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          unit['description']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: isFundamental ? colorScheme.secondary.withOpacity(0.9) : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (unitList.last != unit)
                          Divider(color: colorScheme.outlineVariant.withOpacity(0.5), height: 16),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}