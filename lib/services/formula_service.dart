// lib/services/formula_service.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:physics_ease_release/models/formula.dart';
import 'dart:developer' as developer;

class FormulaService {
  static Future<List<Formula>> loadAllFormulas() async {
    try {
      final List<String> assetPaths = [
        'assets/kinematica.json',
        'assets/dinamica.json',
        'assets/termodinamica.json',
        'assets/lavoro.json',
        'assets/elettrostatica.json',
        'assets/elettromagnetismo.json',
        'assets/ottica.json',
        'assets/fluidi.json',
        'assets/gravitazione.json',
        'assets/qmoto.json',
        'assets/momentoangolare.json',
        'assets/circuiti.json',
        'assets/magnetismo.json',
        'assets/relativita.json',
      ];

      var allLoadedFormulas = <Formula>[];
      developer.log('Inizio caricamento formule dagli asset.');

      for (String path in assetPaths) {
        try {
          developer.log('Tentativo di caricamento: $path');
          final String jsonData = await rootBundle.loadString(path);
          developer.log('Dati JSON caricati da $path: ${jsonData.substring(0, jsonData.length > 100 ? 100 : jsonData.length)}...');

          final List<dynamic> jsonList = json.decode(jsonData) as List<dynamic>;
          developer.log('Decodificati ${jsonList.length} elementi da $path');

          allLoadedFormulas.addAll(
            jsonList.map((e) => Formula.fromMap(e as Map<String, dynamic>)),
          );
          developer.log('Aggiunte formule da $path. Totale formule caricate: ${allLoadedFormulas.length}');

        } on Exception catch (e, stacktrace) {
          developer.log('Errore durante il caricamento di $path: $e', error: e, stackTrace: stacktrace);
        }
      }
      developer.log('Caricamento formule dagli asset completato. Totale finali: ${allLoadedFormulas.length}');
      return allLoadedFormulas;
    } on Exception catch (e, stacktrace) {
      developer.log('Errore generale durante il caricamento delle formule: $e', error: e, stackTrace: stacktrace);
      return [];
    }
  }
}