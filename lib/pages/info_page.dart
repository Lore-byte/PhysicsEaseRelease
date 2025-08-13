// lib/pages/info_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  final ThemeMode themeMode;

  const InfoPage({
    super.key,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final iconColor = colorScheme.primary;
    final textColor = colorScheme.onSurface;
    final cardColor = colorScheme.surfaceContainer;

    final String logoAssetPath = themeMode == ThemeMode.dark
        ? 'assets/my_logo_dark.png'
        : 'assets/my_logo_light.png';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informazioni sull\'App'),
        backgroundColor: colorScheme.primaryContainer,
        iconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.asset(
                  logoAssetPath,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image,
                      size: 150,
                      color: colorScheme.primary,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Contatta gli sviluppatori',
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
                leading: Icon(Icons.email, color: iconColor),
                title: Text('Invia un\'Email', style: textTheme.titleMedium?.copyWith(color: textColor)),
                subtitle: Text('physicsease.app@gmail.com', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurfaceVariant),
                onTap: () async {
                  final Uri emailLaunchUri = Uri.parse(
                    'mailto:physicsease.app@gmail.com?subject=Supporto PhysicEase: [Il tuo Messaggio]',
                  );

                  if (await canLaunchUrl(emailLaunchUri)) {
                    await launchUrl(emailLaunchUri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Impossibile aprire l\'applicazione email. Copia l\'indirizzo: lmala06.tech@gmail.com')),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Informazioni sull\'App',
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
                      'Questa applicazione è stata sviluppata da Lorenzo Malanotte e Edoardo Beldiman. '
                          'Il nostro obiettivo è rendere lo studio della fisica un\'esperienza coinvolgente e intuitiva per tutti.',
                      style: textTheme.bodyLarge?.copyWith(color: textColor),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Speriamo sinceramente che PhysicsEase ti sia un valido supporto nel tuo percorso di apprendimento, rendendo ogni concetto più chiaro e accessibile.',
                      style: textTheme.bodyLarge?.copyWith(color: textColor),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Versione App: 1.0.0',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                '© 2025 PhysicsEase. Tutti i diritti riservati.',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}