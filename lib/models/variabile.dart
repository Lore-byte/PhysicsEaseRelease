// lib/models/variabile.dart
class Variabile {
  final String simbolo;
  final String descrizione;
  final String unita;

  Variabile({
    required this.simbolo,
    required this.descrizione,
    required this.unita,
  });

  factory Variabile.fromJson(Map<String, dynamic> json) {
    return Variabile(
      simbolo: json['simbolo'] as String,
      descrizione: json['descrizione'] as String,
      unita: json['unita'] as String,
    );
  }
}