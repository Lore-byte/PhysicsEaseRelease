// lib/models/formula.dart
import 'dart:convert';

class Formula {
  final String id;
  final String titolo;
  final String descrizione;
  final String formulaLatex;
  final String categoria;
  final String? sottocategoria;
  final List<Variable> variabili;
  final List<Example> esempi;
  final List<String> paroleChiave;

  Formula({
    required this.id,
    required this.titolo,
    required this.descrizione,
    required this.formulaLatex,
    required this.categoria,
    this.sottocategoria,
    this.variabili = const [],
    this.esempi = const [],
    this.paroleChiave = const [],
  });

  factory Formula.fromMap(Map<String, dynamic> map) {
    return Formula(
      id: map['id'] as String,
      titolo: map['titolo'] as String? ?? 'Titolo Sconosciuto',
      descrizione: map['descrizione'] as String? ?? '',
      formulaLatex: map['formula_latex'] as String? ?? '',
      categoria: map['categoria'] as String,
      sottocategoria: map['sottocategoria'] as String?,
      variabili: (map['variabili'] as List<dynamic>?)
          ?.map((v) => Variable.fromMap(v as Map<String, dynamic>))
          .toList() ??
          const [],
      esempi: (map['esempi'] as List<dynamic>?)
          ?.map((e) => Example.fromMap(e as Map<String, dynamic>))
          .toList() ??
          const [],
      paroleChiave: (map['parole_chiave'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          const [],
    );
  }
  factory Formula.fromJson(String jsonString) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return Formula.fromMap(jsonMap);
  }

  String toJson() {
    return jsonEncode({
      'id': id,
      'titolo': titolo,
      'descrizione': descrizione,
      'formula_latex': formulaLatex,
      'categoria': categoria,
      if (sottocategoria != null && sottocategoria!.isNotEmpty) 'sottocategoria': sottocategoria,
      'variabili': variabili.map((v) => v.toMap()).toList(),
      'esempi': esempi.map((e) => e.toMap()).toList(),
      'parole_chiave': paroleChiave,
    });
  }
}

class Variable {
  final String simbolo;
  final String descrizione;
  final String unita;

  const Variable({
    required this.simbolo,
    required this.descrizione,
    required this.unita,
  });

  factory Variable.fromMap(Map<String, dynamic> map) {
    return Variable(
      simbolo: map['simbolo'] as String? ?? '',
      descrizione: map['descrizione'] as String? ?? '',
      unita: map['unita'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'simbolo': simbolo,
      'descrizione': descrizione,
      'unita': unita,
    };
  }
}

class Example {
  final String titolo;
  final String testo;

  const Example({
    required this.titolo,
    required this.testo,
  });

  factory Example.fromMap(Map<String, dynamic> map) {
    return Example(
      titolo: map['titolo'] as String? ?? '',
      testo: map['testo'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titolo': titolo,
      'testo': testo,
    };
  }
}