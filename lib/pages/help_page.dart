// lib/pages/help_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {
  final ThemeMode themeMode;

  const HelpPage({
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aiuto'),
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

            Text(
              'Come Usare l\'App',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              cardColor,
              iconColor,
              Icons.search,
              'Cerca Formule',
              'Usa la barra di ricerca nella schermata Home per trovare rapidamente formule per titolo, descrizione o parole chiave. Puoi anche filtrare per categorie specifiche.',
            ),
            _buildInfoCard(
              context,
              cardColor,
              iconColor,
              Icons.star,
              'I Tuoi Preferiti',
              'Tocca l\'icona a stella su qualsiasi formula per aggiungerla o rimuoverla dai tuoi preferiti. Troverai tutte le formule salvate nella sezione "Preferiti" per un accesso rapido.',
            ),
            _buildInfoCard(
              context,
              cardColor,
              iconColor,
              Icons.calculate,
              'Calcolatrice Integrata',
              'La sezione "Calcolatrice" offre uno strumento utile per i tuoi calcoli rapidi. Puoi inserire espressioni matematiche complesse e ottenere risultati istantanei.',
            ),
            _buildInfoCard(
              context,
              cardColor,
              iconColor,
              Icons.storage,
              'Informazioni e Dati',
              'Nella sezione "Dati" troverai raccolte di informazioni utili come liste di costanti fisiche, unità di misura, dati sui pianeti e la tavola periodica. Ideale per la consultazione rapida.',
            ),
            _buildInfoCard(
              context,
              cardColor,
              iconColor,
              Icons.build,
              'Strumenti Utili',
              'La sezione "Tools" mette a tua disposizione strumenti interattivi come la possibilità di aggiungere le tue formule personalizzate, un convertitore di unità e un potente risolutore di equazioni.',
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

  Widget _buildInfoCard(
      BuildContext context,
      Color cardBgColor,
      Color iconColor,
      IconData icon,
      String title,
      String description,
      ) {
    final textTheme = Theme.of(context).textTheme;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subtitleColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: cardBgColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: textTheme.bodyMedium?.copyWith(color: subtitleColor),
                    textAlign: TextAlign.justify,
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