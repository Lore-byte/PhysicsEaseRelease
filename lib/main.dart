// lib/main.dart

// Importing the Flutter Material package for UI components
import 'package:flutter/material.dart';

// Importing shared_preferences to save small key-value data locally
import 'package:shared_preferences/shared_preferences.dart';

// Importing the Formula model class
import 'package:physics_ease_release/models/formula.dart';

// Importing the service used to load and manage formulas
import 'package:physics_ease_release/services/formula_service.dart';

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

import 'package:physics_ease_release/widgets/floating_top_bar.dart';

// Importing for controlling system features (like exiting the app)
import 'package:flutter/services.dart';

// Entry point of the app
void main() {
  // Runs the main widget of the app
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

  // List of main pages
  late final List<Widget> _pages;

  // Determines whether to show the global AppBar
  bool _showGlobalAppBar = true;

  @override
  void initState() {
    super.initState();
    // Load all app data and preferences when app starts
    _loadAllFormulasAndUserFormulas();
    _loadFavorites();
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

  // Builds the main page widgets list
  List<Widget> _buildPages() {
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue[800]!,
      brightness: Brightness.dark,
    );
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue[600]!,
      brightness: Brightness.light,
    );
    final currentColorScheme = _themeMode == ThemeMode.dark
        ? darkColorScheme
        : lightColorScheme;

    developer.log('Building pages with favorites: $_favoriteIds');
    return [
      HomePage(
        onToggleTheme: _toggleTheme,
        themeMode: _themeMode,
        allFormulas: _allFormulas,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        setGlobalAppBarVisibility: _setGlobalAppBarVisibility,
        searchBarVisible: _searchBarVisible,
        colorScheme: currentColorScheme,
      ),
      FavoritesPage(
        allFormulas: _allFormulas,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        themeMode: _themeMode,
        setGlobalAppBarVisibility: _setGlobalAppBarVisibility,
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
    if (_showGlobalAppBar != visible) {
      setState(() {
        _showGlobalAppBar = visible;
      });
    }
  }

  // Updates pages when data or theme changes
  void _updateTabPages() {
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue[800]!,
      brightness: Brightness.dark,
    );
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue[600]!,
      brightness: Brightness.light,
    );
    final currentColorScheme = _themeMode == ThemeMode.dark
        ? darkColorScheme
        : lightColorScheme;

    setState(() {
      _pages[0] = HomePage(
        onToggleTheme: _toggleTheme,
        themeMode: _themeMode,
        allFormulas: _allFormulas,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        setGlobalAppBarVisibility: _setGlobalAppBarVisibility,
        searchBarVisible: _searchBarVisible,
        colorScheme: currentColorScheme,
      );
      _pages[1] = FavoritesPage(
        allFormulas: _allFormulas,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        themeMode: _themeMode,
        setGlobalAppBarVisibility: _setGlobalAppBarVisibility,
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
    setState(() {
      FocusScope.of(context).unfocus(); // Hide keyboard
      if (_selectedIndex == index) {
        // If already on the same tab, return to root
        _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
        _setGlobalAppBarVisibility(true);
      } else {
        // Reset navigation stacks of all other tabs
        for (int i = 0; i < _navigatorKeys.length; i++) {
          if (i != index) {
            _navigatorKeys[i].currentState?.popUntil((route) => route.isFirst);
          }
        }
        _setGlobalAppBarVisibility(true);
        _selectedIndex = index;
      }
      _searchBarVisible.value = false; // Hide search bar when changing tab
    });
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

  // Builds the floating bottom navigation bar
  Widget _buildFloatingNavBar(ColorScheme colorScheme) {
    final shadowColor = _themeMode == ThemeMode.dark
        ? Colors.black.withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.8);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 30,
            offset: const Offset(0, 50),
            spreadRadius: 40,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: SizedBox(
            height: 70,
            child: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.star),
                  label: 'Preferiti',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calculate),
                  label: 'Calcolatrice',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.storage),
                  label: 'Dati',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.build),
                  label: 'Strumenti',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: colorScheme.primary,
              unselectedItemColor: colorScheme.onSurfaceVariant,
              backgroundColor: Colors.transparent,
              elevation: 0,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 12,
              unselectedFontSize: 11,
            ),
          ),
        ),
      ),
    );
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

    // Define color schemes for light and dark mode
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue[800]!,
      brightness: Brightness.dark,
    );
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue[600]!,
      brightness: Brightness.light,
    );
    final currentColorScheme = _themeMode == ThemeMode.dark
        ? darkColorScheme
        : lightColorScheme;

    // Show onboarding page if user hasn't completed it
    if (_showOnboarding) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: lightColorScheme, useMaterial3: true),
        darkTheme: ThemeData(colorScheme: darkColorScheme, useMaterial3: true),
        themeMode: _themeMode,
        home: OnboardingPage(onFinished: _completeOnboarding),
      );
    }

    // Main MaterialApp structure
    return MaterialApp(
      title: 'PhysicsEase',
      themeMode: _themeMode,
      theme: ThemeData(colorScheme: lightColorScheme, useMaterial3: true),
      darkTheme: ThemeData(colorScheme: darkColorScheme, useMaterial3: true),
      home: Builder(
        builder: (builderContext) => Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false, // Avoid resizing when keyboard opens
          appBar: null, // Custom top bar used instead
          drawer: Drawer(
            child: Column(
              children: [
                // Drawer header with app title
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: currentColorScheme.primaryContainer.withAlpha(200),
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset(
                        _themeMode == ThemeMode.dark
                            ? 'assets/my_logo_dark.png'
                            : 'assets/my_logo_light.png',
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image,
                            size: 120,
                            color: currentColorScheme.onPrimaryContainer,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Theme toggle option
                ListTile(
                  leading: Icon(
                    _themeMode == ThemeMode.light
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: currentColorScheme.primary,
                  ),
                  title: const Text('Tema'),
                  trailing: Switch(
                    value: _themeMode == ThemeMode.dark,
                    onChanged: (_) => _toggleTheme(),
                  ),
                ),

                // Help page link
                ListTile(
                  leading: Icon(Icons.help, color: currentColorScheme.primary),
                  title: const Text('Aiuto'),
                  onTap: () {
                    FocusScope.of(builderContext).unfocus();
                    Navigator.of(builderContext).pop();
                    Navigator.of(builderContext, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (innerContext) =>
                            HelpPage(themeMode: _themeMode),
                      ),
                    );
                  },
                ),

                // Collaborate page link
                ListTile(
                  leading: Icon(
                    Icons.handshake,
                    color: currentColorScheme.primary,
                  ),
                  title: const Text('Collabora'),
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

                // Info page link
                ListTile(
                  leading: Icon(Icons.info, color: currentColorScheme.primary),
                  title: const Text('Info'),
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

                // Privacy policy page link
                ListTile(
                  leading: Icon(
                    Icons.policy,
                    color: currentColorScheme.primary,
                  ),
                  title: const Text('Privacy Policy'),
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

                // License page link
                ListTile(
                  leading: Icon(
                    Icons.copyright,
                    color: currentColorScheme.primary,
                  ),
                  title: const Text('Licenza'),
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
                      onGenerateRoute: (routeSettings) {
                        return MaterialPageRoute(
                          builder: (innerContext) => _pages[index],
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
                  child: _buildFloatingNavBar(currentColorScheme),
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
