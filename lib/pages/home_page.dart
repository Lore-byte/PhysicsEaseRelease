// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:physics_ease_release/models/formula.dart';
import 'package:physics_ease_release/pages/category_formulas_page.dart';
import 'package:physics_ease_release/pages/formula_detail_page.dart';
import 'package:physics_ease_release/pages/quiz_page.dart';

// HomePage is a StatefulWidget that represents the main screen of the app
class HomePage extends StatefulWidget {
  // Callback to toggle between light and dark mode
  final VoidCallback onToggleTheme;

  // The current theme mode (light/dark/system)
  final ThemeMode themeMode;

  // List of all formulas available in the app
  final List<Formula> allFormulas;

  // Set of favorite formula IDs
  final Set<String> favoriteIds;

  // Async function to toggle a formula as favorite
  final Future<void> Function(String) onToggleFavorite;

  // Function to control visibility of the global app bar
  final void Function(bool) setGlobalAppBarVisibility;

  // Notifier to control whether the search bar is visible or not
  final ValueNotifier<bool> searchBarVisible;

  // The color scheme currently used in the app
  final ColorScheme colorScheme;

  // Constructor for HomePage with all required parameters
  const HomePage({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
    required this.allFormulas,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.setGlobalAppBarVisibility,
    required this.searchBarVisible,
    required this.colorScheme,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

// State class for HomePage
class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  // Current text inside the search bar
  String _searchQuery = '';

  // Filtered list of formulas based on search query
  List<Formula> _filteredFormulas = [];

  // Focus node to control search bar focus state
  late FocusNode _searchFocusNode;

  // Controller to manage search bar text input
  late TextEditingController _searchController;

  // Map that associates each physics category with an icon
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
    // Initialize the focus node and text controller
    _searchFocusNode = FocusNode();
    _searchController = TextEditingController();

    // Initially populate filtered formulas (empty search)
    _filterFormulas();

    // Register this widget as a lifecycle observer
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
  void dispose() {
    // Clean up focus node and controller when the widget is disposed
    _searchFocusNode.dispose();
    _searchController.dispose();

    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Called every time user types something in the search bar
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterFormulas();
    });
  }

