// lib/pages/help_page.dart
import 'package:flutter/material.dart';
import 'package:physics_ease_release/pages/onboarding_page.dart';
import 'package:physics_ease_release/pages/quiz_page.dart';
import 'package:physics_ease_release/pages/calculator_page.dart';
import 'package:physics_ease_release/pages/data_page.dart';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';

class HelpPage extends StatelessWidget {
  final ThemeMode themeMode;
  final void Function(bool) setGlobalAppBarVisibility;
  final Future<void> Function(BuildContext, String) onNavigateToSection;

  const HelpPage({
    super.key,
    required this.themeMode,
    required this.setGlobalAppBarVisibility,
    required this.onNavigateToSection,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewPadding.bottom + 16,
              left: 0,
              right: 0,
              top: MediaQuery.of(context).viewPadding.top + 70,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                _buildInfoCard(
                  context: context,
                  icon: Icons.quiz,
                  title: 'Quiz interattivi',
                  description:
                      'Metti alla prova le tue conoscenze con quiz su vari argomenti di fisica. Scegli categoria, difficoltà e numero di domande. Visualizza statistiche dettagliate e rivedi le domande sbagliate.',
                  colorScheme: colorScheme,
                  onTap: () async {
                    setGlobalAppBarVisibility(false);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => QuizPage(
                          setGlobalAppBarVisibility: setGlobalAppBarVisibility,
                        ),
                      ),
                    );
                    setGlobalAppBarVisibility(true);
                  },
                ),

                _buildInfoCard(
                  context: context,
                  icon: Icons.search,
                  title: 'Cerca formule',
                  description:
                      'Usa la barra di ricerca nella schermata Home per trovare rapidamente formule per titolo, descrizione o parole chiave.',
                  colorScheme: colorScheme,
                  onTap: () async {
                    await onNavigateToSection(context, 'search');
                  },
                ),

                _buildInfoCard(
                  context: context,
                  icon: Icons.star,
                  title: 'Preferiti',
                  description:
                      'Tocca la stella per salvare le formule che usi più spesso. Accedi rapidamente dalla sezione Preferiti.',
                  colorScheme: colorScheme,
                  onTap: () async {
                    await onNavigateToSection(context, 'favorites');
                  },
                ),

                _buildInfoCard(
                  context: context,
                  icon: Icons.calculate,
                  title: 'Calcolatrice scientifica',
                  description:
                      'Calcolatrice avanzata con funzioni scientifiche complete. Supporta espressioni matematiche complesse, funzioni trigonometriche e logaritmi.',
                  colorScheme: colorScheme,
                  onTap: () async {
                    await onNavigateToSection(context, 'calculator');
                  },
                ),
                
                 _buildInfoCard(
                  context: context,
                  icon: Icons.storage,
                  title: 'Dati scientifici',
                  description:
                      'Costanti fisiche, dati planetari, tavola periodica completa, biografie di fisici famosi, alfabeto greco e unità di misura.',
                  colorScheme: colorScheme,
                  onTap: () async {
                    await onNavigateToSection(context, 'data');
                  },
                ),

                _buildInfoCard(
                  context: context,
                  icon: Icons.build,
                  title: 'Strumenti avanzati',
                  description:
                      'Convertitore di unità, risolutore di equazioni, visualizzatore di grafici, calcolatore vettoriale e formule personalizzate. Utilizza i sensori del dispositivo per esperimenti real-time.',
                  colorScheme: colorScheme,
                  onTap: () async {
                    await onNavigateToSection(context, 'tools');
                  },
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => OnboardingPage(
                                onFinished: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 24,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.slideshow_rounded,
                                  size: 32,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Rivedi l'onboarding",
                                      style: textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Scopri di nuovo tutte le funzionalità",
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onPrimary
                                            .withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: colorScheme.onPrimary,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: Text(
                    '© 2026 PhysicsEase. Tutti i diritti riservati.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).viewPadding.top,
            left: 16,
            right: 16,
            child: FloatingTopBar(
              title: 'Aiuto',
              leading: FloatingTopBarLeading.back,
              onBackPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(
    BuildContext context,
    IconData icon,
    String text,
    ColorScheme colorScheme,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required ColorScheme colorScheme,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: colorScheme.primary),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 15,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
