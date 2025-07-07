// lib/pages/constants_list_page.dart
import 'package:flutter/material.dart';

class ConstantsListPage extends StatefulWidget {

  @override
  State<ConstantsListPage> createState() => _ConstantsListPageState();
}

class _ConstantsListPageState extends State<ConstantsListPage> {
  final List<Map<String, String>> _constants = [
    {'name': 'Velocità della luce (c)', 'value': '299,792,458 m/s'},
    {'name': 'Costante di Planck (h)', 'value': '6.62607015 × 10^-34 J⋅s'},
    {'name': 'Carica elementare (e)', 'value': '1.602176634 × 10^-19 C'},
    {'name': 'Costante gravitazionale (G)', 'value': '6.67430 × 10^-11 N⋅m²/kg²'},
    {'name': 'Massa dell\'elettrone (me)', 'value': '9.1093837015 × 10^-31 kg'},
    {'name': 'Numero di Avogadro (NA)', 'value': '6.02214076 × 10^23 mol^-1'},
    {'name': 'Costante dei gas (R)', 'value': '8.314462618 J/(mol⋅K)'},
    {'name': 'Costante di Boltzmann (kB)', 'value': '1.380649 × 10^-23 J/K'},
    {'name': 'Permittività dello spazio libero (ε₀)', 'value': '8.8541878128 × 10^-12 F/m'},
    {'name': 'Permeabilità dello spazio libero (μ₀)', 'value': '4π × 10^-7 N/A²'},
    // Aggiungi altre costanti qui
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Costanti Fisiche'),
        backgroundColor: colorScheme.primaryContainer,
        iconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _constants.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final constant = _constants[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    constant['name']!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    constant['value']!,
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}