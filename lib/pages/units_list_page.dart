// lib/pages/units_list_page.dart
import 'package:flutter/material.dart';

class UnitsListPage extends StatelessWidget {

  const UnitsListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });

    final colorScheme = Theme.of(context).colorScheme;

    final Map<String, List<Map<String, String>>> units = {
      'Lunghezza': [
        {'name': 'Metro', 'symbol': 'm', 'description': 'Unità SI fondamentale'},
        {'name': 'Chilometro', 'symbol': 'km', 'description': '1000 metri'},
        {'name': 'Centimetro', 'symbol': 'cm', 'description': '0.01 metri'},
        {'name': 'Millimetro', 'symbol': 'mm', 'description': '0.001 metri'},
        {'name': 'Pollice', 'symbol': 'in', 'description': '2.54 cm'},
        {'name': 'Piede', 'symbol': 'ft', 'description': '12 pollici'},
      ],
      'Massa': [
        {'name': 'Chilogrammo', 'symbol': 'kg', 'description': 'Unità SI fondamentale'},
        {'name': 'Grammo', 'symbol': 'g', 'description': '0.001 chilogrammi'},
        {'name': 'Tonnellata', 'symbol': 't', 'description': '1000 chilogrammi'},
        {'name': 'Libbra', 'symbol': 'lb', 'description': '0.453592 kg'},
      ],
      'Tempo': [
        {'name': 'Secondo', 'symbol': 's', 'description': 'Unità SI fondamentale'},
        {'name': 'Minuto', 'symbol': 'min', 'description': '60 secondi'},
        {'name': 'Ora', 'symbol': 'h', 'description': '3600 secondi'},
        {'name': 'Giorno', 'symbol': 'd', 'description': '24 ore'},
      ],
      'Temperatura': [
        {'name': 'Kelvin', 'symbol': 'K', 'description': 'Unità SI fondamentale'},
        {'name': 'Celsius', 'symbol': '°C', 'description': 'K - 273.15'},
        {'name': 'Fahrenheit', 'symbol': '°F', 'description': '(°C × 9/5) + 32'},
      ],
      'Corrente Elettrica': [
        {'name': 'Ampere', 'symbol': 'A', 'description': 'Unità SI fondamentale'},
        {'name': 'Milliampere', 'symbol': 'mA', 'description': '0.001 Ampere'},
      ],
      'Intensità Luminosa': [
        {'name': 'Candela', 'symbol': 'cd', 'description': 'Unità SI fondamentale'},
      ],
      'Quantità di Sostanza': [
        {'name': 'Mole', 'symbol': 'mol', 'description': 'Unità SI fondamentale'},
      ],
      'Velocità': [
        {'name': 'Metro al secondo', 'symbol': 'm/s', 'description': 'Unità SI derivata'},
        {'name': 'Chilometro orario', 'symbol': 'km/h', 'description': 'Unità comune'},
      ],
      'Forza': [
        {'name': 'Newton', 'symbol': 'N', 'description': 'kg·m/s²'},
      ],
      'Energia': [
        {'name': 'Joule', 'symbol': 'J', 'description': 'N·m'},
        {'name': 'Caloria', 'symbol': 'cal', 'description': '4.184 Joule'},
        {'name': 'Elettronvolt', 'symbol': 'eV', 'description': '1.602×10⁻¹⁹ J'},
      ],
      'Potenza': [
        {'name': 'Watt', 'symbol': 'W', 'description': 'J/s'},
      ],
      'Pressione': [
        {'name': 'Pascal', 'symbol': 'Pa', 'description': 'N/m²'},
        {'name': 'Bar', 'symbol': 'bar', 'description': '10⁵ Pa'},
      ],
      'Frequenza': [
        {'name': 'Hertz', 'symbol': 'Hz', 'description': 'Cicli al secondo'},
      ],
      'Tensione Elettrica': [
        {'name': 'Volt', 'symbol': 'V', 'description': 'J/C'},
      ],
      'Resistenza Elettrica': [
        {'name': 'Ohm', 'symbol': 'Ω', 'description': 'V/A'},
      ],
      'Capacità Elettrica': [
        {'name': 'Farad', 'symbol': 'F', 'description': 'C/V'},
      ],
    };

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lista Unità di Misura'),
          backgroundColor: colorScheme.primaryContainer,
          iconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: units.keys.length,
          itemBuilder: (context, categoryIndex) {
            final categoryName = units.keys.elementAt(categoryIndex);
            final unitList = units[categoryName]!;

            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: ExpansionTile(
                initiallyExpanded: true,
                title: Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                children: unitList.map((unit) {
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
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${unit['symbol']!})',
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          unit['description']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
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