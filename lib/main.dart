// lib/main.dart

// Importing the Flutter Material package for UI components
import 'package:flutter/material.dart';

// Importing shared_preferences to save small key-value data locally
import 'package:shared_preferences/shared_preferences.dart';

// Importing the Formula model class
import 'package:physics_ease_release/models/formula.dart';

// Importing the service used to load and manage formulas
import 'package:physics_ease_release/services/formula_service.dart';

// Importing the service used to manage formula notes
import 'package:physics_ease_release/services/notes_service.dart';
import 'package:physics_ease_release/models/note.dart';

// Importing developer tools for logging
import 'dart:developer' as developer;

// Importing all application pages
import 'package:physics_ease_release/pages/home_page.dart';
import 'package:physics_ease_release/pages/favorites_page.dart';
import 'package:physics_ease_release/pages/calculator_page.dart';
import 'package:physics_ease_release/pages/tools_page.dart';
import 'package:physics_ease_release/pages/data_page.dart';
import 'package:physics_ease_release/pages/help_page.dart';
import 'package:physics_ease_release/pages/info_page.dart';
import 'package:physics_ease_release/pages/collaborate_page.dart';
import 'package:physics_ease_release/pages/privacy_policy_page.dart';
import 'package:physics_ease_release/pages/licence_page.dart';
import 'package:physics_ease_release/pages/onboarding_page.dart';
import 'package:physics_ease_release/theme/app_theme.dart';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';
import 'package:physics_ease_release/widgets/drawer_card.dart';
import 'package:physics_ease_release/widgets/floating_nav_bar.dart';

// Importing for controlling system features (like exiting the app)
import 'package:flutter/services.dart';

// Entry point of the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Calcola la shortestSide logica del display principale (senza MediaQuery)
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final shortestLogicalSide =
      view.physicalSize.shortestSide / view.devicePixelRatio;
  final isTablet = shortestLogicalSide >= 600; // soglia consigliata per tablet

  await SystemChrome.setPreferredOrientations(
    isTablet
        ? <DeviceOrientation>[
            DeviceOrientation.portraitUp,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]
        : <DeviceOrientation>[DeviceOrientation.portraitUp],
  );

  runApp(const MyApp());
}

// Main application widget (Stateful because we manage state: theme, favorites, etc.)
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

// The app state where all logic and variables are stored
class _MyAppState extends State<MyApp> {
  // App theme mode (dark/light)
  ThemeMode _themeMode = ThemeMode.dark;

  // Stores the IDs of favorite formulas
  Set<String> _favoriteIds = {};

  // Stores notes for formulas (formulaId -> List of Note objects)
  Map<String, List<Note>> _formulaNotes = {};

  // Lists containing all formulas and user-added formulas
  List<Formula> _allFormulas = [];
  List<Formula> _userFormulas = [];

  // Index of the selected tab in the navigation bar
  int _selectedIndex = 0;

  // Indicates whether data is still loading
  bool _loading = true;

  // Shows onboarding only the first time
  bool _showOnboarding = false;

  // Scaffold key for drawer control
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Controls visibility of the search bar
  final ValueNotifier<bool> _searchBarVisible = ValueNotifier<bool>(false);

  // Each tab has its own navigation key for nested navigation
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  late final List<bool> _tabAppBarVisibility;

  // List of main pages
  late final List<Widget> _pages;

  // Determines whether to show the global AppBar
  bool _showGlobalAppBar = true;

  ColorScheme get _currentColorScheme => _themeMode == ThemeMode.dark
      ? AppTheme.darkColorScheme
      : AppTheme.lightColorScheme;

