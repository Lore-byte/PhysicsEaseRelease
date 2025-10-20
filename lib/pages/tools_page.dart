import 'package:flutter/material.dart';
import 'package:physics_ease_release/pages/add_formula_page.dart';
import 'package:physics_ease_release/models/formula.dart';
import 'package:physics_ease_release/pages/unit_converter_page.dart';
import 'package:physics_ease_release/pages/equation_solver_page.dart';
import 'package:physics_ease_release/pages/graph_page.dart';
import 'package:physics_ease_release/pages/sensors_page.dart';
import 'package:physics_ease_release/pages/vector_calculator_page.dart';

class ToolsPage extends StatefulWidget {
  final Future<void> Function(Formula) onAddFormula;

  const ToolsPage({
    super.key,
    required this.setGlobalAppBarVisibility,
    required this.onAddFormula,
  });
  final void Function(bool) setGlobalAppBarVisibility;

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
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + 98, top: MediaQuery.of(context).viewPadding.top + 70),
      child: Column(
        children: [
          _buildToolCard(
            context: context,
            title: 'Aggiungi Nuova Formula',
            subtitle: 'Inserisci le tue formule personalizzate',
            icon: Icons.add_box,
            onTap: () async {
              widget.setGlobalAppBarVisibility(false);
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => AddFormulaPage(
                    onAddFormula: widget.onAddFormula,
                  ),
                ),
              );
              widget.setGlobalAppBarVisibility(true);
            },
          ),
          _buildToolCard(
            context: context,
            title: 'Convertitore Unità',
            subtitle: 'Converti tra diverse unità di misura',
            icon: Icons.square_foot,
            onTap: () async {
              widget.setGlobalAppBarVisibility(false);
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => UnitConverterPage(),
                ),
              );
              widget.setGlobalAppBarVisibility(true);
            },
          ),
          _buildToolCard(
            context: context,
            title: 'Risolutore Equazioni',
            subtitle: 'Risolvi equazioni algebriche e fisiche',
            icon: Icons.functions,
            onTap: () async {
              widget.setGlobalAppBarVisibility(false);
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => EquationSolverPage(),
                ),
              );
              widget.setGlobalAppBarVisibility(true);
            },
          ),
          _buildToolCard(
            context: context,
            title: 'Visualizzatore Grafici',
            subtitle: 'Visualizza funzioni matematiche su un grafico',
            icon: Icons.auto_graph,
            onTap: () async {
              widget.setGlobalAppBarVisibility(false);
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => GraphPage(),
                ),
              );
              widget.setGlobalAppBarVisibility(true);
            },
          ),
          _buildToolCard(
            context: context,
            title: 'Calcolatore Vettoriale',
            subtitle: 'Esegui operazioni su vettori',
            icon: Icons.alt_route,
            onTap: () async {
              widget.setGlobalAppBarVisibility(false);
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => VectorCalculatorPage(),
                ),
              );
              widget.setGlobalAppBarVisibility(true);
            },
          ),
          _buildToolCard(
            context: context,
            title: 'Sensori', //spostati sulla versione pro
            subtitle: 'Visualizza dati da accelerometro, giroscopio e magnetometro',
            icon: Icons.sensors,
            onTap: () async {
              widget.setGlobalAppBarVisibility(false);
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => SensorToolPage(),
                ),
              );
              widget.setGlobalAppBarVisibility(true);
            },
          ),
        ],
      ),
    );
  }
}