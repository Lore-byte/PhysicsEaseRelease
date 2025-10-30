// lib/pages/constants_list_page.dart
import 'package:flutter/material.dart';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';

class ConstantsListPage extends StatefulWidget {
  @override
  State<ConstantsListPage> createState() => _ConstantsListPageState();
}

class _ConstantsListPageState extends State<ConstantsListPage> {
  final List<Map<String, String>> _allConstants = [
    {
      'name': 'Velocità della luce (c)',
      'value': '299,792,458 m/s',
      'info': 'È la velocità massima a cui può viaggiare qualsiasi informazione o energia nell\'universo. Il suo valore esatto è definito, non misurato, e serve a definire il metro.'
    },
    {
      'name': 'Costante di Planck (h)',
      'value': '6.62607015 × 10^-34 J⋅s',
      'info': 'Un concetto fondamentale della meccanica quantistica, che mette in relazione l\'energia dei fotoni con la loro frequenza. Planck la introdusse per risolvere il problema della radiazione di corpo nero.'
    },
    {
      'name': 'Carica elementare (e)',
      'value': '1.602176634 × 10^-19 C',
      'info': 'È la carica elettrica di un singolo protone o, con segno negativo, di un singolo elettrone. È la più piccola carica libera osservabile in natura.'
    },
    {
      'name': 'Costante gravitazionale (G)',
      'value': '6.67430 × 10^-11 N⋅m²/kg²',
      'info': 'Determina la forza di attrazione gravitazionale tra due oggetti massivi. È una delle costanti più difficili da misurare con alta precisione a causa della debolezza della gravità.'
    },
    {
      'name': 'Massa dell\'elettrone (me)',
      'value': '9.1093837015 × 10^-31 kg',
      'info': 'La massa di una delle particelle subatomiche più leggere, l\'elettrone. È usata in molte formule dell\'elettromagnetismo e della meccanica quantistica.'
    },
    {
      'name': 'Numero di Avogadro (NA)',
      'value': '6.02214076 × 10^23 mol^-1',
      'info': 'Il numero di particelle (atomi, molecole, ioni, ecc.) contenute in una mole di una sostanza. Fondamentale in chimica per correlare massa e quantità di sostanza.'
    },
    {
      'name': 'Costante dei gas (R)',
      'value': '8.314462618 J/(mol⋅K)',
      'info': 'Conosciuta anche come costante universale dei gas, appare nell\'equazione di stato dei gas ideali, PV=nRT, mettendo in relazione pressione, volume, temperatura e quantità di gas.'
    },
    {
      'name': 'Costante di Boltzmann (kB)',
      'value': '1.380649 × 10^-23 J/K',
      'info': 'Collega l\'energia cinetica delle particelle in un gas alla temperatura del gas stesso. È il ponte tra la fisica microscopica e quella macroscopica (termodinamica).'
    },
    {
      'name': 'Permittività dello spazio libero (ε₀)',
      'value': '8.8541878128 × 10^-12 F/m',
      'info': 'Descrive quanto un campo elettrico "passa" attraverso il vuoto. Fondamentale nelle leggi di Maxwell per l\'elettromagnetismo.'
    },
    {
      'name': 'Permeabilità dello spazio libero (μ₀)',
      'value': '4π × 10^-7 N/A²',
      'info': 'Indica quanto il vuoto permette la formazione di un campo magnetico. Insieme a ε₀, determina la velocità della luce nel vuoto.'
    },
    {
      'name': 'Massa del protone (mp)',
      'value': '1.67262192369 × 10^-27 kg',
      'info': 'La massa di un protone, una delle particelle fondamentali che compongono i nuclei atomici. È circa 1836 volte la massa dell\'elettrone.'
    },
    {
      'name': 'Massa del neutrone (mn)',
      'value': '1.67492749804 × 10^-27 kg',
      'info': 'La massa di un neutrone, un\'altra particella che forma il nucleo atomico. È leggermente più grande della massa del protone.'
    },
    {
      'name': 'Costante di Faraday (F)',
      'value': '96,485.33212 C/mol',
      'info': 'La quantità di carica elettrica trasportata da una mole di elettroni. È cruciale in elettrochimica per calcolare la quantità di sostanza prodotta o consumata in reazioni elettrolitiche.'
    },
    {
      'name': 'Frequenza di transizione iperfine del cesio-133 (ΔνCs)',
      'value': '9,192,631,770 Hz',
      'info': 'La frequenza esatta di una transizione atomica specifica del cesio-133, usata per definire il secondo nel Sistema Internazionale di Unità di Misura. È la base degli orologi atomici.'
    },
    {
      'name': 'Costante di Stefan–Boltzmann (σ)',
      'value': '5.670374419 × 10^-8 W/m²⋅K⁴',
      'info': 'Relaziona la potenza totale irradiata per unità di superficie da un corpo nero alla quarta potenza della sua temperatura termodinamica. Usata per calcolare l\'energia emessa dalle stelle.'
    },
    {
      'name': 'Costante di Rydberg (R∞)',
      'value': '10,973,731.568160 m⁻¹',
      'info': 'Una costante fisica che appare nelle formule per le lunghezze d\'onda della luce emessa dagli atomi di idrogeno. È fondamentale per la spettroscopia atomica.'
    },
    {
      'name': 'Costante atomica di massa (mu)',
      'value': '1.66053906660 × 10^-27 kg',
      'info': 'Definita come un dodicesimo della massa di un atomo di carbonio-12 non legato nel suo stato fondamentale. Usata per esprimere le masse atomiche relative.'
    },
    {
      'name': 'Unità astronomica (AU)',
      'value': '149,597,870,700 m',
      'info': 'La distanza media tra la Terra e il Sole. Usata per misurare le distanze all\'interno del Sistema Solare.'
    },
    {
      'name': 'Anno luce',
      'value': '9.4607 × 10^15 m',
      'info': 'La distanza che la luce percorre in un anno nel vuoto. Unità di misura comune per le distanze astronomiche al di fuori del Sistema Solare.'
    },
    {
      'name': 'Parsec',
      'value': '3.0857 × 10^16 m',
      'info': 'Un\'unità di lunghezza usata in astronomia, equivalente alla distanza alla quale un\'unità astronomica sottende un angolo di un secondo d\'arco. Circa 3.26 anni luce.'
    },
    {
      'name': 'Costante di struttura fine (α)',
      'value': '1/137.035999084',
      'info': 'Una costante adimensionale che caratterizza l\'intensità dell\'interazione elettromagnetica. È una delle costanti fondamentali più misteriose della fisica.'
    },
    {
      'name': 'Tempo di Planck (tp)',
      'value': '5.391247 × 10^-44 s',
      'info': 'L\'unità di tempo più piccola che abbia significato nella fisica teorica. Si pensa che eventi su scale temporali inferiori al tempo di Planck siano inosservabili o non definibili.'
    },
    {
      'name': 'Lunghezza di Planck (lp)',
      'value': '1.616255 × 10^-35 m',
      'info': 'La scala di lunghezza più piccola con significato fisico. A queste scale, gli effetti della gravità quantistica diventano significativi.'
    },
    {
      'name': 'Massa di Planck (mp)',
      'value': '2.176434 × 10^-8 kg',
      'info': 'La massa più grande che abbia significato nella fisica delle particelle senza che gli effetti gravitazionali quantistici diventino dominanti.'
    },
    {
      'name': 'Carica di Planck',
      'value': '1.875545956 × 10^-18 C',
      'info': 'L\'unità naturale di carica elettrica nel sistema di unità di Planck. È correlata alla carica elementare e alla costante di struttura fine.'
    },
    {
      'name': 'Pressione atmosferica standard',
      'value': '101,325 Pa',
      'info': 'La pressione esercitata dall\'atmosfera terrestre al livello del mare. Usata come riferimento in molte applicazioni scientifiche e ingegneristiche.'
    },
    {
      'name': 'Accelerazione gravitazionale (g)',
      'value': '9.80665 m/s²',
      'info': 'L\'accelerazione che un oggetto subisce a causa della gravità terrestre al livello del mare. Varia leggermente a seconda della posizione geografica.'
    },
  ];

