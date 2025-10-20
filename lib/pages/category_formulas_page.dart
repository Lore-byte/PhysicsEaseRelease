// lib/pages/category_formulas_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:physics_ease_release/models/formula.dart';
import 'package:physics_ease_release/pages/formula_detail_page.dart';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';

class CategoryFormulasPage extends StatefulWidget {
  final String category;
  final List<Formula> allFormulas;
  final Set<String> favoriteIds;
  final Future<void> Function(String) onToggleFavorite;
  final ThemeMode themeMode;
  final void Function(bool) setGlobalAppBarVisibility;

  const CategoryFormulasPage({
    super.key,
    required this.category,
    required this.allFormulas,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.themeMode,
    required this.setGlobalAppBarVisibility,
  });

  @override
  State<CategoryFormulasPage> createState() => _CategoryFormulasPageState();
}

class _CategoryFormulasPageState extends State<CategoryFormulasPage> {
  List<Formula> _filteredFormulas = [];

  @override
  void initState() {
    super.initState();
    _filterFormulas();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.setGlobalAppBarVisibility(false);
    });
  }

  @override
  void didUpdateWidget(covariant CategoryFormulasPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.category != oldWidget.category ||
        widget.allFormulas != oldWidget.allFormulas ||
        widget.favoriteIds != oldWidget.favoriteIds) {
      _filterFormulas();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _filterFormulas() {
    setState(() {
      _filteredFormulas = widget.allFormulas
          .where((f) => f.categoria == widget.category)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: null, // RIMOSSA AppBar nativa
      body: Stack(
        children: [

          // Contenuto sotto la barra
            _filteredFormulas.isEmpty
                ? const Center(
              child: Text('Nessuna formula trovata per questa categoria.'),
            )
                : ListView.builder(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).viewPadding.top + 70,
                left: 8.0,
                right: 8.0,
                bottom: MediaQuery.of(context).viewPadding.bottom + 98,
              ),
              itemCount: _filteredFormulas.length,
              itemBuilder: (context, index) {
                final formula = _filteredFormulas[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text(formula.titolo),
                      subtitle: Math.tex(
                        formula.formulaLatex,
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                      trailing:
                      const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FormulaDetailPage(
                              formula: formula,
                              themeMode: widget.themeMode,
                              isFavorite: widget.favoriteIds
                                  .contains(formula.id),
                              onToggleFavorite: widget.onToggleFavorite,
                              setGlobalAppBarVisibility: widget.setGlobalAppBarVisibility,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          // Barra flottante in alto con back e senza cerca
          Positioned(
            top: MediaQuery.of(context).viewPadding.top,
            left: 16,
            right: 16,
            child: FloatingTopBar(
              title: widget.category,
              leading: FloatingTopBarLeading.back,
              showSearch: false,
            ),
          ),
        ],
      ),
    );
  }
}
