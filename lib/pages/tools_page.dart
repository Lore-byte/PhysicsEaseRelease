import 'package:flutter/material.dart';
import 'package:physics_ease_release/pages/add_formula_page.dart';
import 'package:physics_ease_release/models/formula.dart';
import 'package:physics_ease_release/pages/unit_converter_page.dart';
import 'package:physics_ease_release/pages/equation_solver_page.dart';
import 'package:physics_ease_release/pages/graph_page.dart';
import 'package:physics_ease_release/pages/sensors_page.dart';

class ToolsPage extends StatefulWidget {
  final Future<void> Function(Formula) onAddFormula;

  const ToolsPage({
    super.key,
    required this.onAddFormula,
  });

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {

  Widget _buildToolCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: colorScheme.primary),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          _buildToolCard(
            context: context,
            title: 'Aggiungi Nuova Formula',
            subtitle: 'Inserisci le tue formule personalizzate',
            icon: Icons.add_box,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => AddFormulaPage(
                    onAddFormula: widget.onAddFormula,
                  ),
                ),
              );
            },
          ),
          _buildToolCard(
            context: context,
            title: 'Convertitore Unità',
            subtitle: 'Converti tra diverse unità di misura',
            icon: Icons.square_foot,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => UnitConverterPage(),
                ),
              );
            },
          ),
          _buildToolCard(
            context: context,
            title: 'Risolutore Equazioni',
            subtitle: 'Risolvi equazioni algebriche e fisiche',
            icon: Icons.functions,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const EquationSolverPage(),
                ),
              );
            },
          ),
          _buildToolCard(
            context: context,
            title: 'Visualizzatore Grafici',
            subtitle: 'Visualizza funzioni matematiche su un grafico',
            icon: Icons.auto_graph,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const GraphPage(),
                ),
              );
            },
          ),
          _buildToolCard(
            context: context,
            title: 'Sensori', //spostati sulla versione pro
            subtitle: 'Visualizza dati da accelerometro, giroscopio e magnetometro',
            icon: Icons.sensors,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const SensorToolPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}