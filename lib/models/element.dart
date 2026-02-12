// lib/models/element.dart
import 'package:flutter/material.dart';
import 'package:physics_ease_release/theme/app_colors.dart';

class Element {
  final int number;
  final String symbol;
  final String name;
  final double atomicMass;
  final String category;
  final String electronicConfiguration;
  final double meltingPointK;
  final double boilingPointK;
  final double density;
  final String discoveredBy;
  final int yearDiscovered;
  final String description;
  final int xpos;
  final int ypos;
  final String? shell;
  final String? block;

  final Color displayColor;

  Element({
    required this.number,
    required this.symbol,
    required this.name,
    required this.atomicMass,
    required this.category,
    required this.electronicConfiguration,
    this.meltingPointK = 0.0,
    this.boilingPointK = 0.0,
    this.density = 0.0,
    this.discoveredBy = 'Sconosciuto',
    this.yearDiscovered = 0,
    this.description = 'Nessuna descrizione disponibile.',
    required this.xpos,
    required this.ypos,
    this.shell,
    this.block,
    required this.displayColor,
  });

  String get formattedAtomicMass =>
      atomicMass > 0 ? '${atomicMass.toStringAsFixed(3)} u' : 'N/D';
  String get formattedMeltingPoint => meltingPointK > 0
      ? '${(meltingPointK - 273.15).toStringAsFixed(2)} °C (${meltingPointK.toStringAsFixed(2)} K)'
      : 'N/D';
  String get formattedBoilingPoint => boilingPointK > 0
      ? '${(boilingPointK - 273.15).toStringAsFixed(2)} °C (${boilingPointK.toStringAsFixed(2)} K)'
      : 'N/D';
  String get formattedDensity =>
      density > 0 ? '${density.toStringAsFixed(3)} g/cm³' : 'N/D';

  static Color getColorForCategory(String category) {
    switch (category) {
      case 'Metalli alcalini':
        return AppColors.red[300]!;
      case 'Metalli alcalino terrosi':
        return AppColors.orange[300]!;
      case 'Lantanidi':
        return AppColors.purple[300]!;
      case 'Attinidi':
        return AppColors.deepPurple[300]!;
      case 'Metalli di transizione':
        return AppColors.pink[300]!;
      case 'Metalli del blocco p':
        return AppColors.green[300]!;
      case 'Metalloidi':
        return AppColors.teal[300]!;
      case 'Non metalli':
        return AppColors.yellow[300]!;
      case 'Alogeni':
        return AppColors.blue[300]!;
      case 'Gas nobili':
        return AppColors.indigo[300]!;
      case 'Sconosciuta, probabilmente un metalloide':
        return AppColors.brown[300]!;
      case 'Sconosciuta, probabilmente un non metallo':
        return AppColors.lightGreen[300]!;
      case 'Sconosciuta, probabilmente un metallo di transizione':
        return AppColors.cyan[300]!;
      default:
        return AppColors.grey[300]!;
    }
  }
}
