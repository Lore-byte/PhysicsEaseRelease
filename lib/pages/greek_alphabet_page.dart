// lib/pages/greek_alphabet_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class GreekAlphabetPage extends StatelessWidget {
  const GreekAlphabetPage({super.key});

  final List<Map<String, String>> _greekLetters = const [
    {
      'letter': 'Α α (Alfa)',
      'description': 'Accelerazione angolare, coefficiente di dilatazione termica, angolo.',
      'formula': r'\alpha = \frac{\Delta \omega}{\Delta t}',
      'formula_note': '(accelerazione angolare)'
    },
    {
      'letter': 'Β β (Beta)',
      'description': 'Angolo, fattore di velocità (v/c) in relatività.',
      'formula': r'\beta = v/c',
      'formula_note': '(rapporto velocità/luce)'
    },
    {
      'letter': 'Γ γ (Gamma)',
      'description': 'Fattore di Lorentz, coefficiente di dilatazione volumica, raggi gamma.',
      'formula': r'\gamma = \frac{1}{\sqrt{1-v^2/c^2}}',
      'formula_note': '(fattore di Lorentz)'
    },
    {
      'letter': 'Δ δ (Delta)',
      'description': 'Variazione, differenza. Simbolo maiuscolo (Δ) per variazioni finite, minuscolo (δ) per variazioni infinitesime.',
      'formula': r'\Delta x = x_f - x_i',
      'formula_note': '(variazione di posizione)'
    },
    {
      'letter': 'Ε ε (Epsilon)',
      'description': 'Permittività elettrica, deformazione in meccanica.',
      'formula': r'\vec{D} = \epsilon \vec{E}',
      'formula_note': '(vettore spostamento elettrico)'
    },
    {
      'letter': 'Ζ ζ (Zeta)',
      'description': 'Coefficiente di smorzamento (oscillazioni) o coordinata in fluidodinamica.',
      'formula': '',
      'formula_note': ''
    },
    {
      'letter': 'Η η (Eta)',
      'description': 'Viscosità dinamica, efficienza di un motore, indice di rifrazione.',
      'formula': r'F_d = 6\pi\eta r v',
      'formula_note': '(forza di Stokes)'
    },
    {
      'letter': 'Θ θ (Theta)',
      'description': 'Angolo, temperatura (in termodinamica).',
      'formula': r'\theta',
      'formula_note': '(angolo)'
    },
    {
      'letter': 'Ι ι (Iota)',
      'description': 'Simbolo poco comune, a volte utilizzato per indicare una variabile generica o una corrente (come i).',
      'formula': '',
      'formula_note': ''
    },
    {
      'letter': 'Κ κ (Kappa)',
      'description': 'Costante di compressibilità, costante dielettrica, curvatura.',
      'formula': r'K = -\frac{1}{V}\frac{\partial V}{\partial p}',
      'formula_note': '(costante di compressibilità)'
    },
    {
      'letter': 'Λ λ (Lambda)',
      'description': 'Lunghezza d\'onda, densità lineare di carica, costante cosmologica.',
      'formula': r'\lambda = v/f',
      'formula_note': '(lunghezza d\'onda)'
    },
    {
      'letter': 'Μ μ (Mu)',
      'description': 'Coefficiente di attrito, permeabilità magnetica, momento di dipolo magnetico.',
      'formula': r'F_{attrito} = \mu N',
      'formula_note': '(forza di attrito)'
    },
    {
      'letter': 'Ν ν (Nu)',
      'description': 'Frequenza (a volte al posto di f), coefficiente di Poisson, numero di moli.',
      'formula': r'\nu = - \frac{\varepsilon_{trasversale}}{\varepsilon_{longitudinale}}',
      'formula_note': '(coefficiente di Poisson)'
    },
    {
      'letter': 'Ξ ξ (Xi)',
      'description': 'Variabile di stato, ampiezza di reazione (in termodinamica).',
      'formula': '',
      'formula_note': ''
    },
    {
      'letter': 'Ο ο (Omicron)',
      'description': 'Lettera usata raramente in formule fisiche o matematiche. In alcuni casi può rappresentare la grande O della notazione asintotica (Big-O) in informatica e matematica.',
      'formula': r'T(n) = O(n^2)',
      'formula_note': '(notazione asintotica, complessità quadratica)'
    },
    {
      'letter': 'Π π (Pi)',
      'description': 'Costante matematica (3.14...), impulso. Simbolo maiuscolo (Π) per prodotto matematico.',
      'formula': r'C = 2\pi r',
      'formula_note': '(circonferenza)'
    },
    {
      'letter': 'Ρ ρ (Rho)',
      'description': 'Densità, resistività elettrica.',
      'formula': r'\rho = m/V',
      'formula_note': '(densità)'
    },
    {
      'letter': 'Σ σ (Sigma)',
      'description': 'Tensione meccanica, conducibilità elettrica, sezione d\'urto, deviazione standard. Simbolo maiuscolo (Σ) per sommatoria matematica.',
      'formula': '',
      'formula_note': ''
    },
    {
      'letter': 'Τ τ (Tau)',
      'description': 'Momento torcente, costante di tempo, periodo di decadimento.',
      'formula': r'\vec{\tau} = \vec{r} \times \vec{F}',
      'formula_note': '(momento torcente)'
    },
    {
      'letter': 'Υ υ (Ypsilon)',
      'description': 'Velocità (a volte, per distinguerla da v) o variabile di stato.',
      'formula': '',
      'formula_note': ''
    },
    {
      'letter': 'Φ φ (Phi)',
      'description': 'Flusso magnetico/elettrico, potenziale scalare, angolo di fase.',
      'formula': r'\Phi_B = \int \vec{B} \cdot d\vec{A}',
      'formula_note': '(flusso magnetico)'
    },
    {
      'letter': 'Χ χ (Chi)',
      'description': 'Suscettibilità elettrica/magnetica, frazione molare.',
      'formula': '',
      'formula_note': ''
    },
    {
      'letter': 'Ψ ψ (Psi)',
      'description': 'Funzione d\'onda in meccanica quantistica.',
      'formula': r'H\psi = E\psi',
      'formula_note': '(equazione di Schrödinger)'
    },
    {
      'letter': 'Ω ω (Omega)',
      'description': 'Velocità angolare, frequenza angolare. Simbolo maiuscolo (Ω) per resistenza elettrica (Ohm).',
      'formula': r'\omega = \frac{\Delta \theta}{\Delta t}',
      'formula_note': '(velocità angolare)'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alfabeto Greco'),
        backgroundColor: colorScheme.primaryContainer,
        iconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _greekLetters.length,
        itemBuilder: (context, index) {
          final letter = _greekLetters[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            color: colorScheme.surfaceContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    letter['letter']!,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    letter['description']!,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (letter['formula']!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Math.tex(
                          letter['formula']!,
                          textStyle: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                            fontSize: 18,
                          ),
                          mathStyle: MathStyle.display,
                          onErrorFallback: (flutterMathException) {
                            return Text(
                              'Errore nel rendering LaTeX: ${flutterMathException.message}',
                              style: TextStyle(color: colorScheme.error),
                            );
                          },
                        ),
                        if (letter['formula_note']!.isNotEmpty)
                          Text(
                            letter['formula_note']!,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}