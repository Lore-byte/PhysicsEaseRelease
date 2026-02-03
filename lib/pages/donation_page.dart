import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';

class DonationPage extends StatelessWidget {
  final ThemeMode themeMode;

  const DonationPage({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    final currentColorScheme = Theme.of(context).colorScheme;

    final Uri url = Uri.parse('https://github.com/sponsors/Lore-byte');


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
                    Icons.volunteer_activism,
                    size: 80,
                    color: currentColorScheme.primary,
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Il tuo supporto, anche piccolo, fa la differenza',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: currentColorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'PhysicsEase è e rimarrà sempre gratuita per tutti gli utenti. Il tuo contributo ci aiuta a continuare a sviluppare nuove funzionalità e a mantenere l\'app aggiornata senza pubblicità invasive.',
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
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } else {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Impossibile aprire il link.')),
                            );
                          }
                        },
                        icon: const Icon(Icons.open_in_new, size: 32),
                        label: const Text('Dona ora!'),
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
                title: 'Donazioni',
                leading: FloatingTopBarLeading.back,
                onBackPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        )
    );
  }
}
