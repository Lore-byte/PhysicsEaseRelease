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
      'description': 'Angolo, velocità relativa (in relatività).',
      'formula': r'\beta = v/c',
      'formula_note': '(rapporto velocità/luce)'
    },
    {
      'letter': 'Γ γ (Gamma)',
      'description': 'Fattore di Lorentz, coefficiente di dilatazione volumica, raggi gamma.',
      'formula': r'\gamma = 1/\sqrt{1-v^2/c^2}',
      'formula_note': '(fattore di Lorentz)'
    },
    {
      'letter': 'Δ δ (Delta)',
      'description': r'''Variazione, differenza (es. $\Delta t$ per variazione di tempo). Simbolo maiuscolo ($\Delta$) per differenze finite, Laplaciano.''', // Fixed
      'formula': '',
      'formula_note': ''
    },
    {
      'letter': 'Ε ε (Epsilon)',
      'description': 'Permittività elettrica, deformazione.',
      'formula': r'\vec{D} = \epsilon \vec{E}',
      'formula_note': '(vettore spostamento elettrico)'
    },
    {
      'letter': 'Ζ ζ (Zeta)',
      'description': 'Coefficiente di smorzamento (oscillazioni).',
      'formula': '',
      'formula_note': ''
    },
    {
      'letter': 'Η η (Eta)',
      'description': 'Viscosità dinamica, efficienza.',
      'formula': r'F_d = 6\pi\eta r v',
      'formula_note': '(forza di Stokes)'
    },
    {
      'letter': 'Θ θ (Theta)',
      'description': r'''Angolo, temperatura (in termodinamica, a volte come $\Theta$).''',
      'formula': r'\theta',
      'formula_note': '(angolo)'
    },
    {
      'letter': 'Λ λ (Lambda)',
      'description': r'''Lunghezza d\'onda, densità lineare di carica, costante cosmologica.''',
      'formula': r'\lambda = v/f',
      'formula_note': '(lunghezza d\'onda)'
    },
    {
      'letter': 'Μ μ (Mu)',
      'description': r'''Coefficiente di attrito, permeabilità magnetica ($ \mu_0 $), momento di dipolo magnetico.''',
      'formula': r'F_{attrito} = \mu_s N',
      'formula_note': '(forza di attrito)'
    },
    {
      'letter': 'Ν ν (Nu)',
      'description': r'''Frequenza (a volte al posto di $f$).''',
      'formula': r'E = h\nu',
      'formula_note': '(energia del fotone)'
    },
    {
      'letter': 'Ξ ξ (Xi)',
      'description': 'Variabile di stato, ampiezza di reazione (in termodinamica).',
      'formula': '',
      'formula_note': ''
    },
    {
      'letter': 'Π π (Pi)',
      'description': r'''Costante matematica (3.14...), impulso. Simbolo maiuscolo ($\Pi$) per prodotto matematico.''',
      'formula': '',
      'formula_note': ''
    },
    {
      'letter': 'Ρ ρ (Rho)',
      'description': 'Densità, resistività elettrica.',
      'formula': r'R = \rho \frac{L}{A}',
      'formula_note': '(resistenza elettrica)'
    },
    {
      'letter': 'Σ σ (Sigma)',
      'description': r'''Tensione meccanica, conducibilità elettrica, sezione d\'urto, deviazione standard. Simbolo maiuscolo ($\Sigma$) per sommatoria matematica.''',
      'formula': '',
      'formula_note': ''
    },
    {
      'letter': 'Τ τ (Tau)',
      'description': 'Torsione, costante di tempo, periodo (a volte).',
      'formula': r'\vec{\tau} = \vec{r} \times \vec{F}',
      'formula_note': '(momento torcente)'
    },
    {
      'letter': 'Υ υ (Ypsilon)',
      'description': r'''Velocità (a volte, per distinguerla da $v$).''',
      'formula': '',
      'formula_note': ''
    },
    {
      'letter': 'Φ φ (Phi)',
      'description': r'''Flusso magnetico/elettrico, potenziale, angolo di fase. Simbolo maiuscolo ($\Phi$) per flusso totale.''',
      'formula': '',
      'formula_note': ''
    },
    {
      'letter': 'Χ χ (Chi)',
      'description': 'Suscettibilità elettrica/magnetica, frazione molare.',
      'formula': '',
      'formula_note': ''
    },
    {
      'letter': 'Ψ ψ (Psi)',
      'description': 'Funzione d\'onda (meccanica quantistica).',
      'formula': r'H\psi = E\psi',
      'formula_note': '(equazione di Schrödinger)'
    },
    {
      'letter': 'Ω ω (Omega)',
      'description': r'''Velocità angolare, frequenza angolare, resistenza (Ohm, come $\Omega$).''',
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
        title: const Text('Alfabeto Greco in Fisica'),
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