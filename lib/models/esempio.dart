// lib/models/esempio.dart
class Esempio {
  final String titolo;
  final String testo;

  Esempio({
    required this.titolo,
    required this.testo,
  });

  factory Esempio.fromJson(Map<String, dynamic> json) {
    return Esempio(
      titolo: json['titolo'] as String,
      testo: json['testo'] as String,
    );
  }
}