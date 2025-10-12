// lib/pages/periodic_table_page.dart
import 'package:flutter/material.dart';
import 'package:physics_ease_release/models/element.dart' as MyElement;
import 'package:physics_ease_release/data/elements_data.dart';

class PeriodicTablePage extends StatelessWidget {
  const PeriodicTablePage({super.key});

  static final List<MyElement.Element> allElements = getAllElements();

  static final Map<int, MyElement.Element> elementsByNumber = {
    for (var e in allElements) e.number: e
  };
  static final Map<String, MyElement.Element> elementsByPosition = {
    for (var e in allElements) '${e.ypos}-${e.xpos}': e
  };

  // Determina le dimensioni della griglia
  static final int maxColumns = allElements.map((e) => e.xpos).reduce(
          (a, b) => a > b ? a : b); // Max xpos = 18 per la tavola principale
  static final int maxRows = allElements.map((e) => e.ypos).reduce(
          (a, b) => a > b ? a : b); // Max ypos = 10 per lantanidi/attinidi

  // Larghezza di ogni cella (element tile)
  static const double cellSize = 60.0; // Puoi aggiustare la dimensione delle celle

  // Costruisce una cella per un elemento specifico o una cella vuota
  Widget _buildElementCell(BuildContext context, MyElement.Element? element) {
    final colorScheme = Theme.of(context).colorScheme;

    if (element == null) {
      return SizedBox(
        width: cellSize,
        height: cellSize,
        child: Container(
          // Debugging colors
          // color: Colors.grey.withOpacity(0.05),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showElementDetails(context, element),
      child: Container(
        width: cellSize,
        height: cellSize,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: element.displayColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                element.number.toString(),
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: element.displayColor.computeLuminance() > 0.5
                      ? Colors.black87
                      : Colors.white,
                ),
              ),
            ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  element.symbol,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: element.displayColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  element.atomicMass > 0
                      ? element.atomicMass.toStringAsFixed(1)
                      : '',
                  style: TextStyle(
                    fontSize: 8,
                    color: element.displayColor.computeLuminance() > 0.5
                        ? Colors.black54
                        : Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showElementDetails(BuildContext context, MyElement.Element element) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: element.displayColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    element.symbol,
                    style: TextStyle(
                      color: element.displayColor.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      element.name,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      'Numero Atomico: ${element.number}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(context, 'Massa Atomica:', element.formattedAtomicMass),
                _buildDetailRow(context, 'Categoria:', element.category),
                _buildDetailRow(context, 'Conf. Elet:', element.electronicConfiguration),
                _buildDetailRow(context, 'P. Fus:', element.formattedMeltingPoint),
                _buildDetailRow(context, 'P. Eboll:', element.formattedBoilingPoint),
                _buildDetailRow(context, 'Densità:', element.formattedDensity),
                if (element.shell != null && element.shell!.isNotEmpty)
                  _buildDetailRow(context, 'Periodo:', element.shell!),
                if (element.block != null && element.block!.isNotEmpty)
                  _buildDetailRow(context, 'Blocco:', element.block!.toUpperCase()),
                if (element.discoveredBy != 'Sconosciuto' && element.discoveredBy.isNotEmpty)
                  _buildDetailRow(context, 'Scoperto da:', element.discoveredBy),
                if (element.yearDiscovered != 0)
                  _buildDetailRow(context, 'Anno Scoperta:', element.yearDiscovered.toString()),
                const SizedBox(height: 10),
                //Text(
                  //element.description,
                  //style: TextStyle(color: colorScheme.onSurfaceVariant),
                //),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Chiudi',
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryLegend(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final Set<String> categories = allElements.map((e) => e.category).toSet();
    final List<String> sortedCategories = categories.toList()..sort();

    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legenda Categorie:',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: sortedCategories.map((category) {
              return Chip(
                avatar: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: MyElement.Element.getColorForCategory(category),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black.withOpacity(0.2)),
                  ),
                ),
                label: Text(
                  category,
                  style: textTheme.bodySmall,
                ),
                backgroundColor: MyElement.Element.getColorForCategory(category).withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: MyElement.Element.getColorForCategory(category).withOpacity(0.5)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tavola Periodica'),
        backgroundColor: colorScheme.primaryContainer,
        iconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 140, left: 16, right: 16, top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tocca un elemento per vedere i suoi dettagli fisici e chimici. Scorri orizzontalmente per vedere tutti gli elementi.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            _buildCategoryLegend(context),
            const SizedBox(height: 20),
            // Scorrevolezza orizzontale
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int y = 1; y <= 7; y++)
                    Row(
                      children: [
                        for (int x = 1; x <= maxColumns; x++)
                          _buildElementCell(context, elementsByPosition['$y-$x']),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Text(
                    'Lantanidi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      SizedBox(width: cellSize * 3),
                      for (int x = 4; x <= 17; x++)
                        _buildElementCell(context, elementsByPosition['9-$x']),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Attinidi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      SizedBox(width: cellSize * 3),
                      for (int x = 4; x <= 17; x++)
                        _buildElementCell(context, elementsByPosition['10-$x']),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'I dati degli elementi sono basati su informazioni standard sulla tavola periodica (es. IUPAC). Alcuni valori di punti di fusione/ebollizione e densità potrebbero essere N/D (Non Disponibile) per elementi sintetici o non completamente caratterizzati.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}