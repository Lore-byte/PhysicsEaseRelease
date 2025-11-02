import 'package:flutter/material.dart';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';

enum SortOrder { ascending, descending }

class FamousPhysicistsPage extends StatefulWidget {
  const FamousPhysicistsPage({super.key});

  @override
  State<FamousPhysicistsPage> createState() => _FamousPhysicistsPageState();
}

class _FamousPhysicistsPageState extends State<FamousPhysicistsPage> {
  static const List<Map<String, dynamic>> _allPhysicists = [
    {
      'name': 'Robert Hooke',
      'period': '1635 – 1703',
      'birthYear': 1635,
      'bio': 'Scienziato inglese poliedrico, contribuì alla meccanica, all\'elasticità e alla microscopia, ed è noto per la legge di Hooke sull\'elasticità.',
      'discoveries': ['Legge di Hooke (elasticità)', 'Miglioramenti alla microscopia'],
      'curiosities': ['Fu contemporaneo e talvolta rivale di Newton.', 'Il suo libro "Micrographia" rese popolare il termine "cellula".'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Christiaan Huygens',
      'period': '1629 – 1695',
      'birthYear': 1629,
      'bio': 'Fisico e matematico olandese, sviluppò la teoria ondulatoria della luce e importanti risultati sulla meccanica e l\'orologeria.',
      'discoveries': ['Teoria ondulatoria della luce', 'Pendolo isocrono', 'Anelli di Saturno e luna Titano'],
      'curiosities': ['Inventò l\'orologio a pendolo per migliorare la misura del tempo.', 'Scrisse il "Traité de la lumière".'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Daniel Bernoulli',
      'period': '1700 – 1782',
      'birthYear': 1700,
      'bio': 'Matematico e fisico svizzero, noto per la meccanica dei fluidi e contributi alla teoria cinetica dei gas.',
      'discoveries': ['Principio di Bernoulli', 'Teoria cinetica qualitativa dei gas'],
      'curiosities': ['Vinse più volte il premio dell\'Accademia di Parigi.', 'Proveniva da una famosa famiglia di matematici.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Leonhard Euler',
      'period': '1707 – 1783',
      'birthYear': 1707,
      'bio': 'Uno dei massimi matematici, contribuì enormemente anche alla meccanica e all\'ottica, formalizzando strumenti fondamentali per la fisica.',
      'discoveries': ['Equazioni di Eulero per fluidi', 'Meccanica dei corpi rigidi', 'Ottica geometrica'],
      'curiosities': ['Produsse opere monumentali nonostante gravi problemi alla vista.', 'Introdusse molta notazione moderna.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Henry Cavendish',
      'period': '1731 – 1810',
      'birthYear': 1731,
      'bio': 'Fisico e chimico inglese, misurò la densità della Terra e studiò elettricità e gas con straordinaria precisione sperimentale.',
      'discoveries': ['Esperimento della bilancia di torsione (densità della Terra)', 'Idrogeno come sostanza distinta'],
      'curiosities': ['Era notoriamente riservato e pubblicò poco.', 'Le sue carte inedite rivelarono scoperte anticipate.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Charles-Augustin de Coulomb',
      'period': '1736 – 1806',
      'birthYear': 1736,
      'bio': 'Fisico francese, formulò la legge fondamentale dell\'interazione elettrica e magnetica tra cariche e poli.',
      'discoveries': ['Legge di Coulomb', 'Uso della bilancia di torsione'],
      'curiosities': ['Il suo nome è unità SI della carica elettrica.', 'Servì come ingegnere militare.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Michael Faraday',
      'period': '1791 – 1867',
      'birthYear': 1791,
      'bio': 'Pioniere dell\'elettromagnetismo, scoprì l\'induzione elettromagnetica e pose le basi concettuali di campo e linee di forza.',
      'discoveries': ['Induzione elettromagnetica', 'Leggi dell\'elettrolisi', 'Effetto Faraday'],
      'curiosities': ['Autodidatta senza formazione universitaria formale.', 'Le sue "Researches in Electricity" influenzarono Maxwell.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'James Clerk Maxwell',
      'period': '1831 – 1879',
      'birthYear': 1831,
      'bio': 'Unificò elettricità, magnetismo e luce nelle celebri equazioni, fondando l\'elettromagnetismo classico.',
      'discoveries': ['Equazioni di Maxwell', 'Teoria elettromagnetica della luce', 'Distribuzione di Maxwell-Boltzmann'],
      'curiosities': ['Formalizzò matematicamente le idee di Faraday.', 'Contribuì alla fisica statistica.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Heinrich Hertz',
      'period': '1857 – 1894',
      'birthYear': 1857,
      'bio': 'Fisico tedesco che dimostrò sperimentalmente l\'esistenza delle onde elettromagnetiche previste da Maxwell.',
      'discoveries': ['Onde radio', 'Risonanza elettromagnetica'],
      'curiosities': ['L\'unità "hertz" misura la frequenza.', 'Mostrò che le onde radio riflettono e rifrangono come la luce.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Max Planck',
      'period': '1858 – 1947',
      'birthYear': 1858,
      'bio': 'Fondatore della teoria dei quanti introducendo la quantizzazione dell\'energia per spiegare la radiazione del corpo nero.',
      'discoveries': ['Quantizzazione dell\'energia', 'Costante di Planck'],
      'curiosities': ['Nobel 1918 per l\'originaria teoria dei quanti.', 'Inizialmente scettico sulle implicazioni della quantizzazione.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Marie Curie',
      'period': '1867 – 1934',
      'birthYear': 1867,
      'bio': 'Pioniera degli studi sulla radioattività, scoprì il polonio e il radio e fu la prima persona a vincere due Nobel.',
      'discoveries': ['Radio e polonio', 'Tecniche di isolamento di elementi radioattivi'],
      'curiosities': ['Nobel in Fisica e in Chimica.', 'Lavorò in condizioni oggi ritenute pericolose.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Ernest Rutherford',
      'period': '1871 – 1937',
      'birthYear': 1871,
      'bio': 'Padre della fisica nucleare, propose il modello nucleare dell\'atomo e identificò decadimenti alfa e beta.',
      'discoveries': ['Modello nucleare atomico', 'Decadimento radioattivo', 'Trasmutazione artificiale'],
      'curiosities': ['Nobel in Chimica 1908.', 'Il suo laboratorio formò molte future figure chiave.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Albert Einstein',
      'period': '1879 – 1955',
      'birthYear': 1879,
      'bio': 'Autore della relatività ristretta e generale e della spiegazione dell\'effetto fotoelettrico, contribuì anche alla meccanica statistica.',
      'discoveries': ['Relatività ristretta e generale', 'Effetto fotoelettrico', 'Moto browniano'],
      'curiosities': ['Nobel 1921 per l\'effetto fotoelettrico.', 'Partecipò ai Congressi Solvay con i pionieri dei quanti.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Niels Bohr',
      'period': '1885 – 1962',
      'birthYear': 1885,
      'bio': 'Sviluppò il modello quantizzato dell\'atomo e l\'idea di complementarità nella meccanica quantistica.',
      'discoveries': ['Modello atomico di Bohr', 'Complementarità'],
      'curiosities': ['Figura centrale della Scuola di Copenaghen.', 'Mentore di molti fisici del XX secolo.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Erwin Schrödinger',
      'period': '1887 – 1961',
      'birthYear': 1887,
      'bio': 'Formulò la meccanica ondulatoria e l\'equazione che porta il suo nome, cardine della fisica quantistica.',
      'discoveries': ['Equazione di Schrödinger', 'Meccanica ondulatoria'],
      'curiosities': ['Dimostrò l\'equivalenza con la meccanica matriciale.', 'Il famoso "gatto di Schrödinger" è un paradosso concettuale.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Wolfgang Pauli',
      'period': '1900 – 1958',
      'birthYear': 1900,
      'bio': 'Introdusse il principio di esclusione e contribuì ai fondamenti della teoria quantistica e della fisica delle particelle.',
      'discoveries': ['Principio di esclusione', 'Neutrino (ipotesi originaria)'],
      'curiosities': ['Nobel 1945 per il principio di esclusione.', 'Conosciuto per la critica severa ma brillante.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Werner Heisenberg',
      'period': '1901 – 1976',
      'birthYear': 1901,
      'bio': 'Padre della meccanica matriciale e del principio di indeterminazione, fu tra i leader della nascita della MQ.',
      'discoveries': ['Principio di indeterminazione', 'Meccanica matriciale'],
      'curiosities': ['Nobel 1932.', 'Figura centrale della "Copenaghen" assieme a Bohr.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Paul Dirac',
      'period': '1902 – 1984',
      'birthYear': 1902,
      'bio': 'Formulò l\'equazione di Dirac che unisce meccanica quantistica e relatività ristretta e prevede l\'antimateria.',
      'discoveries': ['Equazione di Dirac', 'Previsione del positrone', 'QED primitiva'],
      'curiosities': ['Nobel 1933 con Schrödinger.', 'Stile estremamente conciso e rigoroso.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Enrico Fermi',
      'period': '1901 – 1954',
      'birthYear': 1901,
      'bio': 'Contributi fondamentali alla meccanica statistica, alla fisica dei neutroni e alla realizzazione del primo reattore nucleare.',
      'discoveries': ['Statistica di Fermi-Dirac', 'Primo reattore nucleare a fissione', 'Teoria del beta'],
      'curiosities': ['Nobel 1938.', 'Unità di lunghezza nucleare "fermi" a lui dedicata.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Richard Feynman',
      'period': '1918 – 1988',
      'birthYear': 1918,
      'bio': 'Tra i padri dell\'elettrodinamica quantistica, introdusse i diagrammi che portano il suo nome e un approccio path integral.',
      'discoveries': ['QED', 'Diagrammi di Feynman', 'Integrale sui cammini'],
      'curiosities': ['Nobel 1965 con Schwinger e Tomonaga.', 'Celebre divulgatore e problem solver.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Abdus Salam',
      'period': '1926 – 1996',
      'birthYear': 1926,
      'bio': 'Co-artefice dell\'unificazione elettrodebole, contribuì in modo decisivo al Modello Standard.',
      'discoveries': ['Teoria elettrodebole (con Weinberg e Glashow)'],
      'curiosities': ['Primo pakistano a vincere il Nobel (1979).', 'Fondò l\'ICTP a Trieste.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Steven Weinberg',
      'period': '1933 – 2021',
      'birthYear': 1933,
      'bio': 'Coautore della teoria elettrodebole, chiave del Modello Standard e della fisica delle particelle moderna.',
      'discoveries': ['Teoria elettrodebole', 'Meccanismo di rottura di simmetria'],
      'curiosities': ['Nobel 1979 con Salam e Glashow.', 'Autore di influenti testi divulgativi.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
    {
      'name': 'Peter Higgs',
      'period': '1929 – 2024',
      'birthYear': 1929,
      'bio': 'Propose il meccanismo di Higgs per l\'origine delle masse delle particelle, culminato nell\'osservazione del bosone di Higgs al CERN.',
      'discoveries': ['Meccanismo di Higgs', 'Bosone di Higgs (predetto)'],
      'curiosities': ['Nobel 2013 con Englert.', 'LHC osservò la particella nel 2012.'],
      'imageUrl': 'assets/fisici/robert_hooke.jpg',
    },
  ];

  List<Map<String, dynamic>> _filteredPhysicists = [];
  SortOrder _sortOrder = SortOrder.ascending;

  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<bool> _searchBarVisible = ValueNotifier<bool>(false);
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _filteredPhysicists = List.from(_allPhysicists);
    _updateList();
    _searchController.addListener(_updateList);
    _searchFocusNode = FocusNode();

    _searchBarVisible.addListener(_onSearchVisibilityChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_updateList);
    _searchController.dispose();
    _searchBarVisible.removeListener(_onSearchVisibilityChanged);
    _searchBarVisible.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchVisibilityChanged() {
    if (!_searchBarVisible.value) {
      _resetSearchAndFocus();
    }
  }

  void _resetSearchAndFocus() {
    if (_searchController.text.isNotEmpty || _searchFocusNode.hasFocus) {
      _searchController.clear();
      _updateList();
      _searchFocusNode.unfocus();
    }
  }

  void _updateList() {
    setState(() {
      final query = _searchController.text.toLowerCase();

      List<Map<String, dynamic>> results = _allPhysicists
          .where((physicist) =>
      physicist['name'].toLowerCase().contains(query) ||
          physicist['bio'].toLowerCase().contains(query) ||
          (physicist['discoveries'] as List<String>)
              .any((d) => d.toLowerCase().contains(query)))
          .toList();

      results.sort((a, b) {
        final yearA = a['birthYear'] as int;
        final yearB = b['birthYear'] as int;
        return _sortOrder == SortOrder.ascending ? yearA.compareTo(yearB) : yearB.compareTo(yearA);
      });

      _filteredPhysicists = results;
    });
  }

  void _toggleSortOrder() {
    setState(() {
      _sortOrder = _sortOrder == SortOrder.ascending  ? SortOrder.descending : SortOrder.ascending;
      _updateList();
    });
  }

  IconData _getSortIcon() {
    return _sortOrder == SortOrder.ascending ? Icons.arrow_upward : Icons.arrow_downward;
  }

  Widget _buildSection(
      {required BuildContext context,
        required String title,
        required dynamic content}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const Divider(thickness: 1, height: 16),
          if (content is String) Text(content, style: textTheme.bodyLarge),
          if (content is List<String>)
            ...content
                .map((item) => Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: textTheme.bodyLarge),
                  Expanded(
                    child: Text(item, style: textTheme.bodyLarge),
                  ),
                ],
              ),
            ))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildPhysicistImage(
      {required String imageUrl, required double size, required bool isCard}) {
    final bool isAsset = imageUrl.startsWith('assets/');
    final fallbackIcon = Icon(Icons.person, size: size * 0.5, color: Colors.grey);

    final double width = isCard ? size : double.infinity;
    final double height = isCard ? size : 200;
    final BoxFit fit = isCard ? BoxFit.cover : BoxFit.contain;

    Widget imageWidget;

    imageWidget = Image.asset(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return fallbackIcon;
      },
    );

    if (isCard) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: ClipOval(child: imageWidget),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageWidget,
      );
    }
  }

  void _showPhysicistDetailsDialog(
      BuildContext context, Map<String, dynamic> physicist) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            physicist['name'] as String,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildPhysicistImage(
                    imageUrl: physicist['imageUrl'] as String,
                    size: 200,
                    isCard: false,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    physicist['period'] as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  _buildSection(
                    context: context,
                    title: 'Biografia',
                    content: physicist['bio'] as String,
                  ),
                  _buildSection(
                    context: context,
                    title: 'Scoperte Importanti',
                    content: physicist['discoveries'] as List<String>,
                  ),
                  _buildSection(
                    context: context,
                    title: 'Curiosità',
                    content: physicist['curiosities'] as List<String>,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Chiudi'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPhysicistCard(
      {required BuildContext context, required Map<String, dynamic> physicist}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showPhysicistDetailsDialog(context, physicist),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildPhysicistImage(
                imageUrl: physicist['imageUrl'] as String,
                size: 60,
                isCard: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      physicist['name'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      physicist['period'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double fixedTopBarHeight = MediaQuery.of(context).viewPadding.top + 70;

    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Column(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: _searchBarVisible,
                builder: (context, visible, _) {
                  if (!visible) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: EdgeInsets.only(
                      top: fixedTopBarHeight,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) {
                        FocusScope.of(context).unfocus();
                      },
                      decoration: InputDecoration(
                        hintText: 'Cerca per nome, bio o scoperta...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(
                            Icons.backspace_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: _resetSearchAndFocus,
                        )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.outline,
                          ),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _searchBarVisible,
                  builder: (context, searchVisible, _) {
                    final topListPadding =
                    searchVisible ? 0.0 : fixedTopBarHeight;

                    if (_filteredPhysicists.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 60,
                                color: colorScheme.onSurfaceVariant
                                    .withOpacity(0.6)),
                            const SizedBox(height: 16),
                            Text(
                              'Nessun fisico trovato.',
                              style: TextStyle(
                                fontSize: 18,
                                color: colorScheme.onSurfaceVariant
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.only(
                        top: topListPadding,
                        bottom: MediaQuery.of(context).viewPadding.bottom + 98,
                        left: 16,
                        right: 16,
                      ),
                      itemCount: _filteredPhysicists.length,
                      separatorBuilder: (context, index) =>
                      const SizedBox(height: 8.0),
                      itemBuilder: (context, index) {
                        final physicist = _filteredPhysicists[index];
                        return _buildPhysicistCard(
                            context: context, physicist: physicist);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).viewPadding.top,
            left: 16,
            right: 16,
            child: FloatingTopBar(
              title: 'Fisici',
              leading: FloatingTopBarLeading.back,
              onBackPressed: () => Navigator.of(context).maybePop(),
              showSearch: true,
              searchVisible: _searchBarVisible,
              showOrdinamento: true,
              ordinamentoIcon: _getSortIcon(),
              onOrdinamentoPressed: _toggleSortOrder,
            ),
          ),
        ],
      ),
    );
  }
}
