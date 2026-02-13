// lib/pages/category_formulas_page.dart

import 'package:flutter/material.dart';
import 'package:physics_ease_release/models/formula.dart';
import 'package:physics_ease_release/models/note.dart';
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
  final Map<String, List<Note>> formulaNotes;
  final Future<void> Function(String, List<Note>)? onSaveNotes;

  const CategoryFormulasPage({
    super.key,
    required this.category,
    required this.allFormulas,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.onRemoveUserFormula,
    required this.themeMode,
    required this.setGlobalAppBarVisibility,
    required this.formulaNotes,
    required this.onSaveNotes,
  });

  @override
  State<CategoryFormulasPage> createState() => _CategoryFormulasPageState();
}

class _CategoryFormulasPageState extends State<CategoryFormulasPage> {
  List<Formula> _filteredFormulas = [];
  final Set<String> _programmaticDismissIds = {};
  final Set<String> _pendingDeleteIds = {};
  static const Duration _programmaticDismissDuration = Duration(
    milliseconds: 500,
  );

  Widget _buildDismissBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: Icon(
        Icons.delete_outline,
        color: Theme.of(context).colorScheme.onError,
      ),
    );
  }

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

  Future<bool> _confirmAndDeleteFormula(Formula formula) async {
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

    return shouldDelete == true;
  }

  Future<void> _triggerDismissAnimation(Formula formula) async {
    if (_programmaticDismissIds.contains(formula.id) ||
        _pendingDeleteIds.contains(formula.id)) {
      return;
    }

    final shouldDelete = await _confirmAndDeleteFormula(formula);
    if (!shouldDelete || !mounted) return;

    setState(() {
      _programmaticDismissIds.add(formula.id);
    });
  }

  Future<void> _handleFormulaDismissed(Formula formula) async {
    if (_pendingDeleteIds.contains(formula.id)) return;

    final removedIndex = _filteredFormulas.indexWhere(
      (f) => f.id == formula.id,
    );
    if (removedIndex == -1) {
      if (mounted) {
        setState(() {
          _programmaticDismissIds.remove(formula.id);
        });
      }
      return;
    }

    setState(() {
      _filteredFormulas.removeAt(removedIndex);
      _programmaticDismissIds.remove(formula.id);
      _pendingDeleteIds.add(formula.id);
    });

    var isUndo = false;
    final snackBarController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Formula rimossa dalle personalizzate'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Annulla',
          onPressed: () {
            isUndo = true;
            if (!mounted) return;

            setState(() {
              final safeIndex = removedIndex.clamp(0, _filteredFormulas.length);
              _filteredFormulas.insert(safeIndex, formula);
              _pendingDeleteIds.remove(formula.id);
            });
          },
        ),
      ),
    );

    await snackBarController.closed;

    if (!mounted) return;
    if (isUndo) return;

    try {
      await widget.onRemoveUserFormula(formula.id);
      if (!mounted) return;

      setState(() {
        _pendingDeleteIds.remove(formula.id);
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        if (!_filteredFormulas.any((f) => f.id == formula.id)) {
          final safeIndex = removedIndex.clamp(0, _filteredFormulas.length);
          _filteredFormulas.insert(safeIndex, formula);
        }
        _pendingDeleteIds.remove(formula.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Errore durante l\'eliminazione della formula'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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

                    final isProgrammaticDismissing = _programmaticDismissIds
                        .contains(formula.id);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 8.0,
                      ),
                      child: isCustomCategory
                          ? Dismissible(
                              key: Key(formula.id),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) =>
                                  _confirmAndDeleteFormula(formula),
                              onDismissed: (_) {
                                _handleFormulaDismissed(formula);
                              },
                              background: _buildDismissBackground(context),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return TweenAnimationBuilder<double>(
                                    tween: Tween<double>(
                                      begin: 0,
                                      end: isProgrammaticDismissing ? 1 : 0,
                                    ),
                                    duration: _programmaticDismissDuration,
                                    curve: Curves.easeOutCubic,
                                    onEnd: () {
                                      if (!mounted ||
                                          !_programmaticDismissIds.contains(
                                            formula.id,
                                          )) {
                                        return;
                                      }

                                      _handleFormulaDismissed(formula);
                                    },
                                    child: IgnorePointer(
                                      ignoring: isProgrammaticDismissing,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 2,
                                        child: ListTile(
                                          leading: IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                            tooltip: 'Rimuovi formula',
                                            onPressed: () {
                                              _triggerDismissAnimation(formula);
                                            },
                                          ),
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
                                                  isFavorite: widget.favoriteIds
                                                      .contains(formula.id),
                                                  onToggleFavorite:
                                                      widget.onToggleFavorite,
                                                  setGlobalAppBarVisibility: widget
                                                      .setGlobalAppBarVisibility,
                                                  initialNotes: widget.formulaNotes[formula.id] ?? [],
                                                  onSaveNotes: widget.onSaveNotes,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    builder: (context, progress, child) {
                                      final translatedDx =
                                          -constraints.maxWidth *
                                          1.15 *
                                          progress;

                                      return Stack(
                                        children: [
                                          if (progress > 0)
                                            Positioned.fill(
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: SizedBox(
                                                  width:
                                                      constraints.maxWidth *
                                                      progress,
                                                  child:
                                                      _buildDismissBackground(
                                                        context,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          Transform.translate(
                                            offset: Offset(translatedDx, 0),
                                            child: child,
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            )
                          : Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              child: ListTile(
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
                                        onToggleFavorite:
                                            widget.onToggleFavorite,
                                        setGlobalAppBarVisibility:
                                            widget.setGlobalAppBarVisibility,
                                        initialNotes: widget.formulaNotes[formula.id] ?? [],
                                        onSaveNotes: widget.onSaveNotes,
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
