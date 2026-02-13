// lib/pages/planets_page.dart
import 'package:flutter/material.dart';
import 'package:physics_ease_release/theme/app_colors.dart';
import 'package:physics_ease_release/models/celestial_body.dart';
//import 'dart:math';
import 'package:physics_ease_release/widgets/floating_top_bar.dart';

class PlanetsPage extends StatelessWidget {
  const PlanetsPage({super.key});

  static final List<CelestialBody> celestialBodies = [
    CelestialBody(
      id: 'sun',
      name: 'Sole',
      type: 'Stella',
      description:
          'Il Sole è la stella al centro del nostro Sistema Solare. È una gigantesca sfera di gas incandescenti che produce energia attraverso la fusione nucleare.',
      massKg: 1.989 * 1e30,
      radiusKm: 696340,
      orbitalPeriodDays: 0.0,
      distanceFromSunKm: 0.0,
      surfaceGravityMetersPerSecondSquared: 274.0,
      imagePath: 'assets/planet/sun.png',
      color: AppColors.yellow[700]!,
    ),
    CelestialBody(
      id: 'mercury',
      name: 'Mercurio',
      type: 'Pianeta',
      description: 'Il pianeta più piccolo e più vicino al Sole.',
      massKg: 3.3011 * 1e23,
      radiusKm: 2439.7,
      orbitalPeriodDays: 87.97,
      distanceFromSunKm: 57.91e6,
      surfaceGravityMetersPerSecondSquared: 3.70,
      imagePath: 'assets/planet/mercury.png',
      color: AppColors.grey[700]!,
    ),
    CelestialBody(
      id: 'venus',
      name: 'Venere',
      type: 'Pianeta',
      description: 'Conosciuto come la "stella del mattino" o della "sera".',
      massKg: 4.8675 * 1e24,
      radiusKm: 6051.8,
      orbitalPeriodDays: 224.70,
      distanceFromSunKm: 108.2e6,
      surfaceGravityMetersPerSecondSquared: 8.87,
      imagePath: 'assets/planet/venus.png',
      color: AppColors.orange[800]!,
    ),
    CelestialBody(
      id: 'earth',
      name: 'Terra',
      type: 'Pianeta',
      description: 'Il nostro pianeta, unico noto per ospitare la vita.',
      massKg: 5.972 * 1e24,
      radiusKm: 6371,
      orbitalPeriodDays: 365.25,
      distanceFromSunKm: 149.6e6,
      surfaceGravityMetersPerSecondSquared: 9.81,
      imagePath: 'assets/planet/earth.png',
      color: AppColors.blue[600]!,
    ),
    CelestialBody(
      id: 'moon',
      name: 'Luna',
      type: 'Satellite Naturale',
      description:
          'La Luna è l\'unico satellite naturale della Terra. Influisce sulle maree oceaniche e stabilizza l\'asse di rotazione terrestre.',
      massKg: 7.342 * 1e22,
      radiusKm: 1737.4,
      orbitalPeriodDays: 27.32,
      distanceFromSunKm: 384400,
      surfaceGravityMetersPerSecondSquared: 1.63,
      imagePath: 'assets/planet/moon.png',
      color: AppColors.blueGrey[300]!,
    ),
    CelestialBody(
      id: 'mars',
      name: 'Marte',
      type: 'Pianeta',
      description: 'Il pianeta rosso, oggetto di grande interesse scientifico.',
      massKg: 6.4171 * 1e23,
      radiusKm: 3389.5,
      orbitalPeriodDays: 686.97,
      distanceFromSunKm: 227.9e6,
      surfaceGravityMetersPerSecondSquared: 3.71,
      imagePath: 'assets/planet/mars.png',
      color: AppColors.red[800]!,
    ),
    CelestialBody(
      id: 'jupiter',
      name: 'Giove',
      type: 'Pianeta',
      description: 'Il gigante gassoso del sistema solare.',
      massKg: 1.8982 * 1e27,
      radiusKm: 69911,
      orbitalPeriodDays: 4332.59,
      distanceFromSunKm: 778.5e6,
      surfaceGravityMetersPerSecondSquared: 24.79,
      imagePath: 'assets/planet/jupiter.png',
      color: AppColors.orange[400]!,
    ),
    CelestialBody(
      id: 'saturn',
      name: 'Saturno',
      type: 'Pianeta',
      description: 'Famoso per i suoi anelli spettacolari.',
      massKg: 5.6834 * 1e26,
      radiusKm: 58232,
      orbitalPeriodDays: 10759.22,
      distanceFromSunKm: 1.433e9,
      surfaceGravityMetersPerSecondSquared: 10.44,
      imagePath: 'assets/planet/saturn.png',
      color: AppColors.yellow[700]!,
    ),
    CelestialBody(
      id: 'uranus',
      name: 'Urano',
      type: 'Pianeta',
      description: 'Un gigante di ghiaccio con un\'orbita peculiare.',
      massKg: 8.6810 * 1e25,
      radiusKm: 25362,
      orbitalPeriodDays: 30688.46,
      distanceFromSunKm: 2.874e9,
      surfaceGravityMetersPerSecondSquared: 8.69,
      imagePath: 'assets/planet/uranus.png',
      color: AppColors.blueAccent[100]!,
    ),
    CelestialBody(
      id: 'neptune',
      name: 'Nettuno',
      type: 'Pianeta',
      description: 'Il pianeta più lontano dal Sole, un gigante di ghiaccio.',
      massKg: 1.02413 * 1e26,
      radiusKm: 24622.0,
      orbitalPeriodDays: 60182,
      distanceFromSunKm: 4.504e9,
      surfaceGravityMetersPerSecondSquared: 11.15,
      imagePath: 'assets/planet/neptune.png',
      color: AppColors.indigo[800]!,
    ),
    CelestialBody(
      id: 'pluto',
      name: 'Plutone',
      type: 'Pianeta nano',
      description:
          'Un pianeta nano della fascia di Kuiper, un tempo considerato il nono pianeta del Sistema Solare.',
      massKg: 1.303 * 1e22,
      radiusKm: 1188.3,
      orbitalPeriodDays: 90560,
      distanceFromSunKm: 5.906e9,
      surfaceGravityMetersPerSecondSquared: 0.62,
      imagePath: 'assets/planet/pluto.png',
      color: AppColors.brown[400]!,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<CelestialBody> planetsOnly = celestialBodies
        .where((body) => body.type == 'Pianeta')
        .toList();
    final double maxPlanetRadius = planetsOnly
        .map((p) => p.radiusKm)
        .reduce((a, b) => a > b ? a : b);
    final double minPlanetRadius = planetsOnly
        .map((p) => p.radiusKm)
        .reduce((a, b) => a < b ? a : b);

    const double minCircleSize = 50.0;
    const double maxCircleSize = 120.0;

    final screenWidth = MediaQuery.of(context).size.width;
    final double dynamicChildAspectRatio = screenWidth < 400 ? 0.7 : 0.8;

    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewPadding.bottom + 80,
              left: 16,
              right: 16,
              top: MediaQuery.of(context).viewPadding.top + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: dynamicChildAspectRatio,
                  ),
                  itemCount: celestialBodies.length,
                  itemBuilder: (context, index) {
                    final body = celestialBodies[index];
                    double circleSize;

                    if (body.type == 'Stella') {
                      circleSize = maxCircleSize;
                    } else if (body.type == 'Satellite Naturale') {
                      circleSize = minCircleSize * 0.8;
                    } else {
                      final double normalizedRadius =
                          (body.radiusKm - minPlanetRadius) /
                          (maxPlanetRadius - minPlanetRadius);
                      circleSize =
                          minCircleSize +
                          (normalizedRadius * (maxCircleSize - minCircleSize));
                    }

                    return _buildCelestialBodyCard(context, body, circleSize);
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).viewPadding.top,
            left: 16,
            right: 16,
            child: FloatingTopBar(
              title: 'Sistema Solare',
              leading: FloatingTopBarLeading.back,
              onBackPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelestialBodyCard(
    BuildContext context,
    CelestialBody body,
    double circleSize,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showCelestialBodyDetails(context, body);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: Image.asset(
                  body.imagePath,
                  width: circleSize,
                  height: circleSize,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                body.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                body.type,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  void _showCelestialBodyDetails(BuildContext context, CelestialBody body) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '${body.name} (${body.type})',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: ClipOval(
                    child: Image.asset(
                      body.imagePath,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  body.description,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const Divider(height: 30),
                _buildDetailRow(context, 'Massa:', body.massScientific),
                _buildDetailRow(context, 'Raggio:', '${body.radiusKm} km'),
                _buildDetailRow(
                  context,
                  'Periodo Orbitale:',
                  body.orbitalPeriodDisplay,
                ),
                _buildDetailRow(
                  context,
                  'Distanza:',
                  body.distanceFromSunDisplay,
                ),
                _buildDetailRow(
                  context,
                  'Gravità Superficiale:',
                  body.surfaceGravityString,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Chiudi',
                style: TextStyle(color: colorScheme.onPrimary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
