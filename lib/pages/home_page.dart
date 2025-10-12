// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:physics_ease_release/models/formula.dart';
import 'package:physics_ease_release/pages/category_formulas_page.dart';
import 'package:physics_ease_release/pages/formula_detail_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;
  final List<Formula> allFormulas;
  final Set<String> favoriteIds;
  final Future<void> Function(String) onToggleFavorite;
  final void Function(bool) setGlobalAppBarVisibility;

  const HomePage({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
    required this.allFormulas,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.setGlobalAppBarVisibility,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String _searchQuery = '';
  List<Formula> _filteredFormulas = [];
  late FocusNode _searchFocusNode;
  late TextEditingController _searchController;

  final Map<String, IconData> _categoryIcons = {
    'Cinematica': Icons.directions_run,
    'Dinamica': Icons.fitness_center,
    'Termodinamica': Icons.thermostat,
    'Lavoro ed Energia': Icons.bolt,
    'Elettromagnetismo': Icons.electric_meter,
    'Elettrostatica': Icons.electric_bolt,
    'Onde e Ottica': Icons.waves,
    'Fluidi': Icons.water_drop,
    'Gravitazione': Icons.public,
    'Quantità di Moto': Icons.speed_outlined,
    'Momento Angolare': Icons.rotate_left_sharp,
    'Circuiti Elettrici': Icons.electrical_services_rounded,
    'Magnetismo': Icons.explore,
    'Relatività': Icons.access_time,
    'Fisica Quantistica': Icons.blur_circular,
    'Fisica Nucleare': Icons.warning_amber,
    'Personalizzate': Icons.person_add_alt_1,
  };

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _searchController = TextEditingController();
    _filterFormulas();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.allFormulas != oldWidget.allFormulas ||
        widget.favoriteIds != oldWidget.favoriteIds) {
      _filterFormulas();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentRoute = ModalRoute.of(context);
    if (currentRoute != null && currentRoute.isCurrent) {
      if (_searchController.text.isNotEmpty || _searchFocusNode.hasFocus) {
        _resetSearchAndFocus();
      }
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterFormulas();
    });
  }

  void _resetSearchAndFocus() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _filteredFormulas = [];
      _searchFocusNode.unfocus();
    });
  }

  void _filterFormulas() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredFormulas = [];
      } else {
        final queryLower = _searchQuery.toLowerCase();
        _filteredFormulas = widget.allFormulas.where((formula) {
          return formula.titolo.toLowerCase().contains(queryLower) ||
              formula.descrizione.toLowerCase().contains(queryLower) ||
              formula.paroleChiave
                  .any((k) => k.toLowerCase().contains(queryLower));
        }).toList();
      }
    });
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
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
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
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
    final Set<String> categories =
    widget.allFormulas.map((f) => f.categoria).toSet();

    List<String> temi = categories.where((cat) => cat != 'Personalizzate').toList();
    temi.sort();

    if (categories.contains('Personalizzate')) {
      temi.add('Personalizzate');
    }


    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Cerca formule o parole chiave...',
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant),
                onPressed: () {
                  _resetSearchAndFocus();
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant,
            ),
            onChanged: _onSearchChanged,
          ),
        ),

        Expanded(
          child: GestureDetector(
            onTap: () {
              _searchFocusNode.unfocus();
            },
            behavior: HitTestBehavior.translucent,
            child: _searchQuery.isEmpty
                ? ListView.builder(
              padding: EdgeInsets.only(bottom: 120),
              itemCount: temi.length,
              itemBuilder: (context, index) {
                final tema = temi[index];
                return _buildCategoryCard(
                  context: context,
                  title: tema,
                  icon: _categoryIcons[tema] ?? Icons.category,
                  onTap: () async {
                    _searchFocusNode.unfocus();
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CategoryFormulasPage(
                          category: tema,
                          allFormulas: widget.allFormulas,
                          favoriteIds: widget.favoriteIds,
                          onToggleFavorite: widget.onToggleFavorite,
                          themeMode: widget.themeMode,
                          setGlobalAppBarVisibility:
                          widget.setGlobalAppBarVisibility,
                        ),
                      ),
                    );
                    widget.setGlobalAppBarVisibility(true);
                  },
                );
              },
            )
                : ListView.builder(
              padding: EdgeInsets.only(bottom: 120),
              itemCount: _filteredFormulas.length,
              itemBuilder: (context, index) {
                final formula = _filteredFormulas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      formula.titolo,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: formula.formulaLatex.isNotEmpty
                        ? Math.tex(
                      formula.formulaLatex,
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                      onErrorFallback: (Object e) {
                        return Text(
                          'Errore LaTeX',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        );
                      },
                    )
                        : Text(
                      'Formula non disponibile',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color:
                        Theme.of(context).colorScheme.error,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      _searchFocusNode.unfocus();
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FormulaDetailPage(
                            formula: formula,
                            themeMode: widget.themeMode,
                            isFavorite:
                            widget.favoriteIds.contains(formula.id),
                            onToggleFavorite: widget.onToggleFavorite,
                          ),
                        ),
                      );
                      widget.setGlobalAppBarVisibility(true);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}