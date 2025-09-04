// lib/pages/data_page.dart
import 'package:flutter/material.dart';
import 'package:physics_ease_release/pages/constants_list_page.dart';
import 'package:physics_ease_release/pages/units_list_page.dart';
import 'package:physics_ease_release/pages/planets_page.dart';
import 'package:physics_ease_release/pages/periodic_table_page.dart';
import 'package:physics_ease_release/pages/greek_alphabet_page.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {

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
            title: 'Costanti Fisiche',
            subtitle: 'Consulta le costanti fondamentali della fisica',
            icon: Icons.science,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => ConstantsListPage(),
                ),
              );
            },
          ),
          _buildToolCard(
            context: context,
            title: 'Unità di Misura',
            subtitle: 'Esplora le unità di misura più comuni in fisica',
            icon: Icons.straighten,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => UnitsListPage(),
                ),
              );
            },
          ),
          _buildToolCard(
            context: context,
            title: 'Sistema Solare',
            subtitle: 'Scopri dati e proprietà fisiche dei pianeti',
            icon: Icons.public,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const PlanetsPage(),
                ),
              );
            },
          ),
          _buildToolCard(
            context: context,
            title: 'Tavola Periodica',
            subtitle: 'Esplora gli elementi chimici e le loro proprietà',
            icon: Icons.grid_on,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const PeriodicTablePage(),
                ),
              );
            },
          ),
          _buildToolCard(
            context: context,
            title: 'Alfabeto Greco',
            subtitle: 'Scopri le lettere greche e il loro utilizzo in fisica',
            icon: Icons.sort_by_alpha,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const GreekAlphabetPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}