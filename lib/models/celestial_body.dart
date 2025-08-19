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

  String get massScientific => "${massKg.toStringAsExponential(2)} kg";

  String get surfaceGravityString => "${surfaceGravityMetersPerSecondSquared.toStringAsFixed(2)} m/s²";

  String get distanceFromSunDisplay {
    if (type == 'Stella') return 'N/A (Centro del Sistema)';
    if (type == 'Satellite Naturale') return '${(distanceFromSunKm).toStringAsFixed(0)} km dalla Terra';
    return "${(distanceFromSunKm / 149.6e6).toStringAsFixed(2)} UA";
  }

  String get orbitalPeriodDisplay {
    if (type == 'Stella') return 'N/A';
    if (type == 'Satellite Naturale') return '${orbitalPeriodDays.toStringAsFixed(1)} giorni (della Terra)';
    return '${orbitalPeriodDays.toStringAsFixed(1)} giorni terrestri';
  }
}