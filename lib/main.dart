// lib/main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:physics_ease_release/models/formula.dart';
import 'package:physics_ease_release/services/formula_service.dart';
import 'dart:developer' as developer;

import 'package:physics_ease_release/pages/home_page.dart';
import 'package:physics_ease_release/pages/favorites_page.dart';
import 'package:physics_ease_release/pages/calculator_page.dart';
import 'package:physics_ease_release/pages/tools_page.dart';
import 'package:physics_ease_release/pages/data_page.dart';
import 'package:physics_ease_release/pages/help_page.dart';
import 'package:physics_ease_release/pages/info_page.dart';
import 'package:physics_ease_release/pages/collaborate_page.dart';
import 'package:physics_ease_release/pages/privacy_policy_page.dart';
import 'package:physics_ease_release/pages/onboarding_page.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  Set<String> _favoriteIds = {};
  List<Formula> _allFormulas = [];
  List<Formula> _userFormulas = [];
  int _selectedIndex = 0;
  bool _loading = true;
  bool _showOnboarding = false;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  late final List<Widget> _pages;
  bool _showGlobalAppBar = true;

  @override
  void initState() {
    super.initState();
    _loadAllFormulasAndUserFormulas();
    _loadFavorites();
    _loadThemeMode();
    _pages = _buildPages();
    _checkOnboardingStatus();
  }


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
      _updateTabPages();
    });
  }

  Future<void> _loadAllFormulasAndUserFormulas() async {
    final loadedPredefinedFormulas = await FormulaService.loadAllFormulas();
    final prefs = await SharedPreferences.getInstance();
    final userFormulasJson = prefs.getStringList('userFormulas') ?? [];

    List<Formula> loadedUserFormulas = [];
    for (String jsonString in userFormulasJson) {
      try {
        loadedUserFormulas.add(Formula.fromJson(jsonString));
      } catch (e) {
        developer.log('Errore nel parsing della formula utente da SharedPreferences: $e');
      }
    }

    setState(() {
      _userFormulas = loadedUserFormulas;
      _allFormulas = [...loadedPredefinedFormulas, ..._userFormulas];
      developer.log('Caricate ${loadedPredefinedFormulas.length} formule predefinite.');
      developer.log('Caricate ${_userFormulas.length} formule aggiunte dall\'utente.');
      _updateTabPages();
    });
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;

    setState(() {
      _showOnboarding = !seen;
      _loading = false;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    setState(() {
      _showOnboarding = false;
    });
  }

  Future<void> _addFormulaAndSave(Formula newFormula) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userFormulas.add(newFormula);
      _allFormulas = [..._allFormulas, newFormula];
      developer.log('Aggiunta nuova formula: ${newFormula.titolo}. Formule totali: ${_allFormulas.length}');
    });

    final userFormulasJson = _userFormulas.map((f) => f.toJson()).toList();
    await prefs.setStringList('userFormulas', userFormulasJson);
    developer.log('Salvate ${_userFormulas.length} formule utente in SharedPreferences.');
    _updateTabPages();
  }

  List<Widget> _buildPages() {
    developer.log('Building _pages con preferiti: $_favoriteIds');
    return [
      HomePage(
        onToggleTheme: _toggleTheme,
        themeMode: _themeMode,
        allFormulas: _allFormulas,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        setGlobalAppBarVisibility: _setGlobalAppBarVisibility,
      ),
      FavoritesPage(
        allFormulas: _allFormulas,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        themeMode: _themeMode,
      ),
      const CalculatorPage(),
      const DataPage(),
      ToolsPage(
        onAddFormula: _addFormulaAndSave,
      ),
    ];
  }

  void _setGlobalAppBarVisibility(bool visible) {
    if (_showGlobalAppBar != visible) {
      setState(() {
        _showGlobalAppBar = visible;
      });
    }
  }

  void _updateTabPages() {
    setState(() {
      _pages[0] = HomePage(
        onToggleTheme: _toggleTheme,
        themeMode: _themeMode,
        allFormulas: _allFormulas,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        setGlobalAppBarVisibility: _setGlobalAppBarVisibility,
      );
      _pages[1] = FavoritesPage(
        allFormulas: _allFormulas,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        themeMode: _themeMode,
      );
      _pages[4] = ToolsPage(
        onAddFormula: _addFormulaAndSave,
      );
      developer.log('_updateTabPages chiamata. Preferiti attuali: $_favoriteIds, Tema attuale: $_themeMode');
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList('favorites') ?? [];
    setState(() {
      _favoriteIds = favList.toSet();
      developer.log('Caricati preferiti: $_favoriteIds');
      _updateTabPages();
    });
  }

  Future<void> _toggleFavorite(String formulaId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final newFavoriteIds = Set<String>.from(_favoriteIds);
      if (newFavoriteIds.contains(formulaId)) {
        newFavoriteIds.remove(formulaId);
        developer.log('Rimosso preferito: $formulaId. Nuovi preferiti: $newFavoriteIds');
      } else {
        newFavoriteIds.add(formulaId);
        developer.log('Aggiunto preferito: $formulaId. Nuovi preferiti: $newFavoriteIds');
      }
      _favoriteIds = newFavoriteIds;
    });
    await prefs.setStringList('favorites', _favoriteIds.toList());
    developer.log('Preferiti salvati in SharedPreferences: ${_favoriteIds.toList()}');
    _updateTabPages();
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;

      prefs.setString('themeMode', _themeMode == ThemeMode.dark ? 'dark' : 'light');
      developer.log('Tema cambiato in: $_themeMode. Salvato in SharedPreferences.');
      _updateTabPages();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      FocusScope.of(context).unfocus();

      if (_selectedIndex == index) {
        _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
        _setGlobalAppBarVisibility(true);
      } else {
        for (int i = 0; i < _navigatorKeys.length; i++) {
          if (i != index) {
            _navigatorKeys[i].currentState?.popUntil((route) => route.isFirst);
          }
        }
        _setGlobalAppBarVisibility(true);
        _selectedIndex = index;
      }
    });
  }

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
        return 'Tools';
      default:
        return 'PhysicsEase';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Definizione degli schemi di colore
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue[800]!,
      brightness: Brightness.dark,
    );
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue[600]!,
      brightness: Brightness.light,
    );
    final currentColorScheme = _themeMode == ThemeMode.dark ? darkColorScheme : lightColorScheme;

    if (_showOnboarding) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: lightColorScheme,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme,
          useMaterial3: true,
        ),
        themeMode: _themeMode,
        home: OnboardingPage(
          onFinished: _completeOnboarding,
        ),
      );
    }

    return MaterialApp(
      title: 'PhysicsEase',
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: lightColorScheme,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: true,
      ),
      home: Builder(
        builder: (builderContext) => Scaffold(
          appBar: _showGlobalAppBar
              ? AppBar(
            title: Text(_getCurrentAppBarTitle()),
            backgroundColor: currentColorScheme.primaryContainer,
            iconTheme: IconThemeData(color: currentColorScheme.onPrimaryContainer),
          )
              : null,
          drawer: Drawer(
            child: Column(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: currentColorScheme.primaryContainer),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.science, size: 40, color: currentColorScheme.onPrimaryContainer),
                      const SizedBox(width: 16),
                      Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: currentColorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(
                    _themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
                    color: currentColorScheme.primary,
                  ),
                  title: const Text('Tema'),
                  trailing: Switch(
                    value: _themeMode == ThemeMode.dark,
                    onChanged: (_) => _toggleTheme(),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.help, color: currentColorScheme.primary),
                  title: const Text('Aiuto'),
                  onTap: () {
                    FocusScope.of(builderContext).unfocus();
                    Navigator.of(builderContext).pop();
                    Navigator.of(builderContext, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (innerContext) => HelpPage(themeMode: _themeMode),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.handshake, color: currentColorScheme.primary),
                  title: const Text('Collabora'),
                  onTap: () {
                    FocusScope.of(builderContext).unfocus();
                    Navigator.of(builderContext).pop();
                    Navigator.of(builderContext, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (innerContext) => CollaboratePage(themeMode: _themeMode),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info, color: currentColorScheme.primary),
                  title: const Text('Info'),
                  onTap: () {
                    FocusScope.of(builderContext).unfocus();
                    Navigator.of(builderContext).pop();
                    Navigator.of(builderContext, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (innerContext) => InfoPage(themeMode: _themeMode),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.policy, color: currentColorScheme.primary),
                  title: const Text('Privacy Policy'),
                  onTap: () {
                    FocusScope.of(builderContext).unfocus();
                    Navigator.of(builderContext).pop();
                    Navigator.of(builderContext, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (innerContext) => PrivacyPolicyPage(themeMode: _themeMode),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          body: PopScope( //WillPopScope dava problem con gli allert e non era più supportato con le ultime versioni di android (predict del pop)
            canPop: false,
            onPopInvokedWithResult: (bool didPop, dynamic result) async {
              if (didPop) {
                return;
              }
              FocusScope.of(context).unfocus();
              final NavigatorState currentNavigator = _navigatorKeys[_selectedIndex].currentState!;
              print('onPopInvoked chiamato per indice: $_selectedIndex');
              print('currentNavigator.canPop(): ${currentNavigator.canPop()}');
              if (currentNavigator.canPop()) {
                print('Eseguo pop su currentNavigator (torno indietro nella tab)');
                currentNavigator.pop();
              } else {
                print('currentNavigator NON può poppare. Richiesta di chiusura dell\'app.');
                SystemNavigator.pop();
              }
            },
            child: IndexedStack(
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
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Preferiti'),
              BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calcolatrice'),
              BottomNavigationBarItem(icon: Icon(Icons.storage), label: 'Dati'),
              BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Tools'),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: currentColorScheme.primary,
            unselectedItemColor: currentColorScheme.onSurfaceVariant,
            backgroundColor: currentColorScheme.surfaceContainer,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}

/*
MAIN SENZA ONBOARDING
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:physics_ease_release/models/formula.dart';
import 'package:physics_ease_release/services/formula_service.dart';
import 'dart:developer' as developer;

import 'package:physics_ease_release/pages/home_page.dart';
import 'package:physics_ease_release/pages/favorites_page.dart';
import 'package:physics_ease_release/pages/calculator_page.dart';
import 'package:physics_ease_release/pages/tools_page.dart';
import 'package:physics_ease_release/pages/data_page.dart';
import 'package:physics_ease_release/pages/help_page.dart';
import 'package:physics_ease_release/pages/info_page.dart';
import 'package:physics_ease_release/pages/collaborate_page.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  Set<String> _favoriteIds = {};
  List<Formula> _allFormulas = [];
  List<Formula> _userFormulas = [];
  int _selectedIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  late final List<Widget> _pages;
  bool _showGlobalAppBar = true;

  @override
  void initState() {
    super.initState();
    _loadAllFormulasAndUserFormulas();
    _loadFavorites();
    _loadThemeMode();
    _pages = _buildPages();
  }


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
      _updateTabPages();
    });
  }

  Future<void> _loadAllFormulasAndUserFormulas() async {
    final loadedPredefinedFormulas = await FormulaService.loadAllFormulas();
    final prefs = await SharedPreferences.getInstance();
    final userFormulasJson = prefs.getStringList('userFormulas') ?? [];

    List<Formula> loadedUserFormulas = [];
    for (String jsonString in userFormulasJson) {
      try {
        loadedUserFormulas.add(Formula.fromJson(jsonString));
      } catch (e) {
        developer.log('Errore nel parsing della formula utente da SharedPreferences: $e');
      }
    }

    setState(() {
      _userFormulas = loadedUserFormulas;
      _allFormulas = [...loadedPredefinedFormulas, ..._userFormulas];
      developer.log('Caricate ${loadedPredefinedFormulas.length} formule predefinite.');
      developer.log('Caricate ${_userFormulas.length} formule aggiunte dall\'utente.');
      _updateTabPages();
    });
  }

  Future<void> _addFormulaAndSave(Formula newFormula) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userFormulas.add(newFormula);
      _allFormulas = [..._allFormulas, newFormula];
      developer.log('Aggiunta nuova formula: ${newFormula.titolo}. Formule totali: ${_allFormulas.length}');
    });

    final userFormulasJson = _userFormulas.map((f) => f.toJson()).toList();
    await prefs.setStringList('userFormulas', userFormulasJson);
    developer.log('Salvate ${_userFormulas.length} formule utente in SharedPreferences.');
    _updateTabPages();
  }

  List<Widget> _buildPages() {
    developer.log('Building _pages con preferiti: $_favoriteIds');
    return [
      HomePage(
        onToggleTheme: _toggleTheme,
        themeMode: _themeMode,
        allFormulas: _allFormulas,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        setGlobalAppBarVisibility: _setGlobalAppBarVisibility,
      ),
      FavoritesPage(
        allFormulas: _allFormulas,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        themeMode: _themeMode,
      ),
      const CalculatorPage(),
      const DataPage(),
      ToolsPage(
        onAddFormula: _addFormulaAndSave,
      ),
    ];
  }

  void _setGlobalAppBarVisibility(bool visible) {
    if (_showGlobalAppBar != visible) {
      setState(() {
        _showGlobalAppBar = visible;
      });
    }
  }

  void _updateTabPages() {
    setState(() {
      _pages[0] = HomePage(
        onToggleTheme: _toggleTheme,
        themeMode: _themeMode,
        allFormulas: _allFormulas,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        setGlobalAppBarVisibility: _setGlobalAppBarVisibility,
      );
      _pages[1] = FavoritesPage(
        allFormulas: _allFormulas,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        themeMode: _themeMode,
      );
      _pages[4] = ToolsPage(
        onAddFormula: _addFormulaAndSave,
      );
      developer.log('_updateTabPages chiamata. Preferiti attuali: $_favoriteIds, Tema attuale: $_themeMode');
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList('favorites') ?? [];
    setState(() {
      _favoriteIds = favList.toSet();
      developer.log('Caricati preferiti: $_favoriteIds');
      _updateTabPages();
    });
  }

  Future<void> _toggleFavorite(String formulaId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final newFavoriteIds = Set<String>.from(_favoriteIds);
      if (newFavoriteIds.contains(formulaId)) {
        newFavoriteIds.remove(formulaId);
        developer.log('Rimosso preferito: $formulaId. Nuovi preferiti: $newFavoriteIds');
      } else {
        newFavoriteIds.add(formulaId);
        developer.log('Aggiunto preferito: $formulaId. Nuovi preferiti: $newFavoriteIds');
      }
      _favoriteIds = newFavoriteIds;
    });
    await prefs.setStringList('favorites', _favoriteIds.toList());
    developer.log('Preferiti salvati in SharedPreferences: ${_favoriteIds.toList()}');
    _updateTabPages();
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;

      prefs.setString('themeMode', _themeMode == ThemeMode.dark ? 'dark' : 'light');
      developer.log('Tema cambiato in: $_themeMode. Salvato in SharedPreferences.');
      _updateTabPages();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      FocusScope.of(context).unfocus();

      if (_selectedIndex == index) {
        _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
        _setGlobalAppBarVisibility(true);
      } else {
        for (int i = 0; i < _navigatorKeys.length; i++) {
          if (i != index) {
            _navigatorKeys[i].currentState?.popUntil((route) => route.isFirst);
          }
        }
        _setGlobalAppBarVisibility(true);
        _selectedIndex = index;
      }
    });
  }

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
        return 'Tools';
      default:
        return 'PhysicsEase';
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue[800]!,
      brightness: Brightness.dark,
    );
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue[600]!,
      brightness: Brightness.light,
    );
    final currentColorScheme = _themeMode == ThemeMode.dark ? darkColorScheme : lightColorScheme;

    return MaterialApp(
      title: 'PhysicsEase',
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: lightColorScheme,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: true,
      ),
      home: Builder(
        builder: (builderContext) => Scaffold(
          appBar: _showGlobalAppBar
              ? AppBar(
            title: Text(_getCurrentAppBarTitle()),
            backgroundColor: currentColorScheme.primaryContainer,
            iconTheme: IconThemeData(color: currentColorScheme.onPrimaryContainer),
          )
              : null,
          drawer: Drawer(
            child: Column(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: currentColorScheme.primaryContainer),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.science, size: 40, color: currentColorScheme.onPrimaryContainer),
                      const SizedBox(width: 16),
                      Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: currentColorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(
                    _themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
                    color: currentColorScheme.primary,
                  ),
                  title: const Text('Tema'),
                  trailing: Switch(
                    value: _themeMode == ThemeMode.dark,
                    onChanged: (_) => _toggleTheme(),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.help, color: currentColorScheme.primary),
                  title: const Text('Aiuto'),
                  onTap: () {
                    FocusScope.of(builderContext).unfocus();
                    Navigator.of(builderContext).pop();
                    Navigator.of(builderContext, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (innerContext) => HelpPage(themeMode: _themeMode),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.handshake, color: currentColorScheme.primary),
                  title: const Text('Collabora'),
                  onTap: () {
                    FocusScope.of(builderContext).unfocus();
                    Navigator.of(builderContext).pop();
                    Navigator.of(builderContext, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (innerContext) => CollaboratePage(themeMode: _themeMode),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info, color: currentColorScheme.primary),
                  title: const Text('Info'),
                  onTap: () {
                    FocusScope.of(builderContext).unfocus();
                    Navigator.of(builderContext).pop();
                    Navigator.of(builderContext, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (innerContext) => InfoPage(themeMode: _themeMode),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          body: PopScope( //WillPopScope dava problem con gli allert e non era più supportato con le ultime versioni di android (predict del pop)
            canPop: false,
            onPopInvokedWithResult: (bool didPop, dynamic result) async {
              if (didPop) {
                return;
              }
              FocusScope.of(context).unfocus();
              final NavigatorState currentNavigator = _navigatorKeys[_selectedIndex].currentState!;
              print('onPopInvoked chiamato per indice: $_selectedIndex');
              print('currentNavigator.canPop(): ${currentNavigator.canPop()}');
              if (currentNavigator.canPop()) {
                print('Eseguo pop su currentNavigator (torno indietro nella tab)');
                currentNavigator.pop();
              } else {
                print('currentNavigator NON può poppare. Richiesta di chiusura dell\'app.');
                SystemNavigator.pop();
              }
            },
            child: IndexedStack(
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
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Preferiti'),
              BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calcolatrice'),
              BottomNavigationBarItem(icon: Icon(Icons.storage), label: 'Dati'),
              BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Tools'),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: currentColorScheme.primary,
            unselectedItemColor: currentColorScheme.onSurfaceVariant,
            backgroundColor: currentColorScheme.surfaceContainer,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}
 */