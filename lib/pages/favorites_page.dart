// lib/pages/favorites_page.dart
import 'package:flutter/material.dart';
import 'package:physics_ease_release/models/formula.dart';
import 'package:physics_ease_release/models/note.dart';
import 'package:physics_ease_release/pages/formula_detail_page.dart';
import 'package:physics_ease_release/widgets/latex_text.dart';

class FavoritesPage extends StatefulWidget {
  final List<Formula> allFormulas;
  final Set<String> favoriteIds;
  final Future<void> Function(String) onToggleFavorite;
  final ThemeMode themeMode;
  final void Function(bool) setGlobalAppBarVisibility;
  final Map<String, List<Note>> formulaNotes;
  final Future<void> Function(String, List<Note>)? onSaveNotes;

  const FavoritesPage({
    super.key,
    required this.allFormulas,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.themeMode,
    required this.setGlobalAppBarVisibility,
    required this.formulaNotes,
    required this.onSaveNotes,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Formula> _favoriteFormulas = [];
  final Set<String> _programmaticDismissIds = {};
  static const Duration _programmaticDismissDuration = Duration(
    milliseconds: 500,
  );

  Widget _buildDismissBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      child: Icon(
        Icons.delete_outline,
        color: Theme.of(context).colorScheme.onError,
      ),
    );
  }

  void _handleFavoriteDismissed(Formula formula) {
    if (mounted) {
      setState(() {
        _favoriteFormulas.removeWhere((item) => item.id == formula.id);
        _programmaticDismissIds.remove(formula.id);
      });
    }

    widget.onToggleFavorite(formula.id);
    widget.setGlobalAppBarVisibility(true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Formula rimossa dai preferiti'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Annulla',
          onPressed: () {
            widget.onToggleFavorite(formula.id);
          },
        ),
      ),
    );
  }

  void _triggerDismissAnimation(Formula formula) {
    if (_programmaticDismissIds.contains(formula.id)) return;

    setState(() {
      _programmaticDismissIds.add(formula.id);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void didUpdateWidget(covariant FavoritesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.favoriteIds != oldWidget.favoriteIds ||
        widget.allFormulas != oldWidget.allFormulas) {
      _loadFavorites();
    }
  }

  void _loadFavorites() {
    final formulasById = <String, Formula>{
      for (final formula in widget.allFormulas) formula.id: formula,
    };

    final orderedFavorites = widget.favoriteIds
        .toList()
        .reversed
        .map((id) => formulasById[id])
        .whereType<Formula>()
        .toList();

    setState(() {
      _favoriteFormulas = orderedFavorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_favoriteFormulas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border,
              size: 80,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 20),
            Text(
              'Nessuna formula nei preferiti.\nClicca sulla stella per aggiungerne alcune!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewPadding.bottom + 98,
        left: 8.0,
        right: 8.0,
        top: MediaQuery.of(context).viewPadding.top + 70,
      ),
      itemCount: _favoriteFormulas.length,
      itemBuilder: (context, index) {
        final formula = _favoriteFormulas[index];
        final isProgrammaticDismissing = _programmaticDismissIds.contains(
          formula.id,
        );
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
          child: Dismissible(
            key: Key(formula.id),
            direction: DismissDirection.startToEnd,
            onDismissed: (_) {
              _handleFavoriteDismissed(formula);
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
                        !_programmaticDismissIds.contains(formula.id)) {
                      return;
                    }

                    _handleFavoriteDismissed(formula);
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
                            Icons.remove_circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          tooltip: 'Rimuovi dai preferiti',
                          onPressed: () {
                            _triggerDismissAnimation(formula);
                          },
                        ),
                        title: Text(formula.titolo),
                        subtitle: formula.formulaLatex.isNotEmpty
                            ? LatexText(
                                formula.formulaLatex,
                                style: TextStyle(
                                  fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                latexColor: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                forceLatex: true,
                              )
                            : Text(
                                'Formula non disponibile',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                          widget.setGlobalAppBarVisibility(
                            false,
                          ); // NASCONDI PRIMA DI APRIRE
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FormulaDetailPage(
                                formula: formula,
                                themeMode: widget.themeMode,
                                isFavorite: widget.favoriteIds.contains(formula.id),
                                onToggleFavorite: widget.onToggleFavorite,
                                setGlobalAppBarVisibility:
                                    widget.setGlobalAppBarVisibility,
                                initialNotes: widget.formulaNotes[formula.id] ?? [],
                                onSaveNotes: widget.onSaveNotes,
                              ),
                            ),
                          );
                          widget.setGlobalAppBarVisibility(
                            true,
                          ); // RIPRISTINA DOPO IL POP
                        },
                      ),
                    ),
                  ),
                  builder: (context, progress, child) {
                    final translatedDx = constraints.maxWidth * 1.15 * progress;

                    return Stack(
                      children: [
                        if (progress > 0)
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: constraints.maxWidth * progress,
                                child: _buildDismissBackground(context),
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
          ),
        );
      },
    );
  }
}
