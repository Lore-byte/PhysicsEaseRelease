// lib/pages/formula_detail_page.dart

import 'package:flutter/material.dart';
import 'package:physics_ease_release/theme/app_colors.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:share_plus/share_plus.dart';
//import 'package:url_launcher/url_launcher.dart';
import 'package:physics_ease_release/models/formula.dart';
import 'package:screenshot/screenshot.dart';
//import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:physics_ease_release/widgets/floating_top_bar.dart';
import 'package:physics_ease_release/widgets/latex_text.dart';
import 'package:physics_ease_release/models/note.dart';

class FormulaDetailPage extends StatefulWidget {
  final Formula formula;
  final ThemeMode themeMode;
  final void Function(bool) setGlobalAppBarVisibility;
  final bool isFavorite;
  final Future<void> Function(String) onToggleFavorite;
  final List<Note> initialNotes;
  final Future<void> Function(String, List<Note>)? onSaveNotes;

  const FormulaDetailPage({
    super.key,
    required this.formula,
    required this.themeMode,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.setGlobalAppBarVisibility,
    this.initialNotes = const [],
    this.onSaveNotes,
  });

  @override
  State<FormulaDetailPage> createState() => _FormulaDetailPageState();
}

class _FormulaDetailPageState extends State<FormulaDetailPage> {
  late bool _isFavorite;
  final TextEditingController _chatInputController = TextEditingController();
  final List<TextEditingController> _noteTitleControllers = [];
  final List<TextEditingController> _noteContentControllers = [];
  final List<FocusNode> _noteTitleFocusNodes = [];
  final List<FocusNode> _noteContentFocusNodes = [];
  final List<bool> _noteEditingStates = [];
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _initializeNotes();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.setGlobalAppBarVisibility(false);
    });
  }

  void _initializeNotes() {
    final initialNotes = widget.initialNotes;
    for (final note in initialNotes) {
      _addNoteController(note);
    }
  }

  void _addNoteController(Note note) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);
    final titleFocusNode = FocusNode();
    final contentFocusNode = FocusNode();
    
    titleController.addListener(_onNoteChanged);
    contentController.addListener(_onNoteChanged);
    
    _noteTitleControllers.add(titleController);
    _noteContentControllers.add(contentController);
    _noteTitleFocusNodes.add(titleFocusNode);
    _noteContentFocusNodes.add(contentFocusNode);
    _noteEditingStates.add(note.content.isEmpty && note.title.isEmpty);
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
    for (var controller in _noteTitleControllers) {
      controller.removeListener(_onNoteChanged);
      controller.dispose();
    }
    for (var controller in _noteContentControllers) {
      controller.removeListener(_onNoteChanged);
      controller.dispose();
    }
    for (var focusNode in _noteTitleFocusNodes) {
      focusNode.dispose();
    }
    for (var focusNode in _noteContentFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onNoteChanged() {
    final currentNotes = _getAllNotes();
    final hasChanged = currentNotes != widget.initialNotes;
    if (hasChanged != _hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanged;
      });
    }
  }

  List<Note> _getAllNotes() {
    final notes = <Note>[];
    for (int i = 0; i < _noteTitleControllers.length; i++) {
      final title = _noteTitleControllers[i].text.trim();
      final content = _noteContentControllers[i].text.trim();
      
      if (content.isNotEmpty) {
        notes.add(Note(title: title, content: content));
      }
    }
    return notes;
  }

  void _addNewNote() {
    setState(() {
      _addNoteController(Note(title: '', content: ''));
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_noteContentFocusNodes.isNotEmpty) {
        _noteContentFocusNodes.last.requestFocus();
      }
    });
  }

  void _removeNoteAt(int index) {
    setState(() {
      _noteTitleControllers[index].dispose();
      _noteContentControllers[index].dispose();
      _noteTitleFocusNodes[index].dispose();
      _noteContentFocusNodes[index].dispose();
      _noteTitleControllers.removeAt(index);
      _noteContentControllers.removeAt(index);
      _noteTitleFocusNodes.removeAt(index);
      _noteContentFocusNodes.removeAt(index);
      _noteEditingStates.removeAt(index);
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _saveNote() async {
    if (widget.onSaveNotes != null) {
      final notes = _getAllNotes();
      await widget.onSaveNotes!(widget.formula.id, notes);
      setState(() {
        _hasUnsavedChanges = false;
        for (int i = 0; i < _noteEditingStates.length; i++) {
          _noteEditingStates[i] = false;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note salvate con successo'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
    for (var focusNode in _noteTitleFocusNodes) {
      focusNode.unfocus();
    }
    for (var focusNode in _noteContentFocusNodes) {
      focusNode.unfocus();
    }
  }

  void _editNoteAt(int index) {
    setState(() {
      _noteEditingStates[index] = true;
      _hasUnsavedChanges = true;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _noteContentFocusNodes[index].requestFocus();
    });
  }

  void _cancelNoteEdit() {
    setState(() {
      for (var controller in _noteTitleControllers) {
        controller.removeListener(_onNoteChanged);
        controller.dispose();
      }
      for (var controller in _noteContentControllers) {
        controller.removeListener(_onNoteChanged);
        controller.dispose();
      }
      for (var focusNode in _noteTitleFocusNodes) {
        focusNode.dispose();
      }
      for (var focusNode in _noteContentFocusNodes) {
        focusNode.dispose();
      }
      _noteTitleControllers.clear();
      _noteContentControllers.clear();
      _noteTitleFocusNodes.clear();
      _noteContentFocusNodes.clear();
      _noteEditingStates.clear();
      _initializeNotes();
      _hasUnsavedChanges = false;
    });
  }

  Future<void> _toggleLocalFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    await widget.onToggleFavorite(widget.formula.id);
  }

  Future<void> shareFormula() async {
    // 1) Crea il widget da catturare con tema e sfondo
    final widgetToCapture = InheritedTheme.captureAll(
      context,
      Material(
        color: AppColors.transparent,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              // sfondo pieno per evitare trasparenze
              color: Theme.of(context).colorScheme.surface,
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
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // 2) Cattura
    final imageBytes = await _screenshotController.captureFromWidget(
      widgetToCapture,
      pixelRatio: 4.0,
    );

    if (imageBytes.isEmpty) {
      // fallback o messaggio errore
      return;
    }

    // 3) Salva PNG temporaneo
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/formula_${widget.formula.id}.png');
    await file.writeAsBytes(imageBytes, flush: true);

    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    final origin = Rect.fromLTWH(0, 0, size.width, size.height / 2);

    final String link = 'https://sites.google.com/view/physicsease-app';

    await Share.shareXFiles(
      [
        XFile(file.path, mimeType: 'image/png'),
      ], // mimeType utile con alcune app
      text:
          'Dai un\'occhiata a questa formula su PhysicsEase e scarica l\'app per scoprirne altre!\n$link',
      subject: 'Formula di Fisica: ${widget.formula.titolo}',
      sharePositionOrigin: origin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    developer.log(
      'FormulaDetailPage: Rendering formula "${widget.formula.titolo}". LaTeX string: "${widget.formula.formulaLatex}"',
    );

    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewPadding.bottom + 98,
              left: 16.0,
              right: 16.0,
              top: MediaQuery.of(context).viewPadding.top + 70,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.formula.titolo,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  color: colorScheme.surfaceContainerHighest,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: widget.formula.formulaLatex.isNotEmpty
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Math.tex(
                                widget.formula.formulaLatex,
                                mathStyle:
                                    MathStyle.display, // usa stile centrato
                                textStyle: TextStyle(
                                  fontSize: 36,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                onErrorFallback: (Object e) {
                                  String errorMessage =
                                      'Errore di rendering LaTeX sconosciuto.';
                                  if (e is FlutterMathException) {
                                    errorMessage = e.message;
                                  } else {
                                    errorMessage = e.toString();
                                  }
                                  developer.log(
                                    'ERRORE RENDERING LATEX per "${widget.formula.titolo}": $errorMessage',
                                    error: e,
                                  );
                                  return Text(
                                    'Errore LaTeX: $errorMessage',
                                    style: TextStyle(
                                      color: colorScheme.error,
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Text(
                              'Formula LaTeX non disponibile per "${widget.formula.titolo}". Controlla il JSON.',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: colorScheme.error,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Descrizione',
                  content: RichText(
                    text: TextSpan(
                      children: LatexText.parseMixedContent(
                        context,
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
                                    textStyle: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                    onErrorFallback: (e) => Text(
                                      '[Errore LaTeX simbolo]',
                                      style: TextStyle(
                                        color: colorScheme.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: ': ',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                ...LatexText.parseMixedContent(
                                  context,
                                  v.descrizione,
                                  textTheme.bodyMedium,
                                  colorScheme.onSurface,
                                ),
                                TextSpan(
                                  text: ' (',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Math.tex(
                                    v.unita,
                                    textStyle: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                    onErrorFallback: (e) => Text(
                                      '[Errore LaTeX unità]',
                                      style: TextStyle(
                                        color: colorScheme.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: ')',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
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
                          children: LatexText.parseMixedContent(
                            context,
                            e.testo,
                            textTheme.bodyMedium,
                            colorScheme
                                .onSurface, // Color for LaTeX in examples
                          ),
                        ),
                      ),
                    ),
                  ),
                _buildNotesSection(colorScheme, textTheme),
                if (widget.formula.paroleChiave.isNotEmpty)
                  _buildSectionCard(
                    title: 'Parole chiave',
                    content: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: widget.formula.paroleChiave
                          .map(
                            (kw) => Chip(
                              label: Text(kw),
                              backgroundColor: colorScheme.primaryContainer,
                              labelStyle: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          )
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
              onSharePressed: shareFormula,
            ),
          ),
        ],
      ),
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
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(ColorScheme colorScheme, TextTheme textTheme) {
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
            Row(
              children: [
                Text(
                  'Note',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_hasUnsavedChanges) ...[
                  TextButton.icon(
                    onPressed: _cancelNoteEdit,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Annulla'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.error,
                    ),
                  ),
                  const SizedBox(width: 4),
                  FilledButton.icon(
                    onPressed: _saveNote,
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Salva'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                IconButton(
                  onPressed: _addNewNote,
                  icon: const Icon(Icons.add_circle_outline, size: 22),
                  tooltip: 'Aggiungi nota',
                  color: colorScheme.primary,
                ),
              ],
            ),
            if (_noteTitleControllers.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...List.generate(_noteTitleControllers.length, (index) {
                final isEditing = _noteEditingStates[index];
                final hasContent = _noteContentControllers[index].text.trim().isNotEmpty;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: isEditing
                      ? _buildEditingNote(index, colorScheme, textTheme)
                      : hasContent
                          ? _buildViewNote(index, colorScheme, textTheme)
                          : _buildEditingNote(index, colorScheme, textTheme),
                );
              }),
            ],
            if (_hasUnsavedChanges)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Hai modifiche non salvate',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditingNote(int index, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteTitleControllers[index],
                  focusNode: _noteTitleFocusNodes[index],
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Titolo della nota (opzionale)',
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _removeNoteAt(index),
                icon: const Icon(Icons.delete_outline, size: 20),
                tooltip: 'Elimina nota',
                color: colorScheme.error,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          TextField(
            controller: _noteContentControllers[index],
            focusNode: _noteContentFocusNodes[index],
            maxLines: null,
            minLines: 3,
            decoration: InputDecoration(
              hintText: 'Scrivi qui la tua nota...',
              hintStyle: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildViewNote(int index, ColorScheme colorScheme, TextTheme textTheme) {
    final title = _noteTitleControllers[index].text.trim();
    final content = _noteContentControllers[index].text.trim();
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title.isNotEmpty) ...[
                      Text(
                        title,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      content,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _editNoteAt(index),
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: 'Modifica nota',
                color: colorScheme.primary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