  // Resets the search query and removes focus from the field
  void _resetSearchAndFocus() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _filteredFormulas = [];
      _searchFocusNode.unfocus();
    });
  }

  // Filters formulas based on the current search query
  void _filterFormulas() {
    setState(() {
      if (_searchQuery.isEmpty) {
        // If search is empty, show nothing (or could show all)
        _filteredFormulas = [];
      } else {
        final queryLower = _searchQuery.toLowerCase();
        // Check if title, description, or keywords contain the query
        _filteredFormulas = widget.allFormulas.where((formula) {
          return formula.titolo.toLowerCase().contains(queryLower) ||
              formula.descrizione.toLowerCase().contains(queryLower) ||
              formula.paroleChiave
                  .any((k) => k.toLowerCase().contains(queryLower));
        }).toList();
      }
    });
  }

  // Builds a single card for a physics category
  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colorScheme = widget.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap, // Opens the category page when tapped
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
              // Arrow icon to indicate navigation
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extract unique categories from the formulas list
    final Set<String> categories =
        widget.allFormulas.map((f) => f.categoria).toSet();

    // Sort categories alphabetically, except "Personalizzate" which goes last
    List<String> temi = categories.where((cat) => cat != 'Personalizzate').toList();
    temi.sort();

    if (categories.contains('Personalizzate')) {
      temi.add('Personalizzate');
    }

    // Build the page layout
    return Stack(
      children: [
        Column(
          children: [
            // Search bar visibility controlled by ValueListenableBuilder
            ValueListenableBuilder<bool>(
              valueListenable: widget.searchBarVisible,
              builder: (context, visible, _) {
            if (!visible) {
              // When search bar closes, clear query and focus
              if (_searchQuery.isNotEmpty || _searchFocusNode.hasFocus) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _resetSearchAndFocus());
              }
              return const SizedBox.shrink(); // Return empty space
            }

            return Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).viewPadding.top + 70,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,                         // focalizza solo all'apertura
                textInputAction: TextInputAction.search, // tasto Invio/Cerca
                onSubmitted: (_) {
                  FocusScope.of(context).unfocus();      // chiude tastiera in modo stabile
                  // opzionale: widget.searchBarVisible.value = false; // per chiudere anche la barra
                },
                decoration: InputDecoration(
                  hintText: 'Cerca formule o parole chiave...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.backspace_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                onChanged: _onSearchChanged,
              ),
            );

          },
        ),

        // Main content list (categories or filtered formulas)
        ValueListenableBuilder<bool>(
          valueListenable: widget.searchBarVisible,
          builder: (context, searchVisible, _) {
            final topListPadding = searchVisible
                ? 0.0
                : MediaQuery.of(context).viewPadding.top + 70;

            return Expanded(
              child: GestureDetector(
                // Tap outside search bar to dismiss keyboard
                onTap: () => _searchFocusNode.unfocus(),
                behavior: HitTestBehavior.translucent,
                child: _searchQuery.isEmpty
                    // If search is empty, show category list
                    ? ListView.builder(
                        padding: EdgeInsets.only(
                          top: topListPadding,
                          bottom: MediaQuery.of(context).viewPadding.bottom + 98 + MediaQuery.of(context).viewInsets.bottom,
                        ),
                        itemCount: temi.length,
                        itemBuilder: (context, index) {
                          final tema = temi[index];
                          return _buildCategoryCard(
                            context: context,
                            title: tema,
                            icon: _categoryIcons[tema] ?? Icons.category,
                            onTap: () async {
                              // When category tapped, hide search bar and navigate to category page
                              widget.searchBarVisible.value = false;
                              _searchFocusNode.unfocus();
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CategoryFormulasPage(
                                    category: tema,
                                    allFormulas: widget.allFormulas,
                                    favoriteIds: widget.favoriteIds,
                                    onToggleFavorite: widget.onToggleFavorite,
                                    themeMode: widget.themeMode,
                                    setGlobalAppBarVisibility: widget.setGlobalAppBarVisibility,
                                  ),
                                ),
                              );
                              // Restore app bar visibility after returning
                              widget.setGlobalAppBarVisibility(true);
                            },
                          );
                        },
                      )
                    // Otherwise show filtered formulas
                    : ListView.builder(
                        padding: EdgeInsets.only(
                          top: 0, // Explicitly zero when filtered
                          bottom: MediaQuery.of(context).viewPadding.bottom + 98 + MediaQuery.of(context).viewInsets.bottom,
                          left: 16,
                          right: 16,
                        ),
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
                              // If LaTeX formula available, render it
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
                                        // If LaTeX fails, show error text
                                        return Text(
                                          'Errore LaTeX',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.error,
                                            fontSize: 12,
                                          ),
                                        );
                                      },
                                    )
                                  // Fallback text if formula missing
                                  : Text(
                                      'Formula non disponibile',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () async {
                                // When formula tapped, open detail page
                                widget.searchBarVisible.value = false;
                                _searchFocusNode.unfocus();
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => FormulaDetailPage(
                                      formula: formula,
                                      themeMode: widget.themeMode,
                                      setGlobalAppBarVisibility: widget.setGlobalAppBarVisibility,
                                      isFavorite: widget.favoriteIds.contains(formula.id),
                                      onToggleFavorite: widget.onToggleFavorite,
                                    ),
                                  ),
                                );
                                // Restore app bar visibility after returning
                                widget.setGlobalAppBarVisibility(true);
                              },
                            ),
                          );
                        },
                      ),
              ),
            );
          },
        ),
          ],
        ),
        
        Positioned(
          right: 16,
          bottom: 100,
          child: FloatingActionButton.extended(
            heroTag: 'quiz_fab',
            tooltip: 'Apri Quiz',
            onPressed: () async {
              widget.setGlobalAppBarVisibility(false);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizPage(
                    setGlobalAppBarVisibility: widget.setGlobalAppBarVisibility,
                  ),
                ),
              );
              widget.setGlobalAppBarVisibility(true);
            },
            icon: const Icon(Icons.quiz_rounded, size: 22),
            label: Text(
              'Quiz',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: widget.colorScheme.onPrimary,
              ),
            ),
            backgroundColor: widget.colorScheme.primary,
            foregroundColor: widget.colorScheme.onPrimary,
            elevation: 6,
            focusElevation: 8,
            hoverElevation: 8,
            highlightElevation: 10,
            shape: const StadiumBorder(),
          ),
        ),
      ],
    );
  }
}
