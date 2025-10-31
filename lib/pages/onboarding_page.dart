import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback onFinished;

  const OnboardingPage({super.key, required this.onFinished});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Definisci qui le pagine per poter calcolare l'ultima pagina in build
    final pages = <PageViewModel>[
      PageViewModel(
        title: "PhysicsEase ⚡",
        body:
        "Benvenuto nell'app! Preparati a scoprire un mondo di formule, strumenti e dati a portata di mano.",
        image: Icon(Icons.school, size: 150, color: primaryColor),
        decoration: PageDecoration(
          bodyTextStyle: const TextStyle(fontSize: 18),
          titleTextStyle:
          const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          pageColor: Theme.of(context).scaffoldBackgroundColor,
          imagePadding: const EdgeInsets.only(top: 50),
        ),
      ),
      PageViewModel(
        title: "Sempre con te",
        body:
        "PhysicsEase funziona anche offline. Questo significa che puoi studiare e consultare tutto ciò di cui hai bisogno ovunque tu sia, senza preoccuparti della connessione internet.",
        image: Icon(Icons.wifi_off, size: 150, color: primaryColor),
        decoration: PageDecoration(
          bodyTextStyle: const TextStyle(fontSize: 18),
          titleTextStyle:
          const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          pageColor: Theme.of(context).scaffoldBackgroundColor,
          imagePadding: const EdgeInsets.only(top: 50),
        ),
      ),
      PageViewModel(
        title: "Cerca",
        body: "Usa la barra di ricerca per trovare rapidamente le formule.",
        image: Icon(Icons.search, size: 150, color: primaryColor),
        decoration: PageDecoration(
          bodyTextStyle: const TextStyle(fontSize: 18),
          titleTextStyle:
          const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          pageColor: Theme.of(context).scaffoldBackgroundColor,
          imagePadding: const EdgeInsets.only(top: 50),
        ),
      ),
      PageViewModel(
        title: "Personalizza e salva",
        body:
        "Salva le tue formule preferite e aggiungi le tue. Troverai tutto nella sezione 'Preferiti' e 'Strumenti'!",
        image: Icon(Icons.star, size: 150, color: primaryColor),
        decoration: PageDecoration(
          bodyTextStyle: const TextStyle(fontSize: 18),
          titleTextStyle:
          const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          pageColor: Theme.of(context).scaffoldBackgroundColor,
          imagePadding: const EdgeInsets.only(top: 50),
        ),
      ),
      PageViewModel(
        title: "Strumenti a portata di mano",
        body:
        "Oltre alla calcolatrice, la sezione 'Strumenti' offre un convertitore di unità, un risolutore di equazioni, un visualizzatore di grafici, un calcolatore vettoriale e la possibilità di salvare formule personalizzate.",
        image: Icon(Icons.build, size: 150, color: primaryColor),
        decoration: PageDecoration(
          bodyTextStyle: const TextStyle(fontSize: 18),
          titleTextStyle:
          const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          pageColor: Theme.of(context).scaffoldBackgroundColor,
          imagePadding: const EdgeInsets.only(top: 50),
        ),
      ),
      PageViewModel(
        title: "Informazioni e dati",
        body:
        "Costanti fisiche, dati sui pianeti, tavola periodica e altro ancora. Trova tutto ciò che ti serve per lo studio.",
        image: Icon(Icons.storage, size: 150, color: primaryColor),
        decoration: PageDecoration(
          bodyTextStyle: const TextStyle(fontSize: 18),
          titleTextStyle:
          const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          pageColor: Theme.of(context).scaffoldBackgroundColor,
          imagePadding: const EdgeInsets.only(top: 50),
        ),
      ),
    ];

    final bool isLastPage = _currentIndex == pages.length - 1;

    return IntroductionScreen(
      pages: pages,
      // Aggiorna l'indice corrente per cambiare "Salta" -> "Inizia"
      onChange: (index) => setState(() => _currentIndex = index), // top-right
      // Callbacks
      onDone: widget.onFinished, // usato solo se riattivi Done
      onSkip: widget.onFinished, // non mostrato (skip nascosto)
      // Mostra solo frecce in basso
      showBackButton: true,
      showSkipButton: false,
      showDoneButton: false,
      back: Icon(Icons.arrow_back, color: primaryColor, size: 30),
      next: Icon(Icons.arrow_forward, color: primaryColor, size: 30),
      // Dots e layout in basso
      skipOrBackFlex: 0,
      nextFlex: 0,
      dotsFlex: 2,
      controlsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 98),
      baseBtnStyle: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        minimumSize: const Size(0, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      // Header in alto a destra: Salta/Inizia
      globalHeader: SafeArea(
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 16.0),
            child: TextButton(
              onPressed: widget.onFinished,
              child: Text(
                isLastPage ? "Inizia" : "Salta",
                style: TextStyle(
                  fontSize: 20,
                  color: primaryColor,
                  fontWeight: isLastPage ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
      // Dots
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: primaryColor.withOpacity(0.3),
        activeSize: const Size(22.0, 10.0),
        activeColor: primaryColor,
        activeShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
