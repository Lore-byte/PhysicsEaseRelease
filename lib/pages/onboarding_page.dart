import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingPage extends StatelessWidget {
  final VoidCallback onFinished;

  const OnboardingPage({super.key, required this.onFinished});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "PhysicsEase ⚡",
          body:
          "Benvenuto nell'app! Preparati a scoprire un mondo di formule, strumenti e dati a portata di mano.",
          image: Icon(Icons.school, size: 150, color: primaryColor),
          decoration: PageDecoration(
            bodyTextStyle: const TextStyle(fontSize: 18),
            titleTextStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            pageColor: Theme.of(context).scaffoldBackgroundColor,
            imagePadding: const EdgeInsets.only(top: 50),
          ),
        ),
        PageViewModel(
          title: "Sempre con te",
          body:
          "PhysicsEase funziona anche offline. Questo significa che puoi studiare e consultare tutto ciò di cui hai bisogno ovunque tu sia, senza preoccuparti della connessione internet.",
          image: Icon(Icons.signal_cellular_connected_no_internet_4_bar_outlined, size: 150, color: primaryColor),
          decoration: PageDecoration(
            bodyTextStyle: const TextStyle(fontSize: 18),
            titleTextStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            pageColor: Theme.of(context).scaffoldBackgroundColor,
            imagePadding: const EdgeInsets.only(top: 50),
          ),
        ),
        PageViewModel(
          title: "Cerca",
          body:
          "Usa la barra di ricerca per trovare rapidamente le formule.",
          image: Icon(Icons.search, size: 150, color: primaryColor),
          decoration: PageDecoration(
            bodyTextStyle: const TextStyle(fontSize: 18),
            titleTextStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
            titleTextStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
            titleTextStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
            titleTextStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            pageColor: Theme.of(context).scaffoldBackgroundColor,
            imagePadding: const EdgeInsets.only(top: 50),
          ),
        ),
      ],
      onDone: onFinished,
      onSkip: onFinished,
      showSkipButton: true,
      skip: Text("Salta", style: TextStyle(color: primaryColor)),
      next: Icon(Icons.arrow_forward, color: primaryColor),
      done: Text("Inizia", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
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