  MaterialApp _buildRootApp({
    required Widget home,
    bool debugShowCheckedModeBanner = true,
    String title = 'PhysicsEase',
  }) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      themeMode: _themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: home,
    );
  }

  static const List<NavBarItem> _navItems = [
    NavBarItem(icon: Icons.home, label: 'Home'),
    NavBarItem(icon: Icons.star, label: 'Preferiti'),
    NavBarItem(icon: Icons.calculate, label: 'Calcolatrice'),
    NavBarItem(icon: Icons.storage, label: 'Dati'),
    NavBarItem(icon: Icons.build, label: 'Strumenti'),
  ];

  @override
  void initState() {
    super.initState();
    _tabAppBarVisibility = List<bool>.filled(_navItems.length, true);

    // Load all app data and preferences when app starts
    _loadAllFormulasAndUserFormulas();
    _loadFavorites();
    _loadNotes();
    _loadThemeMode();
    _pages = _buildPages();
    _checkOnboardingStatus();
  }

  // Loads the saved theme (dark/light) from SharedPreferences
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('themeMode');
    setState(() {
      if (savedTheme == 'light') {
        _themeMode = ThemeMode.light;
      } else if (savedTheme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.dark;
      }
      developer.log('Caricato tema: $_themeMode');
      _updateTabPages(); // Refresh UI to apply theme
    });
  }

  // Loads all predefined and user-created formulas
  Future<void> _loadAllFormulasAndUserFormulas() async {
    final loadedPredefinedFormulas = await FormulaService.loadAllFormulas();
    final prefs = await SharedPreferences.getInstance();
    final userFormulasJson = prefs.getStringList('userFormulas') ?? [];

    // Decode user formulas from JSON
    List<Formula> loadedUserFormulas = [];
    for (String jsonString in userFormulasJson) {
      try {
        loadedUserFormulas.add(Formula.fromJson(jsonString));
      } catch (e) {
        developer.log('Error parsing user formula: $e');
      }
    }

    setState(() {
      _userFormulas = loadedUserFormulas;
      _allFormulas = [...loadedPredefinedFormulas, ..._userFormulas];
      developer.log(
        'Loaded ${loadedPredefinedFormulas.length} predefined formulas.',
      );
      developer.log('Loaded ${_userFormulas.length} user formulas.');
      _updateTabPages();
    });
  }

  // Checks if the onboarding has already been shown
  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;

    setState(() {
      _showOnboarding = !seen;
      _loading = false;
    });
  }

  // Marks onboarding as completed
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    setState(() {
      _showOnboarding = false;
    });
  }

  // Adds a new user formula and saves it persistently
  Future<void> _addFormulaAndSave(Formula newFormula) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userFormulas.add(newFormula);
      _allFormulas = [..._allFormulas, newFormula];
      developer.log('Added new formula: ${newFormula.titolo}');
    });

    final userFormulasJson = _userFormulas.map((f) => f.toJson()).toList();
    await prefs.setStringList('userFormulas', userFormulasJson);
    developer.log('Saved ${_userFormulas.length} user formulas.');
    _updateTabPages();
  }

  Future<void> _removeUserFormulaAndSave(String formulaId) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _userFormulas.removeWhere((formula) => formula.id == formulaId);
      _allFormulas.removeWhere((formula) => formula.id == formulaId);
      _favoriteIds.remove(formulaId);
      developer.log('Removed user formula: $formulaId');
    });

    final userFormulasJson = _userFormulas.map((f) => f.toJson()).toList();
    await prefs.setStringList('userFormulas', userFormulasJson);
    await prefs.setStringList('favorites', _favoriteIds.toList());
    developer.log('Saved ${_userFormulas.length} user formulas after removal.');
    _updateTabPages();
  }

  // Builds the main page widgets list
  List<Widget> _buildPages() {
    final currentColorScheme = _currentColorScheme;

    developer.log('Building pages with favorites: $_favoriteIds');
    return [
      HomePage(
        onToggleTheme: _toggleTheme,
        themeMode: _themeMode,
        allFormulas: _allFormulas,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        onRemoveUserFormula: _removeUserFormulaAndSave,
        setGlobalAppBarVisibility: _setGlobalAppBarVisibility,
        searchBarVisible: _searchBarVisible,
        colorScheme: currentColorScheme,
        formulaNotes: _formulaNotes,
        onSaveNotes: _saveNotes,
      ),
      FavoritesPage(
        allFormulas: _allFormulas,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        themeMode: _themeMode,
        setGlobalAppBarVisibility: _setGlobalAppBarVisibility,
        formulaNotes: _formulaNotes,
        onSaveNotes: _saveNotes,
      ),
      const CalculatorPage(),
      DataPage(setGlobalAppBarVisibility: _setGlobalAppBarVisibility),
      ToolsPage(
        onAddFormula: _addFormulaAndSave,
        setGlobalAppBarVisibility: _setGlobalAppBarVisibility,
      ),
    ];
  }

  // Controls whether to show/hide global AppBar
  void _setGlobalAppBarVisibility(bool visible) {
    final currentIndex = _selectedIndex;
    if (_tabAppBarVisibility[currentIndex] == visible &&
        _showGlobalAppBar == visible) {
      return;
    }

    setState(() {
      _tabAppBarVisibility[currentIndex] = visible;
      _showGlobalAppBar = visible;
    });
  }

  // Updates pages when data or theme changes
  void _updateTabPages() {
    final currentColorScheme = _currentColorScheme;

    setState(() {
      _pages[0] = HomePage(
        onToggleTheme: _toggleTheme,
        themeMode: _themeMode,
        allFormulas: _allFormulas,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        onRemoveUserFormula: _removeUserFormulaAndSave,
        setGlobalAppBarVisibility: _setGlobalAppBarVisibility,
        searchBarVisible: _searchBarVisible,
        colorScheme: currentColorScheme,
        formulaNotes: _formulaNotes,
        onSaveNotes: _saveNotes,
      );
      _pages[1] = FavoritesPage(
        allFormulas: _allFormulas,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        themeMode: _themeMode,
        setGlobalAppBarVisibility: _setGlobalAppBarVisibility,
        formulaNotes: _formulaNotes,
        onSaveNotes: _saveNotes,
      );
      _pages[3] = DataPage(
        setGlobalAppBarVisibility: _setGlobalAppBarVisibility,
      );
      _pages[4] = ToolsPage(
        onAddFormula: _addFormulaAndSave,
        setGlobalAppBarVisibility: _setGlobalAppBarVisibility,
      );
      developer.log('Updated pages and theme.');
    });
  }

  // Loads saved favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList('favorites') ?? [];
    setState(() {
      _favoriteIds = favList.toSet();
      developer.log('Loaded favorites: $_favoriteIds');
      _updateTabPages();
    });
  }

  // Adds/removes a formula from favorites
  Future<void> _toggleFavorite(String formulaId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final newFavoriteIds = Set<String>.from(_favoriteIds);
      if (newFavoriteIds.contains(formulaId)) {
        newFavoriteIds.remove(formulaId);
        developer.log('Removed favorite: $formulaId');
      } else {
        newFavoriteIds.add(formulaId);
        developer.log('Added favorite: $formulaId');
      }
      _favoriteIds = newFavoriteIds;
    });
    await prefs.setStringList('favorites', _favoriteIds.toList());
    developer.log('Saved favorites: ${_favoriteIds.toList()}');
    _updateTabPages();
  }

  // Loads saved notes 
  Future<void> _loadNotes() async {
    try {
      final formulasWithNotes = await NotesService.getFormulasWithNotes();
      final notesByFormula = <String, List<Note>>{};
      
      for (final formulaId in formulasWithNotes) {
        final notes = await NotesService.loadNotes(formulaId);
        notesByFormula[formulaId] = notes;
      }
      
      setState(() {
        _formulaNotes = notesByFormula;
        developer.log('Loaded notes for ${_formulaNotes.length} formulas');
      });
    } catch (e) {
      developer.log('Error loading notes: $e');
    }
  }

  // Saves or updates notes for a specific formula
  Future<void> _saveNotes(String formulaId, List<Note> notes) async {
    final success = await NotesService.saveNotes(formulaId, notes);
    if (success) {
      setState(() {
        if (notes.isEmpty) {
          _formulaNotes.remove(formulaId);
        } else {
          _formulaNotes[formulaId] = notes;
        }
        developer.log('Notes saved for formula: $formulaId');
      });
    }
  }

  // Toggles between light and dark mode
  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = (_themeMode == ThemeMode.light)
          ? ThemeMode.dark
          : ThemeMode.light;
      prefs.setString(
        'themeMode',
        _themeMode == ThemeMode.dark ? 'dark' : 'light',
      );
      developer.log('Theme changed to: $_themeMode');
      _updateTabPages();
    });
  }

  // Handles navigation bar taps
  void _onItemTapped(int index) {
    FocusScope.of(context).unfocus();

    if (_selectedIndex == index) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);

      if (!_tabAppBarVisibility[index] || !_showGlobalAppBar) {
        setState(() {
          _tabAppBarVisibility[index] = true;
          _showGlobalAppBar = true;
        });
      }
    } else {
      setState(() {
        _selectedIndex = index;
        _showGlobalAppBar = _tabAppBarVisibility[index];
      });
    }
  }

  // Returns the AppBar title based on the current tab index
  String _getCurrentAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'PhysicsEase';
      case 1:
        return 'Preferiti';
      case 2:
        return 'Calcolatrice';
      case 3:
        return 'Dati';
      case 4:
        return 'Strumenti';
      default:
        return 'PhysicsEase';
    }
  }



  // Builds the entire app UI
  @override
  Widget build(BuildContext context) {
    // If still loading, show progress indicator
    if (_loading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final currentColorScheme = _currentColorScheme;
    final bool isDarkMode = _themeMode == ThemeMode.dark;

    // Show onboarding page if user hasn't completed it
    if (_showOnboarding) {
      return _buildRootApp(
        debugShowCheckedModeBanner: false,
        home: OnboardingPage(onFinished: _completeOnboarding),
      );
    }

    return _buildRootApp(
      home: Builder(
        builder: (builderContext) => Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false, // Avoid resizing when keyboard opens
          appBar: null, // Custom top bar used instead
          drawer: Drawer(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Drawer header with app title
                Container(
                  width: double.infinity,
                  height: 200,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: currentColorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(36),
                        child: Image.asset(
                          _themeMode == ThemeMode.dark
                              ? 'assets/my_logo_dark.png'
                              : 'assets/my_logo_light.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image,
                              size: 100,
                              color: currentColorScheme.onPrimaryContainer,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Theme toggle option
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 28),
                  leading: Icon(
                    Icons.palette_outlined,
                    color: currentColorScheme.primary,
                    size: 28,
                  ),
                  title: const Text('Tema', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: currentColorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          color: AppTheme.transparent,
                          borderRadius: BorderRadius.circular(24),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              if (isDarkMode) _toggleTheme();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: !isDarkMode
                                    ? currentColorScheme.primary
                                    : AppTheme.transparent,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(
                                Icons.wb_sunny_outlined,
                                size: 24,
                                color: !isDarkMode
                                    ? currentColorScheme.onPrimary
                                    : currentColorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                        Material(
                          color: AppTheme.transparent,
                          borderRadius: BorderRadius.circular(24),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              if (!isDarkMode) _toggleTheme();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? currentColorScheme.primary
                                    : AppTheme.transparent,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(
                                Icons.dark_mode_outlined,
                                size: 24,
                                color: isDarkMode
                                    ? currentColorScheme.onPrimary
                                    : currentColorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Divider(
                  color: currentColorScheme.outlineVariant,
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),

                const SizedBox(height: 20),

                // Sezione Supporto
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Supporto',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: currentColorScheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                DrawerCard(
                  icon: Icons.help_outline,
                  title: 'Aiuto',
                  onTap: () async {
                    FocusScope.of(builderContext).unfocus();
                    Navigator.of(builderContext).pop();
                    await Navigator.of(builderContext, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (innerContext) => HelpPage(
                          themeMode: _themeMode,
                          setGlobalAppBarVisibility: _setGlobalAppBarVisibility,
                          onNavigateToSection: (ctx, section) async {
                            if (section == 'search') {
                              Navigator.of(ctx).pop();
                              if (mounted) {
                                setState(() {
                                  _selectedIndex = 0;
                                  _searchBarVisible.value = true;
                                });
                              }
                            } else if (section == 'favorites') {
                              _setGlobalAppBarVisibility(false);
                              await Navigator.push(
                                ctx,
                                MaterialPageRoute(
                                  builder: (context) => FavoritesPage(
                                    allFormulas: _allFormulas,
                                    favoriteIds: _favoriteIds,
                                    onToggleFavorite: _toggleFavorite,
                                    themeMode: _themeMode,
                                    setGlobalAppBarVisibility: _setGlobalAppBarVisibility,
                                    formulaNotes: _formulaNotes,
                                    onSaveNotes: _saveNotes,
                                  ),
                                ),
                              );
                              _setGlobalAppBarVisibility(true);
                            } else if (section == 'calculator') {
                              _setGlobalAppBarVisibility(false);
                              await Navigator.push(
                                ctx,
                                MaterialPageRoute(
                                  builder: (context) => const CalculatorPage(),
                                ),
                              );
                              _setGlobalAppBarVisibility(true);
                            } else if (section == 'data') {
                              _setGlobalAppBarVisibility(false);
                              await Navigator.push(
                                ctx,
                                MaterialPageRoute(
                                  builder: (context) => DataPage(
                                    setGlobalAppBarVisibility: _setGlobalAppBarVisibility,
                                  ),
                                ),
                              );
                              _setGlobalAppBarVisibility(true);
                            } else if (section == 'tools') {
                              _setGlobalAppBarVisibility(false);
                              await Navigator.push(
                                ctx,
                                MaterialPageRoute(
                                  builder: (context) => ToolsPage(
                                    onAddFormula: _addFormulaAndSave,
                                    setGlobalAppBarVisibility: _setGlobalAppBarVisibility,
                                  ),
                                ),
                              );
                              _setGlobalAppBarVisibility(true);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
                _buildDrawerCard(
                  context: builderContext,
                  icon: Icons.favorite_outline,
                  title: 'Dona ora',
                  colorScheme: currentColorScheme,
                  onTap: () {
                    FocusScope.of(builderContext).unfocus();
                    Navigator.of(builderContext).pop();
                    Navigator.of(builderContext, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (innerContext) =>
                            DonationPage(themeMode: _themeMode),
                      ),
                    );
                  },
                ),
                _buildDrawerCard(
                  context: builderContext,
                  icon: Icons.handshake_outlined,
                  title: 'Collabora',
                  colorScheme: currentColorScheme,
                  onTap: () {
                    FocusScope.of(builderContext).unfocus();
                    Navigator.of(builderContext).pop();
                    Navigator.of(builderContext, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (innerContext) =>
                            CollaboratePage(themeMode: _themeMode),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Sezione Informazioni
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Informazioni',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: currentColorScheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                DrawerCard(
                  icon: Icons.info_outline,
                  title: 'Info',
                  onTap: () {
                    FocusScope.of(builderContext).unfocus();
                    Navigator.of(builderContext).pop();
                    Navigator.of(builderContext, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (innerContext) =>
                            InfoPage(themeMode: _themeMode),
                      ),
                    );
                  },
                ),
                DrawerCard(
                  icon: Icons.policy_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    FocusScope.of(builderContext).unfocus();
                    Navigator.of(builderContext).pop();
                    Navigator.of(builderContext, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (innerContext) =>
                            PrivacyPolicyPage(themeMode: _themeMode),
                      ),
                    );
                  },
                ),
                DrawerCard(
                  icon: Icons.copyright_outlined,
                  title: 'Licenza',
                  onTap: () {
                    FocusScope.of(builderContext).unfocus();
                    Navigator.of(builderContext).pop();
                    Navigator.of(builderContext, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (innerContext) =>
                            LicencePage(themeMode: _themeMode),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // Main page body with tab navigation and floating bars
          body: PopScope(
            canPop: false, // Disable system back unless handled manually
            onPopInvokedWithResult: (bool didPop, dynamic result) async {
              if (didPop) return;

              FocusScope.of(context).unfocus();
              final NavigatorState currentNavigator =
                  _navigatorKeys[_selectedIndex].currentState!;
              if (currentNavigator.canPop()) {
                currentNavigator.pop();
              } else {
                // Exit the app if on root of first tab
                SystemNavigator.pop();
              }
            },

            child: Stack(
              children: [
                // Stack keeps all tabs alive using IndexedStack
                IndexedStack(
                  index: _selectedIndex,
                  children: List.generate(_pages.length, (index) {
                    return Navigator(
                      key: _navigatorKeys[index],
                      onGenerateInitialRoutes: (navigator, initialRoute) {
                        return [
                          MaterialPageRoute(
                            builder: (context) => _pages[index],
                            settings: const RouteSettings(
                              name: Navigator.defaultRouteName,
                            ),
                          ),
                        ];
                      },
                      onGenerateRoute: (routeSettings) {
                        return MaterialPageRoute(
                          builder: (context) => _pages[index],
                          settings: routeSettings,
                        );
                      },
                    );
                  }),
                ),

                // Floating bottom navigation bar
                Positioned(
                  bottom: MediaQuery.of(context).viewPadding.bottom + 12,
                  left: 16,
                  right: 16,
                  child: FloatingNavBar(
                    selectedIndex: _selectedIndex,
                    onItemTapped: _onItemTapped,
                    themeMode: _themeMode,
                    items: _navItems,
                  ),
                ),

                // Floating top AppBar
                if (_showGlobalAppBar)
                  Positioned(
                    top: MediaQuery.of(context).viewPadding.top,
                    left: 16,
                    right: 16,
                    child: FloatingTopBar(
                      title: _getCurrentAppBarTitle(),
                      leading: FloatingTopBarLeading.menu,
                      onMenuPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                        _searchBarVisible.value = false;
                      },
                      showSearch: _selectedIndex == 0, // solo Home
                      searchVisible: _searchBarVisible,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