  List<Map<String, String>> _filteredConstants = [];
  final TextEditingController _searchController = TextEditingController();

  final ValueNotifier<bool> _searchBarVisible = ValueNotifier<bool>(false);
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _filteredConstants = _allConstants;
    _searchController.addListener(_filterConstants);
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterConstants);
    _searchController.dispose();
    _searchBarVisible.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _filterConstants() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredConstants = _allConstants.where((constant) {
        return constant['name']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _resetSearchAndFocus() {
    _searchController.clear();
    _filterConstants(); // con query vuota torna alla lista completa
    _searchFocusNode.unfocus();
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          // Contenuto: search bar a scomparsa + lista
          Column(
            children: [
              // Barra di ricerca a scomparsa come in Home
              ValueListenableBuilder<bool>(
                valueListenable: _searchBarVisible,
                builder: (context, visible, _) {
                  if (!visible) {
                    if (_searchController.text.isNotEmpty || _searchFocusNode.hasFocus) {
                      WidgetsBinding.instance.addPostFrameCallback((_) => _resetSearchAndFocus());
                    }
                    return const SizedBox.shrink();
                  }

                  // visible == true
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
                      autofocus: true,                         //focus solo all’apertura
                      textInputAction: TextInputAction.search, //tasto Invio/Cerca
                      onSubmitted: (_) {
                        FocusScope.of(context).unfocus();      //chiude la tastiera
                        // opzionale: _searchBarVisible.value = false; // per chiudere anche la barra
                      },
                      decoration: InputDecoration(
                        hintText: 'Cerca costante...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(
                            Icons.backspace_outlined,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          onPressed: _resetSearchAndFocus,
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
                    ),
                  );
                },
              ),

              // Lista con padding top dinamico, come in Home
              ValueListenableBuilder<bool>(
                valueListenable: _searchBarVisible,
                builder: (context, searchVisible, _) {
                  final topListPadding = searchVisible
                      ? 0.0
                      : MediaQuery.of(context).viewPadding.top + 70;

                  final colorScheme = Theme.of(context).colorScheme;

                  return Expanded(
                    child: _filteredConstants.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 60, color: colorScheme.onSurfaceVariant.withOpacity(0.6)),
                          const SizedBox(height: 16),
                          Text(
                            'Nessuna costante trovata.',
                            style: TextStyle(
                              fontSize: 18,
                              color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.separated(
                      padding: EdgeInsets.only(
                        top: topListPadding,
                        bottom: MediaQuery.of(context).viewPadding.bottom + 98,
                        left: 16,
                        right: 16,
                      ),
                      itemCount: _filteredConstants.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8.0),
                      itemBuilder: (context, index) {
                        final constant = _filteredConstants[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              _showConstantDetails(context, constant);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    constant['name']!,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    constant['value']!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),

          // FloatingTopBar sovrapposta
          Positioned(
            top: MediaQuery.of(context).viewPadding.top,
            left: 16,
            right: 16,
            child: FloatingTopBar(
              title: 'Costanti Fisiche',
              leading: FloatingTopBarLeading.back,
              showSearch: true,
              searchVisible: _searchBarVisible,
            ),
            ),
        ],
      ),
    );
  }

  void _showConstantDetails(BuildContext context, Map<String, String> constant) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: colorScheme.surfaceVariant,
          title: Text(
            constant['name']!,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  constant['value']!,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (constant['info'] != null && constant['info']!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Descrizione:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    constant['info']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Chiudi',
                style: TextStyle(color: colorScheme.primary),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}