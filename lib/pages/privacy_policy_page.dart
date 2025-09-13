import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatelessWidget {
  final ThemeMode themeMode;

  const PrivacyPolicyPage({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    final currentColorScheme = Theme.of(context).colorScheme;

    final Uri _url = Uri.parse(
        'https://sites.google.com/view/physicsease-privacy-policy/home?authuser=1');

    final String logoAssetPath = themeMode == ThemeMode.dark
        ? 'assets/my_logo_dark.png'
        : 'assets/my_logo_light.png';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
              Icons.privacy_tip_outlined,
              size: 80,
              color: currentColorScheme.primary,
            ),
            const SizedBox(height: 24),

            Text(
              'La nostra priorità è la tua privacy.',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: currentColorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              'Per garantire la massima trasparenza puoi consultare la nostra politica sulla privacy completa.',
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
                  label: const Text('Apri la Privacy Policy'),
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
