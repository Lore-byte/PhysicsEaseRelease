// lib/pages/add_formula_page.dart
import 'package:flutter/material.dart';
import 'package:physics_ease_release/models/formula.dart';

class AddFormulaPage extends StatefulWidget {
  final Future<void> Function(Formula) onAddFormula;

  const AddFormulaPage({
    super.key,
    required this.onAddFormula,
  });

  @override
  State<AddFormulaPage> createState() => _AddFormulaPageState();
}

class _AddFormulaPageState extends State<AddFormulaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _formulaLatexController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();

  final List<TextEditingController> _variableSymbolControllers = [];
  final List<TextEditingController> _variableDescControllers = [];
  final List<TextEditingController> _variableUnitControllers = [];

  final List<TextEditingController> _exampleTitleControllers = [];
  final List<TextEditingController> _exampleTextControllers = [];

  @override
  void initState() {
    super.initState();
    _addVariableField();
    _addExampleField();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _formulaLatexController.dispose();
    _keywordsController.dispose();
    for (var controller in _variableSymbolControllers) controller.dispose();
    for (var controller in _variableDescControllers) controller.dispose();
    for (var controller in _variableUnitControllers) controller.dispose();
    for (var controller in _exampleTitleControllers) controller.dispose();
    for (var controller in _exampleTextControllers) controller.dispose();
    super.dispose();
  }

  void _addVariableField() {
    setState(() {
      _variableSymbolControllers.add(TextEditingController());
      _variableDescControllers.add(TextEditingController());
      _variableUnitControllers.add(TextEditingController());
    });
  }

  void _removeVariableField(int index) {
    setState(() {
      _variableSymbolControllers[index].dispose();
      _variableDescControllers[index].dispose();
      _variableUnitControllers[index].dispose();
      _variableSymbolControllers.removeAt(index);
      _variableDescControllers.removeAt(index);
      _variableUnitControllers.removeAt(index);
    });
  }

  void _addExampleField() {
    setState(() {
      _exampleTitleControllers.add(TextEditingController());
      _exampleTextControllers.add(TextEditingController());
    });
  }

  void _removeExampleField(int index) {
    setState(() {
      _exampleTitleControllers[index].dispose();
      _exampleTextControllers[index].dispose();
      _exampleTitleControllers.removeAt(index);
      _exampleTextControllers.removeAt(index);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final String id = DateTime.now().millisecondsSinceEpoch.toString();
      final String title = _titleController.text.trim();
      final String description = _descriptionController.text.trim();
      final String formulaLatex = _formulaLatexController.text.trim();
      final List<String> keywords = _keywordsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

      final List<Variable> variables = [];
      for (int i = 0; i < _variableSymbolControllers.length; i++) {
        if (_variableSymbolControllers[i].text.isNotEmpty &&
            _variableDescControllers[i].text.isNotEmpty &&
            _variableUnitControllers[i].text.isNotEmpty) {
          variables.add(Variable(
            simbolo: _variableSymbolControllers[i].text.trim(),
            descrizione: _variableDescControllers[i].text.trim(),
            unita: _variableUnitControllers[i].text.trim(),
          ));
        }
      }

      final List<Example> examples = [];
      for (int i = 0; i < _exampleTitleControllers.length; i++) {
        if (_exampleTitleControllers[i].text.isNotEmpty &&
            _exampleTextControllers[i].text.isNotEmpty) {
          examples.add(Example(
            titolo: _exampleTitleControllers[i].text.trim(),
            testo: _exampleTextControllers[i].text.trim(),
          ));
        }
      }

      final newFormula = Formula(
        id: id,
        titolo: title,
        descrizione: description,
        formulaLatex: formulaLatex,
        categoria: 'Personalizzate',
        variabili: variables,
        esempi: examples,
        paroleChiave: keywords,
      );


      widget.onAddFormula(newFormula).then((_) {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggiungi Nuova Formula'),
        backgroundColor: colorScheme.primaryContainer,
        iconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Titolo Formula',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci il titolo della formula';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descrizione',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci una descrizione';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _formulaLatexController,
                decoration: InputDecoration(
                  labelText: 'Formula in LaTeX (es. E=mc^2)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci la formula in formato LaTeX';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _keywordsController,
                decoration: InputDecoration(
                  labelText: 'Parole Chiave (separate da virgola)',
                  hintText: 'es. energia, massa, relatività',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              Text('Variabili:', style: Theme.of(context).textTheme.titleMedium),
              ...List.generate(_variableSymbolControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _variableSymbolControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Simbolo',
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: TextFormField(
                          controller: _variableDescControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Descrizione Variabile',
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _variableUnitControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Unità (es. m/s)',
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: colorScheme.error),
                        onPressed: () => _removeVariableField(index),
                      ),
                    ],
                  ),
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addVariableField,
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Aggiungi Variabile'),
                ),
              ),
              const SizedBox(height: 24),
              Text('Esempi:', style: Theme.of(context).textTheme.titleMedium),
              ...List.generate(_exampleTitleControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _exampleTitleControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Titolo Esempio',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _exampleTextControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Testo Esempio',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              maxLines: 3,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_circle, color: colorScheme.error),
                            onPressed: () => _removeExampleField(index),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addExampleField,
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Aggiungi Esempio'),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.save),
                label: const Text('Salva Formula'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}