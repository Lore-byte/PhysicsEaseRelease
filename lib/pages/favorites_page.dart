// lib/pages/favorites_page.dart
import 'package:flutter/material.dart';
import 'package:physics_ease_release/models/formula.dart';
import 'package:physics_ease_release/pages/formula_detail_page.dart';
import 'package:physics_ease_release/widgets/latex_text.dart';

class FavoritesPage extends StatefulWidget {
  final List<Formula> allFormulas;
  final Set<String> favoriteIds;
  final Future<void> Function(String) onToggleFavorite;
  final ThemeMode themeMode;
  final void Function(bool) setGlobalAppBarVisibility;

  const FavoritesPage({
    super.key,
    required this.allFormulas,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.themeMode,
    required this.setGlobalAppBarVisibility,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Formula> _favoriteFormulas = [];

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
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
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
                  widget.onToggleFavorite(formula.id);
                  widget.setGlobalAppBarVisibility(true);
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
                    ),
                  ),
                );
                widget.setGlobalAppBarVisibility(
                  true,
                ); // RIPRISTINA DOPO IL POP
              },
            ),
          ),
        );
      },
    );
  }
}
