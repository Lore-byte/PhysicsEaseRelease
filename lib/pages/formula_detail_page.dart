import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:physics_ease_release/models/formula.dart';
import 'dart:developer' as developer;

class FormulaDetailPage extends StatefulWidget {
  final Formula formula;
  final ThemeMode themeMode;
  final bool isFavorite;
  final Future<void> Function(String) onToggleFavorite;

  const FormulaDetailPage({
    super.key,
    required this.formula,
    required this.themeMode,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  State<FormulaDetailPage> createState() => _FormulaDetailPageState();
}

class _FormulaDetailPageState extends State<FormulaDetailPage> {
  late bool _isFavorite;
  final TextEditingController _chatInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;

    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }

  @override
  void didUpdateWidget(covariant FormulaDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite) {
      setState(() {
        _isFavorite = widget.isFavorite;
      });
    }
  }

  @override
  void dispose() {
    _chatInputController.dispose();
    super.dispose();
  }

  Future<void> _toggleLocalFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    await widget.onToggleFavorite(widget.formula.id);
  }

  // New function to parse mixed content (text and LaTeX)
  List<InlineSpan> _parseMixedContent(String text, TextStyle? textStyle, Color? latexColor) {
    final List<InlineSpan> spans = [];
    final RegExp latexRegex = RegExp(r'\$\$([^$]+?)\$\$|\$([^$]+?)\$'); // Matches $$...$$ and $...$

    text.splitMapJoin(
      latexRegex,
      onMatch: (Match match) {
        final latexContent = match.group(1) ?? match.group(2); // Get content from $$...$$ or $...$
        if (latexContent != null) {
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Math.tex(
                latexContent,
                textStyle: (textStyle ?? const TextStyle()).copyWith(color: latexColor),
                onErrorFallback: (Object e) {
                  developer.log('ERRORE RENDERING INLINE LATEX: $e', error: e);
                  return Text(
                    '[Errore LaTeX]',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: (textStyle?.fontSize ?? 14) * 0.8),
                  );
                },
              ),
            ),
          );
        }
        return ''; // Return empty string to indicate match was handled
      },
      onNonMatch: (String nonMatch) {
        spans.add(TextSpan(text: nonMatch, style: textStyle));
        return ''; // Return empty string to indicate non-match was handled
      },
    );
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    developer.log('FormulaDetailPage: Rendering formula "${widget.formula.titolo}". LaTeX string: "${widget.formula.formulaLatex}"');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primaryContainer,
        iconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: colorScheme.onPrimaryContainer,
            ),
            onPressed: _toggleLocalFavorite,
          ),
          IconButton(
            icon: Icon(Icons.share, color: colorScheme.onPrimaryContainer),
            onPressed: () {
              final url = 'https://physicease.app/formula/${widget.formula.id}';
              Share.share(
                'Dai un\'occhiata a questa formula su PhysicEase:\n${widget.formula.titolo}: ${widget.formula.formulaLatex}\n$url',
                subject: 'Formula di Fisica: ${widget.formula.titolo}',
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.formula.titolo,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              color: colorScheme.surfaceVariant,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: widget.formula.formulaLatex.isNotEmpty
                      ? FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Math.tex(
                      widget.formula.formulaLatex,
                      textStyle: TextStyle(
                        fontSize: 36,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onErrorFallback: (Object e) {
                        String errorMessage = 'Errore di rendering LaTeX sconosciuto.';
                        if (e is FlutterMathException) {
                          errorMessage = e.message;
                        } else {
                          errorMessage = e.toString();
                        }
                        developer.log('ERRORE RENDERING LATEX per "${widget.formula.titolo}": $errorMessage', error: e);
                        return Text(
                          'Errore LaTeX: $errorMessage',
                          style: TextStyle(color: colorScheme.error, fontSize: 14),
                        );
                      },
                    ),
                  )
                      : Text(
                    'Formula LaTeX non disponibile per "${widget.formula.titolo}". Controlla il JSON.',
                    style: TextStyle(fontStyle: FontStyle.italic, color: colorScheme.error),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Descrizione',
              content: RichText(
                text: TextSpan(
                  children: _parseMixedContent(
                    widget.formula.descrizione,
                    textTheme.bodyMedium,
                    colorScheme.onSurface, // Color for LaTeX in description
                  ),
                ),
              ),
            ),
            if (widget.formula.variabili.isNotEmpty)
              _buildSectionCard(
                title: 'Variabili',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.formula.variabili
                      .map((v) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: RichText(
                      text: TextSpan(
                        children: _parseMixedContent(
                          '${v.simbolo}: ${v.descrizione} (${v.unita})',
                          textTheme.bodyMedium,
                          colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ))
                      .toList(),
                ),
              ),
            if (widget.formula.esempi.isNotEmpty)
              ...widget.formula.esempi.map(
                    (e) => _buildSectionCard(
                  title: e.titolo,
                  content: RichText(
                    text: TextSpan(
                      children: _parseMixedContent(
                        e.testo,
                        textTheme.bodyMedium,
                        colorScheme.onSurface, // Color for LaTeX in examples
                      ),
                    ),
                  ),
                ),
              ),
            if (widget.formula.paroleChiave.isNotEmpty)
              _buildSectionCard(
                title: 'Parole chiave',
                content: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: widget.formula.paroleChiave
                      .map((kw) => Chip(
                    label: Text(kw),
                    backgroundColor: colorScheme.primaryContainer,
                    labelStyle: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ))
                      .toList(),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget content}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: colorScheme.surface,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }
}