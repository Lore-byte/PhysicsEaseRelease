import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';

class PrivacyPolicyPage extends StatelessWidget {
  final ThemeMode themeMode;

  const PrivacyPolicyPage({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    final currentColorScheme = Theme.of(context).colorScheme;

    final Uri _url = Uri.parse(
        'https://sites.google.com/view/physicsease-privacy-policy/home');


    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + 16, left: 16.0, right: 16.0, top: MediaQuery.of(context).viewPadding.top + 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
          Positioned(
            top: MediaQuery.of(context).viewPadding.top,
            left: 16,
            right: 16,
            child: FloatingTopBar(
              title: 'Privacy Policy',
              leading: FloatingTopBarLeading.back,
              onBackPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      )
    );
  }
}
