// lib/pages/formula_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:physics_ease_release/models/formula.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:physics_ease_release/widgets/floating_top_bar.dart';


class FormulaDetailPage extends StatefulWidget {
  final Formula formula;
  final ThemeMode themeMode;
  final void Function(bool) setGlobalAppBarVisibility;
  final bool isFavorite;
  final Future<void> Function(String) onToggleFavorite;

  const FormulaDetailPage({
    super.key,
    required this.formula,
    required this.themeMode,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.setGlobalAppBarVisibility,
  });

  @override
  State<FormulaDetailPage> createState() => _FormulaDetailPageState();
}

class _FormulaDetailPageState extends State<FormulaDetailPage> {
  late bool _isFavorite;
  final TextEditingController _chatInputController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.setGlobalAppBarVisibility(false);
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

  Future<void> _shareFormula() async {
    final Uint8List? imageBytes = await _screenshotController.captureFromWidget(
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        color: Theme.of(context).colorScheme.surfaceVariant,
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 800,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Math.tex(
                widget.formula.formulaLatex,
                textStyle: TextStyle(
                  fontSize: 60,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onErrorFallback: (Object e) {
                  developer.log('ERRORE RENDERING LATEX per screenshot: $e', error: e);
                  return Text(
                    '[Errore LaTeX]',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 20),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      pixelRatio: 4.0,
    );

    if (imageBytes != null) {
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/formula_${widget.formula.id}.png').create();
      await imagePath.writeAsBytes(imageBytes);
      final String link = 'https://sites.google.com/view/physicsease-app';
      Share.shareXFiles(
        [XFile(imagePath.path)],
        text: 'Dai un\'occhiata a questa formula su PhysicsEase e scarica l\'app per scoprirne altre!\n$link',
        subject: 'Formula di Fisica: ${widget.formula.titolo}',
      );
    } else {
      developer.log('Errore durante la cattura dello screenshot della formula.');
    }
  }


  //Nuovo parser
  List<InlineSpan> _parseMixedContent(String text, TextStyle? textStyle, Color? latexColor) {
    final List<InlineSpan> spans = [];
    // Usa la nuova RegExp che riconosce sia LaTeX sia grassetto
    final RegExp contentRegex = RegExp(r'\$\$([^$]+?)\$\$|\$([^$]+?)\$|\*\*([^\*]+?)\*\*');

    text.splitMapJoin(
      contentRegex,
      onMatch: (Match match) {
        // Prova a trovare una corrispondenza LaTeX
        final latexContent = match.group(1) ?? match.group(2);
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
          return '';
        }

        // Se non è LaTeX, prova a trovare una corrispondenza per il grassetto
        final boldContent = match.group(3);
        if (boldContent != null) {
          spans.add(
            TextSpan(
              text: boldContent,
              // Applica lo stile grassetto
              style: textStyle?.copyWith(fontWeight: FontWeight.bold),
            ),
          );
          return '';
        }

        // Fallback (non dovrebbe accadere con questa regex)
        return '';
      },
      onNonMatch: (String nonMatch) {
        // Il testo normale viene aggiunto come sempre
        spans.add(TextSpan(text: nonMatch, style: textStyle));
        return '';
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
      appBar: null,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + 98, left: 16.0, right: 16.0, top: MediaQuery.of(context).viewPadding.top + 70),
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
                          mathStyle: MathStyle.display, // usa stile centrato
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


                //Variabili NEW con render LaTeX per 'simbolo' e 'unita' senza parser
                if (widget.formula.variabili.isNotEmpty)
                  _buildSectionCard(
                    title: 'Variabili',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.formula.variabili.map((v) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Math.tex(
                                    v.simbolo,
                                    textStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                                    onErrorFallback: (e) => Text(
                                      '[Errore LaTeX simbolo]',
                                      style: TextStyle(color: colorScheme.error, fontSize: 12),
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: ': ',
                                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                                ),
                                ..._parseMixedContent(
                                  v.descrizione,
                                  textTheme.bodyMedium,
                                  colorScheme.onSurface,
                                ),
                                TextSpan(
                                  text: ' (',
                                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Math.tex(
                                    v.unita,
                                    textStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                                    onErrorFallback: (e) => Text(
                                      '[Errore LaTeX unità]',
                                      style: TextStyle(color: colorScheme.error, fontSize: 12),
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: ')',
                                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
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
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).viewPadding.top,
            left: 16,
            right: 16,
            child: FloatingTopBar(
              title: "",
              leading: FloatingTopBarLeading.back,
              showSearch: false,
              showFavorite: true,
              isFavorite: _isFavorite,
              onFavoritePressed: _toggleLocalFavorite,
              showShare: true,
              onSharePressed: _shareFormula,
            ),
          ),
        ],
      )
    );
  }

  Widget _buildSectionCard({required String title, required Widget content}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: colorScheme.surfaceContainer,
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