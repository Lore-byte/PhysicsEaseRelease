import 'package:flutter_avif/flutter_avif.dart';
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
      'bio':
          'Scienziato inglese poliedrico, contribuì alla meccanica, all\'elasticità e alla microscopia, ed è noto per la legge di Hooke sull\'elasticità.',
      'discoveries': [
        'Legge di Hooke (elasticità)',
        'Miglioramenti alla microscopia',
      ],
      'curiosities': [
        'Fu contemporaneo e talvolta rivale di Newton.',
        'Il suo libro "Micrographia" rese popolare il termine "cellula".',
      ],
      'imageUrl': 'assets/fisici/RobertHooke.avif',
    },
    {
      'name': 'Christiaan Huygens',
      'period': '1629 – 1695',
      'birthYear': 1629,
      'bio':
          'Fisico e matematico olandese, sviluppò la teoria ondulatoria della luce e importanti risultati sulla meccanica e l\'orologeria.',
      'discoveries': [
        'Teoria ondulatoria della luce',
        'Pendolo isocrono',
        'Anelli di Saturno e luna Titano',
      ],
      'curiosities': [
        'Inventò l\'orologio a pendolo per migliorare la misura del tempo.',
        'Scrisse il "Traité de la lumière".',
      ],
      'imageUrl': 'assets/fisici/ChristiaanHuygens.avif',
    },
    {
      'name': 'Daniel Bernoulli',
      'period': '1700 – 1782',
      'birthYear': 1700,
      'bio':
          'Matematico e fisico svizzero, noto per la meccanica dei fluidi e contributi alla teoria cinetica dei gas.',
      'discoveries': [
        'Principio di Bernoulli',
        'Teoria cinetica qualitativa dei gas',
      ],
      'curiosities': [
        'Vinse più volte il premio dell\'Accademia di Parigi.',
        'Proveniva da una famosa famiglia di matematici.',
      ],
      'imageUrl': 'assets/fisici/DanielBernoulli.avif',
    },
    {
      'name': 'Leonhard Euler',
      'period': '1707 – 1783',
      'birthYear': 1707,
      'bio':
          'Uno dei massimi matematici, contribuì enormemente anche alla meccanica e all\'ottica, formalizzando strumenti fondamentali per la fisica.',
      'discoveries': [
        'Equazioni di Eulero per fluidi',
        'Meccanica dei corpi rigidi',
        'Ottica geometrica',
      ],
      'curiosities': [
        'Produsse opere monumentali nonostante gravi problemi alla vista.',
        'Introdusse molta notazione moderna.',
      ],
      'imageUrl': 'assets/fisici/LeonhardEuler.avif',
    },
    {
      'name': 'Henry Cavendish',
      'period': '1731 – 1810',
      'birthYear': 1731,
      'bio':
          'Fisico e chimico inglese, misurò la densità della Terra e studiò elettricità e gas con straordinaria precisione sperimentale.',
      'discoveries': [
        'Esperimento della bilancia di torsione (densità della Terra)',
        'Idrogeno come sostanza distinta',
      ],
      'curiosities': [
        'Era notoriamente riservato e pubblicò poco.',
        'Le sue carte inedite rivelarono scoperte anticipate.',
      ],
      'imageUrl': 'assets/fisici/HenryCavendish.avif',
    },
    {
      'name': 'Charles-Augustin de Coulomb',
      'period': '1736 – 1806',
      'birthYear': 1736,
      'bio':
          'Fisico francese, formulò la legge fondamentale dell\'interazione elettrica e magnetica tra cariche e poli.',
      'discoveries': ['Legge di Coulomb', 'Uso della bilancia di torsione'],
      'curiosities': [
        'Il suo nome è unità SI della carica elettrica.',
        'Servì come ingegnere militare.',
      ],
      'imageUrl': 'assets/fisici/CharlesAugustinDeCoulomb.avif',
    },
    {
      'name': 'Michael Faraday',
      'period': '1791 – 1867',
      'birthYear': 1791,
      'bio':
          'Pioniere dell\'elettromagnetismo, scoprì l\'induzione elettromagnetica e pose le basi concettuali di campo e linee di forza.',
      'discoveries': [
        'Induzione elettromagnetica',
        'Leggi dell\'elettrolisi',
        'Effetto Faraday',
      ],
      'curiosities': [
        'Autodidatta senza formazione universitaria formale.',
        'Le sue "Researches in Electricity" influenzarono Maxwell.',
      ],
      'imageUrl': 'assets/fisici/MichaelFaraday.avif',
    },
    {
      'name': 'James Clerk Maxwell',
      'period': '1831 – 1879',
      'birthYear': 1831,
      'bio':
          'Unificò elettricità, magnetismo e luce nelle celebri equazioni, fondando l\'elettromagnetismo classico.',
      'discoveries': [
        'Equazioni di Maxwell',
        'Teoria elettromagnetica della luce',
        'Distribuzione di Maxwell-Boltzmann',
      ],
      'curiosities': [
        'Formalizzò matematicamente le idee di Faraday.',
        'Contribuì alla fisica statistica.',
      ],
      'imageUrl': 'assets/fisici/JamesClerkMaxwell.avif',
    },
    {
      'name': 'Heinrich Hertz',
      'period': '1857 – 1894',
      'birthYear': 1857,
      'bio':
          'Fisico tedesco che dimostrò sperimentalmente l\'esistenza delle onde elettromagnetiche previste da Maxwell.',
      'discoveries': ['Onde radio', 'Risonanza elettromagnetica'],
      'curiosities': [
        'L\'unità "hertz" misura la frequenza.',
        'Mostrò che le onde radio riflettono e rifrangono come la luce.',
      ],
      'imageUrl': 'assets/fisici/HeinrichHertz.avif',
    },
    {
      'name': 'Max Planck',
      'period': '1858 – 1947',
      'birthYear': 1858,
      'bio':
          'Fondatore della teoria dei quanti introducendo la quantizzazione dell\'energia per spiegare la radiazione del corpo nero.',
      'discoveries': ['Quantizzazione dell\'energia', 'Costante di Planck'],
      'curiosities': [
        'Nobel 1918 per l\'originaria teoria dei quanti.',
        'Inizialmente scettico sulle implicazioni della quantizzazione.',
      ],
      'imageUrl': 'assets/fisici/MaxPlanck.avif',
    },
    {
      'name': 'Marie Curie',
      'period': '1867 – 1934',
      'birthYear': 1867,
      'bio':
          'Pioniera degli studi sulla radioattività, scoprì il polonio e il radio e fu la prima persona a vincere due Nobel.',
      'discoveries': [
        'Radio e polonio',
        'Tecniche di isolamento di elementi radioattivi',
      ],
      'curiosities': [
        'Nobel in Fisica e in Chimica.',
        'Lavorò in condizioni oggi ritenute pericolose.',
      ],
      'imageUrl': 'assets/fisici/MarieCurie.avif',
    },
    {
      'name': 'Ernest Rutherford',
      'period': '1871 – 1937',
      'birthYear': 1871,
      'bio':
          'Padre della fisica nucleare, propose il modello nucleare dell\'atomo e identificò decadimenti alfa e beta.',
      'discoveries': [
        'Modello nucleare atomico',
        'Decadimento radioattivo',
        'Trasmutazione artificiale',
      ],
      'curiosities': [
        'Nobel in Chimica 1908.',
        'Il suo laboratorio formò molte future figure chiave.',
      ],
      'imageUrl': 'assets/fisici/ErnestRutherford.avif',
    },
    {
      'name': 'Albert Einstein',
      'period': '1879 – 1955',
      'birthYear': 1879,
      'bio':
          'Autore della relatività ristretta e generale e della spiegazione dell\'effetto fotoelettrico, contribuì anche alla meccanica statistica.',
      'discoveries': [
        'Relatività ristretta e generale',
        'Effetto fotoelettrico',
        'Moto browniano',
      ],
      'curiosities': [
        'Nobel 1921 per l\'effetto fotoelettrico.',
        'Partecipò ai Congressi Solvay con i pionieri dei quanti.',
      ],
      'imageUrl': 'assets/fisici/AlbertEinstein.avif',
    },
    {
      'name': 'Niels Bohr',
      'period': '1885 – 1962',
      'birthYear': 1885,
      'bio':
          'Sviluppò il modello quantizzato dell\'atomo e l\'idea di complementarità nella meccanica quantistica.',
      'discoveries': ['Modello atomico di Bohr', 'Complementarità'],
      'curiosities': [
        'Figura centrale della Scuola di Copenaghen.',
        'Mentore di molti fisici del XX secolo.',
      ],
      'imageUrl': 'assets/fisici/NielsBohr.avif',
    },
    {
      'name': 'Erwin Schrödinger',
      'period': '1887 – 1961',
      'birthYear': 1887,
      'bio':
          'Formulò la meccanica ondulatoria e l\'equazione che porta il suo nome, cardine della fisica quantistica.',
      'discoveries': ['Equazione di Schrödinger', 'Meccanica ondulatoria'],
      'curiosities': [
        'Dimostrò l\'equivalenza con la meccanica matriciale.',
        'Il famoso "gatto di Schrödinger" è un paradosso concettuale.',
      ],
      'imageUrl': 'assets/fisici/ErwinSchrödinger.avif',
    },
    {
      'name': 'Wolfgang Pauli',
      'period': '1900 – 1958',
      'birthYear': 1900,
      'bio':
          'Introdusse il principio di esclusione e contribuì ai fondamenti della teoria quantistica e della fisica delle particelle.',
      'discoveries': [
        'Principio di esclusione',
        'Neutrino (ipotesi originaria)',
      ],
      'curiosities': [
        'Nobel 1945 per il principio di esclusione.',
        'Conosciuto per la critica severa ma brillante.',
      ],
      'imageUrl': 'assets/fisici/WolfgangPauli.avif',
    },
    {
      'name': 'Werner Heisenberg',
      'period': '1901 – 1976',
      'birthYear': 1901,
      'bio':
          'Padre della meccanica matriciale e del principio di indeterminazione, fu tra i leader della nascita della MQ.',
      'discoveries': ['Principio di indeterminazione', 'Meccanica matriciale'],
      'curiosities': [
        'Nobel 1932.',
        'Figura centrale della "Copenaghen" assieme a Bohr.',
      ],
      'imageUrl': 'assets/fisici/WernerHeisenberg.avif',
    },
    {
      'name': 'Paul Dirac',
      'period': '1902 – 1984',
      'birthYear': 1902,
      'bio':
          'Formulò l\'equazione di Dirac che unisce meccanica quantistica e relatività ristretta e prevede l\'antimateria.',
      'discoveries': [
        'Equazione di Dirac',
        'Previsione del positrone',
        'QED primitiva',
      ],
      'curiosities': [
        'Nobel 1933 con Schrödinger.',
        'Stile estremamente conciso e rigoroso.',
      ],
      'imageUrl': 'assets/fisici/PaulDirac.avif',
    },
    {
      'name': 'Enrico Fermi',
      'period': '1901 – 1954',
      'birthYear': 1901,
      'bio':
          'Contributi fondamentali alla meccanica statistica, alla fisica dei neutroni e alla realizzazione del primo reattore nucleare.',
      'discoveries': [
        'Statistica di Fermi-Dirac',
        'Primo reattore nucleare a fissione',
        'Teoria del beta',
      ],
      'curiosities': [
        'Nobel 1938.',
        'Unità di lunghezza nucleare "fermi" a lui dedicata.',
      ],
      'imageUrl': 'assets/fisici/EnricoFermi.avif',
    },
    {
      'name': 'J. Robert Oppenheimer',
      'period': '1904 – 1967',
      'birthYear': 1904,
      'bio':
          'Teorico statunitense, guidò il laboratorio di Los Alamos nel Progetto Manhattan e contribuì alla fisica delle particelle e delle stelle compatte.',
      'discoveries': [
        'Direzione scientifica del Progetto Manhattan',
        'Approssimazione Born-Oppenheimer per molecole complesse',
        'Equazioni di Tolman-Oppenheimer-Volkoff per stelle di neutroni',
      ],
      'curiosities': [
        'Citò la Bhagavadgita dicendo "Ora sono diventato Morte" dopo il Trinity Test.',
        'Subì un celebre processo di revoca del nullaosta di sicurezza durante l\'era McCarthy.',
      ],
      'imageUrl': 'assets/fisici/JRobertOppenheimer.avif',
    },
    {
      'name': 'Richard Feynman',
      'period': '1918 – 1988',
      'birthYear': 1918,
      'bio':
          'Tra i padri dell\'elettrodinamica quantistica, introdusse i diagrammi che portano il suo nome e un approccio path integral.',
      'discoveries': ['QED', 'Diagrammi di Feynman', 'Integrale sui cammini'],
      'curiosities': [
        'Nobel 1965 con Schwinger e Tomonaga.',
        'Celebre divulgatore e problem solver.',
      ],
      'imageUrl': 'assets/fisici/RichardFeynman.avif',
    },
    {
      'name': 'Abdus Salam',
      'period': '1926 – 1996',
      'birthYear': 1926,
      'bio':
          'Co-artefice dell\'unificazione elettrodebole, contribuì in modo decisivo al Modello Standard.',
      'discoveries': ['Teoria elettrodebole (con Weinberg e Glashow)'],
      'curiosities': [
        'Primo pakistano a vincere il Nobel (1979).',
        'Fondò l\'ICTP a Trieste.',
      ],
      'imageUrl': 'assets/fisici/AbdusSalam.avif',
    },
    {
      'name': 'Steven Weinberg',
      'period': '1933 – 2021',
      'birthYear': 1933,
      'bio':
          'Coautore della teoria elettrodebole, chiave del Modello Standard e della fisica delle particelle moderna.',
      'discoveries': [
        'Teoria elettrodebole',
        'Meccanismo di rottura di simmetria',
      ],
      'curiosities': [
        'Nobel 1979 con Salam e Glashow.',
        'Autore di influenti testi divulgativi.',
      ],
      'imageUrl': 'assets/fisici/StevenWeinberg.avif',
    },
    {
      'name': 'Peter Higgs',
      'period': '1929 – 2024',
      'birthYear': 1929,
      'bio':
          'Propose il meccanismo di Higgs per l\'origine delle masse delle particelle, culminato nell\'osservazione del bosone di Higgs al CERN.',
      'discoveries': ['Meccanismo di Higgs', 'Bosone di Higgs (predetto)'],
      'curiosities': [
        'Nobel 2013 con Englert.',
        'LHC osservò la particella nel 2012.',
      ],
      'imageUrl': 'assets/fisici/PeterHiggs.avif',
    },
    {
      'name': 'Stephen Hawking',
      'period': '1942 – 2018',
      'birthYear': 1942,
      'bio':
          'Cosmologo britannico che studiò la natura delle singolarità e scoprì la radiazione termica emessa dai buchi neri, rendendo popolari i temi della cosmologia moderna.',
      'discoveries': [
        'Radiazione di Hawking dei buchi neri',
        'Teoremi sulle singolarità con Penrose',
        'Modello cosmologico senza confine',
      ],
      'curiosities': [
        'Visse per oltre cinquant\'anni con la SLA comunicando tramite sintetizzatore vocale.',
        'Il libro "A Brief History of Time" vendette milioni di copie, trasformandolo in un divulgatore di fama mondiale.',
      ],
      'imageUrl': 'assets/fisici/StephenHawking.avif',
    },
    {
      'name': 'Archimede',
      'period': 'c. 287 – 212 a.C.',
      'birthYear': -287,
      'bio':
          'Matematico e ingegnere siracusano, fondò l\'idrostatica e introdusse metodi geometrici precursori del calcolo infinitesimale.',
      'discoveries': [
        'Principio di Archimede',
        'Leggi della leva',
        'Metodo di esaustione per aree e volumi',
      ],
      'curiosities': [
        'Le sue macchine difensive respinsero per anni l\'assedio romano di Siracusa.',
        'Il celebre grido "Eureka!" è legato ai suoi esperimenti sull\'immersione dei corpi.',
      ],
      'imageUrl': 'assets/fisici/Archimede.avif',
    },
    {
      'name': 'Galileo Galilei',
      'period': '1564 – 1642',
      'birthYear': 1564,
      'bio':
          'Pioniere del metodo sperimentale, studiò il moto dei corpi e l\'astronomia telescopica sostenendo l\'eliocentrismo.',
      'discoveries': [
        'Telescopio astronomico perfezionato',
        'Leggi del moto uniformemente accelerato',
        'Osservazioni delle fasi di Venere',
      ],
      'curiosities': [
        'Nel 1610 dedicò i satelliti di Giove a Cosimo II de\' Medici.',
        'Il "Dialogo sopra i due massimi sistemi" fu inserito nell\'Indice dei libri proibiti.',
      ],
      'imageUrl': 'assets/fisici/GalileoGalilei.avif',
    },
    {
      'name': 'Johannes Kepler',
      'period': '1571 – 1630',
      'birthYear': 1571,
      'bio':
          'Astronomo imperiale, formulò le leggi del moto planetario e pose le basi dell\'ottica geometrica moderna.',
      'discoveries': [
        'Leggi di Keplero del moto planetario',
        'Ottica dei telescopi composti',
        'Tavole rudolfine',
      ],
      'curiosities': [
        'Fu assistente di Tycho Brahe a Praga.',
        'Le sue leggi guidarono Newton verso la gravitazione universale.',
      ],
      'imageUrl': 'assets/fisici/JohannesKepler.avif',
    },
    {
      'name': 'Evangelista Torricelli',
      'period': '1608 – 1647',
      'birthYear': 1608,
      'bio':
          'Allievo di Galileo, dimostrò l\'esistenza del vuoto e fondò la barometria moderna.',
      'discoveries': [
        'Barometro a mercurio',
        'Legge di Torricelli per i fluidi',
        'Studi sulla pressione atmosferica',
      ],
      'curiosities': [
        'Succedette a Galileo come matematico dei Medici.',
        'Morì pochi mesi dopo aver pubblicato l\'Opera Geometrica.',
      ],
      'imageUrl': 'assets/fisici/EvangelistaTorricelli.avif',
    },
    {
      'name': 'Blaise Pascal',
      'period': '1623 – 1662',
      'birthYear': 1623,
      'bio':
          'Genio francese dei fluidi e della probabilità, indagò la pressione atmosferica con esperimenti monumentali.',
      'discoveries': [
        'Legge di Pascal',
        'Calcolatrice Pascalina',
        'Esperimenti sulla pressione atmosferica',
      ],
      'curiosities': [
        'Collaborò con Fermat alla nascita della teoria della probabilità.',
        'Fu anche autore dei "Pensées".',
      ],
      'imageUrl': 'assets/fisici/BlaisePascal.avif',
    },
    {
      'name': 'Robert Boyle',
      'period': '1627 – 1691',
      'birthYear': 1627,
      'bio':
          'Chimico e fisico irlandese, stabilì il legame inverso tra pressione e volume dei gas.',
      'discoveries': [
        'Legge di Boyle',
        'Pompa pneumatica avanzata',
        'Metodi sperimentali per la chimica moderna',
      ],
      'curiosities': [
        'Membro fondatore della Royal Society.',
        'Favorì l\'uso dell\'inglese nella divulgazione scientifica.',
      ],
      'imageUrl': 'assets/fisici/RobertBoyle.avif',
    },
    {
      'name': 'Isaac Newton',
      'period': '1643 – 1727',
      'birthYear': 1643,
      'bio':
          'Padre della meccanica classica, della gravità universale e di fondamentali studi sull\'ottica e il calcolo.',
      'discoveries': [
        'Leggi di Newton e Principia',
        'Gravitazione universale',
        'Spettro della luce e calcolo infinitesimale',
      ],
      'curiosities': [
        'Fu direttore della Zecca reale.',
        'Scrisse ampi trattati di alchimia e teologia.',
      ],
      'imageUrl': 'assets/fisici/IsaacNewton.avif',
    },
    {
      'name': 'Étienne-Louis Malus',
      'period': '1775 – 1812',
      'birthYear': 1775,
      'bio':
          'Fisico francese che descrisse matematicamente la polarizzazione della luce riflessa.',
      'discoveries': [
        'Legge di Malus',
        'Polarizzazione per riflessione',
        'Analisi della birifrangenza',
      ],
      'curiosities': [
        'Osservò la polarizzazione studiando il Palazzo del Lussemburgo.',
        'Entrò all\'Académie des Sciences poco prima di morire.',
      ],
      'imageUrl': 'assets/fisici/EtienneLouisMalus.avif',
    },
    {
      'name': 'André-Marie Ampère',
      'period': '1775 – 1836',
      'birthYear': 1775,
      'bio':
          'Autodidatta francese che fondò l\'elettrodinamica e descrisse l\'interazione tra correnti.',
      'discoveries': [
        'Legge di Ampère',
        'Fondamenti dell\'elettrodinamica',
        'Ampèrometro',
      ],
      'curiosities': [
        'L\'unità SI della corrente porta il suo nome.',
        'Fu professore al Collège de France.',
      ],
      'imageUrl': 'assets/fisici/AndreMarieAmpere.avif',
    },
    {
      'name': 'Jean-Baptiste Joseph Fourier',
      'period': '1768 – 1830',
      'birthYear': 1768,
      'bio':
          'Analizzò la conduzione del calore e introdusse lo sviluppo in serie trigonometriche.',
      'discoveries': [
        'Serie di Fourier',
        'Equazione del calore',
        'Analisi armonica dei segnali',
      ],
      'curiosities': [
        'Partecipò alla spedizione napoleonica in Egitto.',
        'I suoi lavori furono inizialmente contestati da Laplace e Lagrange.',
      ],
      'imageUrl': 'assets/fisici/JeanBaptisteJosephFourier.avif',
    },
    {
      'name': 'Carl Friedrich Gauss',
      'period': '1777 – 1855',
      'birthYear': 1777,
      'bio':
          'Matematico universale che contribuì anche al magnetismo terrestre e alla geodesia.',
      'discoveries': [
        'Teorema di Gauss',
        'Metodo dei minimi quadrati',
        'Misure del magnetismo terrestre',
      ],
      'curiosities': [
        'Guidò la grande triangolazione di Hannover.',
        'È soprannominato il "principe dei matematici".',
      ],
      'imageUrl': 'assets/fisici/CarlFriedrichGauss.avif',
    },
    {
      'name': 'Joseph Louis Gay-Lussac',
      'period': '1778 – 1850',
      'birthYear': 1778,
      'bio':
          'Fisico e chimico francese noto per le leggi dei gas e i voli aerostatici scientifici.',
      'discoveries': [
        'Leggi di Gay-Lussac',
        'Esperimenti sulla dilatazione dei gas',
        'Determinazione della composizione dell\'acqua',
      ],
      'curiosities': [
        'Raggiunse 7 km di quota in mongolfiera per misurare l\'atmosfera.',
        'Collaborò con Thénard alla chimica degli alogeni.',
      ],
      'imageUrl': 'assets/fisici/JosephLouisGayLussac.avif',
    },
    {
      'name': 'Georg Simon Ohm',
      'period': '1789 – 1854',
      'birthYear': 1789,
      'bio':
          'Fisico tedesco che stabilì la relazione lineare tra tensione e corrente elettrica.',
      'discoveries': [
        'Legge di Ohm',
        'Concetto di resistenza elettrica',
        'Analisi dei circuiti galvanici',
      ],
      'curiosities': [
        'Le sue ricerche furono inizialmente ignorate.',
        'L\'unità di resistenza prende il suo cognome.',
      ],
      'imageUrl': 'assets/fisici/GeorgSimonOhm.avif',
    },
    {
      'name': 'Sadi Carnot',
      'period': '1796 – 1832',
      'birthYear': 1796,
      'bio':
          'Ingegnere francese considerato il padre della termodinamica per lo studio dei motori termici.',
      'discoveries': [
        'Ciclo di Carnot',
        'Limite di efficienza dei motori',
        'Concetto di reversibilità',
      ],
      'curiosities': [
        'Morì di colera a soli 36 anni.',
        'Il suo trattato inizialmente passò inosservato.',
      ],
      'imageUrl': 'assets/fisici/SadiCarnot.avif',
    },
    {
      'name': 'Franz Ernst Neumann',
      'period': '1798 – 1895',
      'birthYear': 1798,
      'bio':
          'Fisico tedesco attivo in elettrodinamica, ottica e cristallografia.',
      'discoveries': [
        'Legge di Neumann sull\'induzione',
        'Principio di Neumann per l\'ottica',
        'Teoria del calore nei cristalli',
      ],
      'curiosities': [
        'Co-fondò il laboratorio fisico di Königsberg.',
        'Fu mentore di Gustav Kirchhoff.',
      ],
      'imageUrl': 'assets/fisici/FranzErnstNeumann.avif',
    },
    {
      'name': 'Heinrich Lenz',
      'period': '1804 – 1865',
      'birthYear': 1804,
      'bio':
          'Fisico russo di origine baltica noto per la legge che determina il verso delle correnti indotte.',
      'discoveries': [
        'Legge di Lenz',
        'Studi sulle correnti indotte',
        'Ricerca sull\'elettromagnetismo applicato',
      ],
      'curiosities': [
        'Collaborò con Moritz von Jacobi sulla telegrafia.',
        'Il simbolo L dell\'induttanza deriva dal suo cognome.',
      ],
      'imageUrl': 'assets/fisici/HeinrichLenz.avif',
    },
    {
      'name': 'James Prescott Joule',
      'period': '1818 – 1889',
      'birthYear': 1818,
      'bio':
          'Determinò l\'equivalente meccanico del calore e consolidò il primo principio della termodinamica.',
      'discoveries': [
        'Equivalente meccanico del calore',
        'Legge di Joule',
        'Effetto Joule-Thomson',
      ],
      'curiosities': [
        'Era un birraio appassionato di scienze.',
        'Collaborò con Lord Kelvin in esperimenti termodinamici.',
      ],
      'imageUrl': 'assets/fisici/JamesPrescottJoule.avif',
    },
    {
      'name': 'George Gabriel Stokes',
      'period': '1819 – 1903',
      'birthYear': 1819,
      'bio':
          'Fisico irlandese che descrisse i fluidi viscosi e fenomeni di fluorescenza.',
      'discoveries': [
        'Equazioni di Navier-Stokes',
        'Legge di Stokes per la viscosità',
        'Studi sulla fluorescenza',
      ],
      'curiosities': [
        'Fu presidente della Royal Society.',
        'Curò le opere di George Green.',
      ],
      'imageUrl': 'assets/fisici/GeorgeGabrielStokes.avif',
    },
    {
      'name': 'Rudolf Clausius',
      'period': '1822 – 1888',
      'birthYear': 1822,
      'bio':
          'Riformulò il secondo principio della termodinamica e introdusse l\'entropia.',
      'discoveries': [
        'Secondo principio della termodinamica',
        'Concetto di entropia',
        'Teoria cinetica dei gas',
      ],
      'curiosities': [
        'Coniò la frase "l\'energia dell\'universo è costante".',
        'Fu tra i fondatori della Croce Rossa tedesca.',
      ],
      'imageUrl': 'assets/fisici/RudolfClausius.avif',
    },
    {
      'name': 'Lord Kelvin (William Thomson)',
      'period': '1824 – 1907',
      'birthYear': 1824,
      'bio':
          'Pioniere della termodinamica applicata e dell\'ingegneria elettrotelegrafica.',
      'discoveries': [
        'Scala Kelvin',
        'Analisi energetica del calore',
        'Teoria delle linee telegrafiche sottomarine',
      ],
      'curiosities': [
        'Supervisionò la posa del cavo transatlantico.',
        'Fu elevato alla nobiltà per meriti scientifici.',
      ],
      'imageUrl': 'assets/fisici/LordKelvin.avif',
    },
    {
      'name': 'Gustav Robert Kirchhoff',
      'period': '1824 – 1887',
      'birthYear': 1824,
      'bio':
          'Stabilì le leggi dei circuiti elettrici e contribuì alla spettroscopia con Bunsen.',
      'discoveries': [
        'Leggi di Kirchhoff',
        'Spettroscopia atomica',
        'Teorema della radiazione',
      ],
      'curiosities': [
        'Identificò cesio e rubidio tramite le linee spettrali.',
        'Un cratere lunare porta il suo nome.',
      ],
      'imageUrl': 'assets/fisici/GustavRobertKirchhoff.avif',
    },
    {
      'name': 'Josef Stefan',
      'period': '1835 – 1893',
      'birthYear': 1835,
      'bio':
          'Fisico sloveno che dedusse empiricamente la legge della radiazione termica.',
      'discoveries': [
        'Legge di Stefan-Boltzmann',
        'Determinazione della temperatura solare',
        'Ricerca sulla conduzione del calore',
      ],
      'curiosities': [
        'Fu mentore di Ludwig Boltzmann.',
        'Mise in relazione osservazioni astronomiche e laboratorio.',
      ],
      'imageUrl': 'assets/fisici/JosephStefan.avif',
    },
    {
      'name': 'Osborne Reynolds',
      'period': '1842 – 1912',
      'birthYear': 1842,
      'bio':
          'Ingegnere e fisico che studiò la transizione alla turbolenza nei fluidi.',
      'discoveries': [
        'Numero di Reynolds',
        'Modelli di turbolenza',
        'Teoria della lubrificazione',
      ],
      'curiosities': [
        'Creò un laboratorio di idraulica a Manchester.',
        'Applicò i suoi studi ai sistemi di condotta urbana.',
      ],
      'imageUrl': 'assets/fisici/OsborneReynolds.avif',
    },
    {
      'name': 'Ludwig Boltzmann',
      'period': '1844 – 1906',
      'birthYear': 1844,
      'bio':
          'Fondatore della meccanica statistica, legò entropia e probabilità microstatistica.',
      'discoveries': [
        'Equazione di Boltzmann',
        'Distribuzione di Maxwell-Boltzmann',
        'Interpretazione statistica dell\'entropia',
      ],
      'curiosities': [
        'Sulla sua tomba compare S = k log W.',
        'Insegnò a Vienna, Lipsia e Monaco.',
      ],
      'imageUrl': 'assets/fisici/LudwigBoltzmann.avif',
    },
    {
      'name': 'Hendrik Antoon Lorentz',
      'period': '1853 – 1928',
      'birthYear': 1853,
      'bio':
          'Fisico olandese che introdusse le trasformazioni relativistiche e la teoria elettronica.',
      'discoveries': [
        'Trasformazioni di Lorentz',
        'Forza di Lorentz',
        'Teoria dell\'elettrone',
      ],
      'curiosities': [
        'Fu mentore di Pieter Zeeman.',
        'Presiedette il comitato scientifico della diga Afsluitdijk.',
      ],
      'imageUrl': 'assets/fisici/HendrikAntoonLorentz.avif',
    },
    {
      'name': 'Nikola Tesla',
      'period': '1856 – 1943',
      'birthYear': 1856,
      'bio':
          'Inventore serbo-croato naturalizzato statunitense, rivoluzionò la distribuzione dell\'energia elettrica con sistemi a corrente alternata e dispositivi ad alta frequenza.',
      'discoveries': [
        'Sistemi polifase in corrente alternata',
        'Bobina di Tesla e trasformatori ad alta tensione',
        'Radiocomunicazioni e oscillatori ad alta frequenza',
      ],
      'curiosities': [
        'Registrò centinaia di brevetti e organizzava dimostrazioni spettacolari con scariche luminose.',
        'Sognava una rete globale di energia e informazione senza fili come la Wardenclyffe Tower.',
      ],
      'imageUrl': 'assets/fisici/NikolaTesla.avif',
    },
    {
      'name': 'Wilhelm Wien',
      'period': '1864 – 1928',
      'birthYear': 1864,
      'bio':
          'Fisico tedesco della radiazione termica, collegò temperatura e lunghezza d\'onda di picco.',
      'discoveries': [
        'Legge di spostamento di Wien',
        'Distribuzione di Wien',
        'Filtri per fasci catodici',
      ],
      'curiosities': [
        'Nobel per la Fisica nel 1911.',
        'Fu docente di Planck e Sommerfeld.',
      ],
      'imageUrl': 'assets/fisici/WilhelmWien.avif',
    },
    {
      'name': 'Louis de Broglie',
      'period': '1892 – 1987',
      'birthYear': 1892,
      'bio':
          'Propose il dualismo onda-particella per la materia, aprendo la via alla meccanica ondulatoria.',
      'discoveries': [
        'Ipotesi de Broglie',
        'Dualismo onda-particella',
        'Quantizzazione delle orbite',
      ],
      'curiosities': [
        'Fu insignito del Nobel nel 1929.',
        'Apparteneva alla nobiltà francese.',
      ],
      'imageUrl': 'assets/fisici/LouisDeBroglie.avif',
    },
    {
      'name': 'Arthur Compton',
      'period': '1892 – 1962',
      'birthYear': 1892,
      'bio':
          'Mostrò la natura corpuscolare dei fotoni tramite la diffusione dei raggi X.',
      'discoveries': [
        'Effetto Compton',
        'Diffusione inelastica dei raggi X',
        'Studi sui raggi cosmici',
      ],
      'curiosities': [
        'Nobel 1927 con C.T.R. Wilson.',
        'Diresse il Metallurgical Laboratory del Progetto Manhattan.',
      ],
      'imageUrl': 'assets/fisici/ArthurCompton.avif',
    },
    {
      'name': 'John Henry Poynting',
      'period': '1852 – 1914',
      'birthYear': 1852,
      'bio':
          'Descrisse il flusso di energia elettromagnetica e migliorò la misura della costante gravitazionale.',
      'discoveries': [
        'Vettore di Poynting',
        'Teorema di conservazione dell\'energia EM',
        'Misure della costante gravitazionale',
      ],
      'curiosities': [
        'Fu docente di Ernest Rutherford a Manchester.',
        'Collaborò con Cavendish sulle bilance di torsione.',
      ],
      'imageUrl': 'assets/fisici/JohnHenryPoynting.avif',
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
          .where(
            (physicist) =>
                physicist['name'].toLowerCase().contains(query) ||
                physicist['bio'].toLowerCase().contains(query) ||
                (physicist['discoveries'] as List<String>).any(
                  (d) => d.toLowerCase().contains(query),
                ),
          )
          .toList();

      results.sort((a, b) {
        final yearA = a['birthYear'] as int;
        final yearB = b['birthYear'] as int;
        return _sortOrder == SortOrder.ascending
            ? yearA.compareTo(yearB)
            : yearB.compareTo(yearA);
      });

      _filteredPhysicists = results;
    });
  }

  void _toggleSortOrder() {
    setState(() {
      _sortOrder = _sortOrder == SortOrder.ascending
          ? SortOrder.descending
          : SortOrder.ascending;
      _updateList();
    });
  }

  IconData _getSortIcon() {
    return _sortOrder == SortOrder.ascending
        ? Icons.arrow_upward
        : Icons.arrow_downward;
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required dynamic content,
  }) {
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
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: textTheme.bodyLarge),
                        Expanded(child: Text(item, style: textTheme.bodyLarge)),
                      ],
                    ),
                  ),
                )
                //.toList(),
        ],
      ),
    );
  }

  Widget _buildPhysicistImage({
    required String imageUrl,
    required double size,
    required bool isCard,
  }) {
    final fallbackIcon = Icon(
      Icons.person,
      size: size * 0.5,
      color: Colors.grey,
    );

    final double width = isCard ? size : double.infinity;
    final double height = isCard ? size : 200;
    final BoxFit fit = isCard ? BoxFit.cover : BoxFit.contain;
    final bool isAvif = imageUrl.toLowerCase().endsWith('.avif');

    Widget imageWidget = isAvif
        ? AvifImage.asset(
            imageUrl,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => fallbackIcon,
          )
        : Image.asset(
            imageUrl,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => fallbackIcon,
          );

    if (isCard) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
    BuildContext context,
    Map<String, dynamic> physicist,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            physicist['name'] as String,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
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

  Widget _buildPhysicistCard({
    required BuildContext context,
    required Map<String, dynamic> physicist,
  }) {
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
    final double fixedTopBarHeight =
        MediaQuery.of(context).viewPadding.top + 70;

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
                          borderSide: BorderSide(color: colorScheme.outline),
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
                    final topListPadding = searchVisible
                        ? 0.0
                        : fixedTopBarHeight;

                    if (_filteredPhysicists.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 
                                0.6,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nessun fisico trovato.',
                              style: TextStyle(
                                fontSize: 18,
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 
                                  0.8,
                                ),
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
                          context: context,
                          physicist: physicist,
                        );
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
