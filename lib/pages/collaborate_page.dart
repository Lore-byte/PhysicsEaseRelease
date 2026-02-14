import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';

class CollaboratePage extends StatelessWidget {
  final ThemeMode themeMode;

  const CollaboratePage({super.key, required this.themeMode});

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
              left: 16.0,
              right: 16.0,
              top: MediaQuery.of(context).viewPadding.top + 70,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.people_rounded,
                          size: 80,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Unisciti al progetto PhysicsEase!',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'PhysicsEase è un progetto open source nato con l\'obiettivo di rendere la fisica più accessibile a tutti. Crediamo nel potere della collaborazione e per questo il codice sorgente completo è a disposizione di chiunque voglia contribuire.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final url = Uri.parse('https://github.com/Lore-byte/PhysicsEaseRelease');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Impossibile aprire il link.'),
                              backgroundColor: colorScheme.error,
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.code_rounded,
                                size: 36,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Codice sorgente',
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Visualizza su GitHub',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onPrimary.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.open_in_new_rounded,
                              color: colorScheme.onPrimary,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                _buildSectionCard(
                  context: context,
                  icon: Icons.flutter_dash,
                  title: 'Sviluppo in Flutter',
                  description:
                      'L\'applicazione è interamente sviluppata in Flutter, il framework di UI di Google per la creazione di applicazioni native multi-piattaforma da un singolo codebase. Questo ci permette di raggiungere un vasto pubblico su Android e iOS con un\'esperienza utente fluida e moderna.',
                  highlight: 'Se hai esperienza con Flutter, il tuo contributo sarebbe particolarmente apprezzato!',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 16),

                _buildSectionCard(
                  context: context,
                  icon: Icons.edit_note_rounded,
                  title: 'Aggiornamenti dei contenuti',
                  description:
                      'Hai trovato un errore in una formula? Vuoi suggerire l\'aggiunta di nuove formule o argomenti? Puoi contribuire direttamente!\n\nI database delle formule sono semplici file JSON facilmente accessibili nella cartella assets della repository GitHub. Crea una "Pull Request" con le tue modifiche, e dopo una revisione, verranno integrate nell\'app!',
                  highlight: 'Questa è una modalità di contributo ideale anche per chi non ha esperienza di sviluppo codice ma conosce bene la fisica!',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 32),

                Text(
                  'Altri modi per contribuire',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildContributionItem(
                  context: context,
                  icon: Icons.bug_report_rounded,
                  title: 'Segnalazione Bug',
                  description: 'Hai riscontrato un problema o un crash? Segnalalo nella sezione "Issues" su GitHub!',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 12),
                
                _buildContributionItem(
                  context: context,
                  icon: Icons.design_services_rounded,
                  title: 'Miglioramenti UI/UX',
                  description: 'Se hai idee su come rendere l\'interfaccia utente più intuitiva o l\'esperienza più piacevole, condividile!',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 12),
                
                _buildContributionItem(
                  context: context,
                  icon: Icons.campaign_rounded,
                  title: 'Diffondi la Voce',
                  description: 'Parla di PhysicsEase ai tuoi amici, colleghi o studenti. Più persone la useranno, più feedback riceveremo!',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                
                const SizedBox(height: 32),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.volunteer_activism_rounded,
                        color: colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Ogni contributo, grande o piccolo, è prezioso e apprezzato. Entra a far parte della nostra community e aiutaci a costruire la migliore app di fisica!',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).viewPadding.top,
            left: 16,
            right: 16,
            child: FloatingTopBar(
              title: 'Collabora con noi',
              leading: FloatingTopBarLeading.back,
              onBackPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String highlight,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.secondary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_rounded,
                    size: 20,
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      highlight,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 24,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}