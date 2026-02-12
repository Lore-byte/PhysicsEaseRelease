// lib/pages/category_formulas_page.dart

import 'package:flutter/material.dart';
import 'package:physics_ease_release/models/formula.dart';
import 'package:physics_ease_release/pages/formula_detail_page.dart';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';
import 'package:physics_ease_release/widgets/latex_text.dart';

class CategoryFormulasPage extends StatefulWidget {
  final String category;
  final List<Formula> allFormulas;
  final Set<String> favoriteIds;
  final Future<void> Function(String) onToggleFavorite;
  final Future<void> Function(String) onRemoveUserFormula;
  final ThemeMode themeMode;
  final void Function(bool) setGlobalAppBarVisibility;

  const CategoryFormulasPage({
    super.key,
    required this.category,
    required this.allFormulas,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.onRemoveUserFormula,
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
    final filtered = widget.allFormulas
        .where((f) => f.categoria == widget.category)
        .toList();

    if (widget.category == 'Personalizzate') {
      filtered.sort((a, b) {
        final aTime = int.tryParse(a.id) ?? 0;
        final bTime = int.tryParse(b.id) ?? 0;
        return bTime.compareTo(aTime);
      });
    }

    setState(() {
      _filteredFormulas = filtered;
    });
  }

  Future<void> _confirmAndDeleteFormula(Formula formula) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Conferma eliminazione'),
          content: Text('Vuoi eliminare la formula "${formula.titolo}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    final removedIndex = _filteredFormulas.indexWhere(
      (f) => f.id == formula.id,
    );
    Formula? removedFormula;

    if (removedIndex != -1) {
      setState(() {
        removedFormula = _filteredFormulas.removeAt(removedIndex);
      });
    }

    try {
      await widget.onRemoveUserFormula(formula.id);
    } catch (_) {
      if (!mounted) return;
      if (removedFormula != null) {
        setState(() {
          _filteredFormulas.insert(removedIndex, removedFormula!);
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Errore durante l\'eliminazione della formula'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formula eliminata con successo'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //final colorScheme = Theme.of(context).colorScheme;

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
                    final isCustomCategory =
                        widget.category == 'Personalizzate';

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 8.0,
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: isCustomCategory
                              ? IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  tooltip: 'Elimina formula',
                                  onPressed: () =>
                                      _confirmAndDeleteFormula(formula),
                                )
                              : null,
                          title: Text(formula.titolo),
                          subtitle: LatexText(
                            formula.formulaLatex,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            latexColor: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            forceLatex: true,
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FormulaDetailPage(
                                  formula: formula,
                                  themeMode: widget.themeMode,
                                  isFavorite: widget.favoriteIds.contains(
                                    formula.id,
                                  ),
                                  onToggleFavorite: widget.onToggleFavorite,
                                  setGlobalAppBarVisibility:
                                      widget.setGlobalAppBarVisibility,
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
