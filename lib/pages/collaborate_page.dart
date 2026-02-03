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

    final iconColor = colorScheme.primary;
    final textColor = colorScheme.onSurface;
    final cardColor = colorScheme.surfaceContainer;

    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + 16, left: 16.0, right: 16.0, top: MediaQuery.of(context).viewPadding.top + 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Unisciti al progetto PhysicsEase!',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'PhysicsEase è un progetto open source nato con l\'obiettivo di rendere la fisica più accessibile a tutti. Crediamo nel potere della collaborazione e per questo il codice sorgente completo è a disposizione di chiunque voglia contribuire.',
                  style: textTheme.bodyLarge?.copyWith(color: textColor),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 32),

                Text(
                  'Codice sorgente',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  color: cardColor,
                  child: ListTile(
                    leading: Icon(Icons.code, color: iconColor),
                    title: Text('Visualizza su GitHub', style: textTheme.titleMedium?.copyWith(color: textColor)),
                    subtitle: Text('https://github.com/Lore-byte/PhysicsEaseRelease', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                    trailing: Icon(Icons.open_in_new, size: 20, color: colorScheme.onSurfaceVariant),
                    onTap: () async {
                      final url = Uri.parse('https://github.com/Lore-byte/PhysicsEaseRelease');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Impossibile aprire il link.')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Sviluppo in flutter',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  color: cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'L\'applicazione è interamente sviluppata in Flutter, il framework di UI di Google per la creazione di applicazioni native multi-piattaforma da un singolo codebase. Questo ci permette di raggiungere un vasto pubblico su Android e iOS con un\'esperienza utente fluida e moderna.',
                          style: textTheme.bodyLarge?.copyWith(color: textColor),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Se hai esperienza con Flutter, il tuo contributo sarebbe particolarmente apprezzato!',
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Aggiornamenti dei contenuti',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  color: cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hai trovato un errore in una formula? Vuoi suggerire l\'aggiunta di nuove formule o argomenti? Puoi contribuire direttamente!',
                          style: textTheme.bodyLarge?.copyWith(color: textColor),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'I database delle formule sono semplici file JSON facilmente accessibili nella cartella `assets` della repository GitHub. Crea una "Pull Request" con le tue modifiche, e dopo una revisione, verranno integrate nell\'app!',
                          style: textTheme.bodyLarge?.copyWith(color: textColor),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Questa è una modalità di contributo ideale anche per chi non ha esperienza di sviluppo codice ma conosce bene la fisica!',
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Come puoi contribuire ancora?',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  color: cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBulletPoint(
                            context, 'Segnalazione Bug: Hai riscontrato un problema o un crash? Segnalalo nella sezione "Issues" su GitHub!', textColor),
                        _buildBulletPoint(
                            context, 'Miglioramenti UI/UX: Se hai idee su come rendere l\'interfaccia utente più intuitiva o l\'esperienza più piacevole, condividile!', textColor),
                        _buildBulletPoint(
                            context, 'Diffondi la Voce: Parla di PhysicsEase ai tuoi amici, colleghi o studenti. Più persone la useranno, più feedback riceveremo!', textColor),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Ogni contributo, grande o piccolo, è prezioso e apprezzato. Entra a far parte della nostra community e aiutaci a costruire la migliore app di fisica!',
                    style: textTheme.bodyMedium?.copyWith(color: textColor),
                    textAlign: TextAlign.center,
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
              title: 'Collabora con noi',
              leading: FloatingTopBarLeading.back,
              onBackPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text, Color textColor) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: textTheme.bodyLarge?.copyWith(color: textColor)),
          Expanded(
            child: Text(text, style: textTheme.bodyLarge?.copyWith(color: textColor)),
          ),
        ],
      ),
    );
  }
}