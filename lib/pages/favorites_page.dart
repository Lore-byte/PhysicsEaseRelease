// lib/pages/favorites_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:physics_ease_release/models/formula.dart';
import 'package:physics_ease_release/pages/formula_detail_page.dart';

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
    setState(() {
      _favoriteFormulas = widget.allFormulas
          .where((f) => widget.favoriteIds.contains(f.id))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_favoriteFormulas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 80, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            const SizedBox(height: 20),
            Text(
              'Nessuna formula nei preferiti.\nClicca sulla stella per aggiungerne alcune!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + 98, left: 8.0, right: 8.0, top: MediaQuery.of(context).viewPadding.top + 70),
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
              title: Text(formula.titolo),
              subtitle: formula.formulaLatex.isNotEmpty
                  ? Math.tex(
                formula.formulaLatex,
                textStyle: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onErrorFallback: (Object e) {
                  return Text('Errore LaTeX', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12));
                },
              )
                  : Text('Formula non disponibile', style: TextStyle(fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.error)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                widget.setGlobalAppBarVisibility(false); // NASCONDI PRIMA DI APRIRE
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FormulaDetailPage(
                      formula: formula,
                      themeMode: widget.themeMode,
                      isFavorite: widget.favoriteIds.contains(formula.id),
                      onToggleFavorite: widget.onToggleFavorite,
                      setGlobalAppBarVisibility: widget.setGlobalAppBarVisibility,
                    ),
                  ),
                );
                widget.setGlobalAppBarVisibility(true); // RIPRISTINA DOPO IL POP
              },
            ),
          ),
        );
      },
    );
  }
}