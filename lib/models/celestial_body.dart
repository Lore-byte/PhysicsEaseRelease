// lib/models/celestial_body.dart
import 'package:flutter/material.dart';

class CelestialBody {
  final String id;
  final String name;
  final String type;
  final String description;
  final double massKg;
  final double radiusKm;
  final double orbitalPeriodDays;
  final double distanceFromSunKm;
  final double surfaceGravityMetersPerSecondSquared;
  final String imagePath;
  final Color color;

  CelestialBody({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.massKg,
    required this.radiusKm,
    this.orbitalPeriodDays = 0.0,
    this.distanceFromSunKm = 0.0,
    required this.surfaceGravityMetersPerSecondSquared,
    required this.imagePath,
    required this.color,
  });

  double get radiusMeters => radiusKm * 1000;

  String get massScientific {
    if (massKg == 0) return "0 kg";
    final expString = massKg.toStringAsExponential(2);
    final parts = expString.split('e');
    final mantissa = parts[0];
    final exponent = int.parse(parts[1]);
    return "$mantissa × 10^$exponent kg";
  }

  String get surfaceGravityString => "${surfaceGravityMetersPerSecondSquared.toStringAsFixed(2)} m/s²";

  String get distanceFromSunDisplay {
    if (type == 'Stella') return 'N/A (Centro del Sistema)';
    if (type == 'Satellite Naturale') return '${(distanceFromSunKm).toStringAsFixed(0)} km dalla Terra';
    return "${(distanceFromSunKm / 149.6e6).toStringAsFixed(2)} UA";
  }

  String get orbitalPeriodDisplay {
    if (type == 'Stella') return 'N/A';
    if (type == 'Satellite Naturale') {
      return '${_formatOrbitalPeriod(orbitalPeriodDays)} giorni (della Terra)';
    }
    return '${_formatOrbitalPeriod(orbitalPeriodDays)} giorni terrestri';
  }

  String _formatOrbitalPeriod(double days) {
    if (days % 1 == 0) {
      return days.toStringAsFixed(0);
    } else {
      return days.toStringAsFixed(1);
    }
  }
}