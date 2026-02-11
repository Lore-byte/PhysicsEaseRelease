// lib/widgets/latex_text.dart
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:developer' as developer;

/// Widget riutilizzabile per renderizzare testo misto con LaTeX inline.
///
/// Supporta:
/// - `$$...$$` per LaTeX display (blocco)
/// - `$...$` per LaTeX inline
/// - `**...**` per testo in grassetto
/// - Testo normale
class LatexText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? latexColor;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool forceLatex;

  const LatexText(
    this.text, {
    super.key,
    this.style,
    this.latexColor,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.forceLatex = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!_containsSpecialContent(text)) {
      if (forceLatex) {
        return Math.tex(
          text,
          textStyle: (style ?? const TextStyle()).copyWith(
            color: latexColor ?? style?.color,
          ),
          onErrorFallback: (Object e) {
            developer.log('Errore rendering LaTeX: $e', error: e);
            return Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: (style?.fontSize ?? 14) * 0.8,
              ),
            );
          },
        );
      }
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final spans = parseMixedContent(context, text, style, latexColor);
    return Text.rich(
      TextSpan(children: spans),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  static bool _containsSpecialContent(String text) {
    return text.contains('\$') || text.contains('**');
  }

  /// Parsa testo misto contenente LaTeX (`$...$`, `$$...$$`) e grassetto (`**...**`).
  ///
  /// Restituisce una lista di [InlineSpan] da usare in [Text.rich] o [RichText].
  static List<InlineSpan> parseMixedContent(
    BuildContext context,
    String text,
    TextStyle? textStyle,
    Color? latexColor,
  ) {
    final List<InlineSpan> spans = [];
    final RegExp contentRegex = RegExp(
      r'\$\$([^$]+?)\$\$|\$([^$]+?)\$|\*\*([^\*]+?)\*\*',
    );

    text.splitMapJoin(
      contentRegex,
      onMatch: (Match match) {
        final latexContent = match.group(1) ?? match.group(2);
        if (latexContent != null) {
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Math.tex(
                latexContent,
                textStyle: (textStyle ?? const TextStyle()).copyWith(
                  color: latexColor ?? textStyle?.color,
                ),
                onErrorFallback: (Object e) {
                  developer.log('Errore rendering LaTeX: $e', error: e);
                  return Text(
                    latexContent,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: (textStyle?.fontSize ?? 14) * 0.8,
                    ),
                  );
                },
              ),
            ),
          );
          return '';
        }

        final boldContent = match.group(3);
        if (boldContent != null) {
          spans.add(
            TextSpan(
              text: boldContent,
              style: textStyle?.copyWith(fontWeight: FontWeight.bold),
            ),
          );
          return '';
        }

        return '';
      },
      onNonMatch: (String nonMatch) {
        spans.add(TextSpan(text: nonMatch, style: textStyle));
        return '';
      },
    );
    return spans;
  }
}
