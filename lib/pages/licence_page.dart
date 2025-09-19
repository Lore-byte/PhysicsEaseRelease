import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LicencePage extends StatelessWidget {
  final ThemeMode themeMode;

  const LicencePage({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    final currentColorScheme = Theme.of(context).colorScheme;

    final Uri _url = Uri.parse(
        'https://sites.google.com/view/physicsease-license/home');

    final String logoAssetPath = themeMode == ThemeMode.dark
        ? 'assets/my_logo_dark.png'
        : 'assets/my_logo_light.png';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Licenza'),
        backgroundColor: currentColorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo con contenimento proporzionato
            SizedBox(
              width: 160,
              height: 160,
              child: Image.asset(
                logoAssetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_outlined,
                    size: 100,
                    color: currentColorScheme.primary,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            Icon(
              Icons.balance,
              size: 80,
              color: currentColorScheme.primary,
            ),
            const SizedBox(height: 24),

            Text(
              'Per un uso sicuro e consapevole.',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: currentColorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              'Puoi trovare nella licenza completa tutte le informazioni sui termini e le condizioni d’uso dell’app.',
              style: TextStyle(
                fontSize: 16,
                color: currentColorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 320, // larghezza massima del bottone
                ),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (await canLaunchUrl(_url)) {
                      await launchUrl(_url, mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Impossibile aprire il link.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.open_in_new, size: 32),
                  label: const Text('Apri la Licenza'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentColorScheme.primary,
                    foregroundColor: currentColorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 22, // più alto
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40), // più stondato
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 6, // ombra per risalto
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
