import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingPage extends StatelessWidget {
  final VoidCallback onFinished;

  const OnboardingPage({super.key, required this.onFinished});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentIndex = 0;

  Widget _buildAnimatedIcon({
    required IconData icon,
    required Color color,
    required List<Color> gradientColors,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 90,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const double arrowButtonSize = 56;

    // Definisci qui le pagine per poter calcolare l'ultima pagina in build
    final pages = <PageViewModel>[
      PageViewModel(
        title: "PhysicsEase ⚡",
        body:
            "Benvenuto in PhysicsEase! La tua app completa per lo studio della fisica con formule, quiz interattivi, strumenti avanzati e dati scientifici.",
        image: _buildAnimatedIcon(
          icon: Icons.school_rounded,
          color: primaryColor,
          gradientColors: [
            primaryColor,
            primaryColor.withValues(alpha: 0.7),
          ],
        ),
        decoration: PageDecoration(
          bodyTextStyle: TextStyle(
            fontSize: 18,
            height: 1.5,
            color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
          ),
          titleTextStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: primaryColor,
            letterSpacing: 0.5,
          ),
          pageColor: Theme.of(context).scaffoldBackgroundColor,
          imagePadding: const EdgeInsets.only(top: 50),
        ),
      ),
      PageViewModel(
        title: "Sempre con te",
        body:
            "Metti alla prova le tue conoscenze con migliaia di quiz! Scegli la categoria, il livello di difficoltà e il numero di domande. Tieni traccia dei tuoi progressi con statistiche dettagliate.",
        image: _buildAnimatedIcon(
          icon: Icons.quiz_rounded,
          color: const Color(0xFFFF6B6B),
          gradientColors: const [
            Color(0xFFFF6B6B),
            Color(0xFFFF8E53),
          ],
        ),
        decoration: PageDecoration(
          bodyTextStyle: TextStyle(
            fontSize: 18,
            height: 1.5,
            color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
          ),
          titleTextStyle: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFF6B6B),
            letterSpacing: 0.5,
          ),
          pageColor: Theme.of(context).scaffoldBackgroundColor,
          imagePadding: const EdgeInsets.only(top: 50),
        ),
      ),
      PageViewModel(
        title: "Formule e ricerca",
        body:
            "Accedi a centinaia di formule di fisica organizzate per categoria. Usa la ricerca avanzata per trovare rapidamente ciò che ti serve. Aggiungi note personali!",
        image: _buildAnimatedIcon(
          icon: Icons.calculate_rounded,
          color: const Color(0xFF4ECDC4),
          gradientColors: const [
            Color(0xFF4ECDC4),
            Color(0xFF44A08D),
          ],
        ),
        decoration: PageDecoration(
          bodyTextStyle: TextStyle(
            fontSize: 18,
            height: 1.5,
            color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
          ),
          titleTextStyle: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF4ECDC4),
            letterSpacing: 0.5,
          ),
          pageColor: Theme.of(context).scaffoldBackgroundColor,
          imagePadding: const EdgeInsets.only(top: 50),
        ),
      ),
      PageViewModel(
        title: "Personalizza e salva",
        body:
            "PhysicsEase funziona completamente offline! Studia ovunque tu sia: formule, quiz, strumenti e dati sono sempre disponibili senza connessione internet.",
        image: _buildAnimatedIcon(
          icon: Icons.wifi_off_rounded,
          color: const Color(0xFF9B59B6),
          gradientColors: const [
            Color(0xFF9B59B6),
            Color(0xFF8E44AD),
          ],
        ),
        decoration: PageDecoration(
          bodyTextStyle: TextStyle(
            fontSize: 18,
            height: 1.5,
            color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
          ),
          titleTextStyle: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF9B59B6),
            letterSpacing: 0.5,
          ),
          pageColor: Theme.of(context).scaffoldBackgroundColor,
          imagePadding: const EdgeInsets.only(top: 50),
        ),
      ),
      PageViewModel(
        title: "Strumenti a portata di mano",
        body:
            "Salva le tue formule preferite per accedervi rapidamente. Crea e gestisci le tue formule personalizzate nella sezione 'Strumenti'. Organizza il tuo studio!",
        image: _buildAnimatedIcon(
          icon: Icons.star_rounded,
          color: const Color(0xFFFFA502),
          gradientColors: const [
            Color(0xFFFFA502),
            Color(0xFFFFB142),
          ],
        ),
        decoration: PageDecoration(
          bodyTextStyle: TextStyle(
            fontSize: 18,
            height: 1.5,
            color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
          ),
          titleTextStyle: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFFA502),
            letterSpacing: 0.5,
          ),
          pageColor: Theme.of(context).scaffoldBackgroundColor,
          imagePadding: const EdgeInsets.only(top: 50),
        ),
      ),
      PageViewModel(
        title: "Informazioni e dati",
        body:
            "Calcolatrice scientifica, convertitore di unità, risolutore di equazioni, visualizzatore di grafici, calcolatore vettoriale e molto altro in un'unica app.",
        image: _buildAnimatedIcon(
          icon: Icons.build_rounded,
          color: const Color(0xFF3498DB),
          gradientColors: const [
            Color(0xFF3498DB),
            Color(0xFF2980B9),
          ],
        ),
        decoration: PageDecoration(
          bodyTextStyle: TextStyle(
            fontSize: 18,
            height: 1.5,
            color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
          ),
          titleTextStyle: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF3498DB),
            letterSpacing: 0.5,
          ),
          pageColor: Theme.of(context).scaffoldBackgroundColor,
          imagePadding: const EdgeInsets.only(top: 60, bottom: 30),
          bodyPadding: const EdgeInsets.symmetric(horizontal: 24),
          contentMargin: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
      PageViewModel(
        title: "Sensori real-time",
        body:
            "Utilizza i sensori del tuo dispositivo per esperimenti in tempo reale! Accelerometro, giroscopio e magnetometro con grafici in tempo reale per visualizzare i dati.",
        image: _buildAnimatedIcon(
          icon: Icons.sensors_rounded,
          color: const Color(0xFFE74C3C),
          gradientColors: const [
            Color(0xFFE74C3C),
            Color(0xFFC0392B),
          ],
        ),
        decoration: PageDecoration(
          bodyTextStyle: TextStyle(
            fontSize: 18,
            height: 1.5,
            color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
          ),
          titleTextStyle: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFFE74C3C),
            letterSpacing: 0.5,
          ),
          pageColor: Theme.of(context).scaffoldBackgroundColor,
          imagePadding: const EdgeInsets.only(top: 60, bottom: 30),
          bodyPadding: const EdgeInsets.symmetric(horizontal: 24),
          contentMargin: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
      PageViewModel(
        title: "Dati scientifici",
        body:
            "Costanti fisiche, dati sui pianeti del sistema solare, tavola periodica degli elementi, biografie di fisici famosi, alfabeto greco e unità di misura. Tutto a portata di mano!",
        image: _buildAnimatedIcon(
          icon: Icons.science_rounded,
          color: const Color(0xFF1ABC9C),
          gradientColors: const [
            Color(0xFF1ABC9C),
            Color(0xFF16A085),
          ],
        ),
        decoration: PageDecoration(
          bodyTextStyle: TextStyle(
            fontSize: 18,
            height: 1.5,
            color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
          ),
          titleTextStyle: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1ABC9C),
            letterSpacing: 0.5,
          ),
          pageColor: Theme.of(context).scaffoldBackgroundColor,
          imagePadding: const EdgeInsets.only(top: 60, bottom: 30),
          bodyPadding: const EdgeInsets.symmetric(horizontal: 24),
          contentMargin: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    ];

    final bool isLastPage = _currentIndex == pages.length - 1;

    return IntroductionScreen(
      pages: pages,
      // Aggiorna l'indice corrente per cambiare "Salta" -> "Inizia"
      onChange: (index) => setState(() => _currentIndex = index), // top-right
      // Callbacks
      onDone: () {},
      onSkip: () {},
      // Mostra solo frecce in basso
      showBackButton: true,
      showSkipButton: true,
      showDoneButton: true,
      skip: IgnorePointer(
        child: SizedBox(width: arrowButtonSize, height: arrowButtonSize),
      ),
      back: Container(
        width: arrowButtonSize,
        height: arrowButtonSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.arrow_back_rounded, color: primaryColor, size: 28),
      ),
      next: Container(
        width: arrowButtonSize,
        height: arrowButtonSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_forward_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      done: IgnorePointer(
        child: SizedBox(width: arrowButtonSize, height: arrowButtonSize),
      ),
      // Dots e layout in basso
      skipOrBackFlex: 0,
      nextFlex: 0,
      dotsFlex: 2,
      controlsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 98),
      baseBtnStyle: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(arrowButtonSize, arrowButtonSize),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      // Header in alto a destra: Salta/Inizia
      globalHeader: SafeArea(
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 24.0),
            child: Container(
              decoration: BoxDecoration(
                color: isLastPage
                    ? primaryColor
                    : primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isLastPage
                    ? [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: TextButton(
                onPressed: widget.onFinished,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  isLastPage ? "Inizia" : "Salta",
                  style: TextStyle(
                    fontSize: 18,
                    color: isLastPage ? Colors.white : primaryColor,
                    fontWeight: isLastPage ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      // Dots
      dotsDecorator: DotsDecorator(
        size: const Size(12.0, 12.0),
        color: primaryColor.withValues(alpha: 0.2),
        activeSize: const Size(28.0, 12.0),
        activeColor: primaryColor,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
}
