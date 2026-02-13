// lib/services/notes_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'package:physics_ease_release/models/note.dart';

/// Service to manage formula notes with persistent storage
class NotesService {
  static const String _notesKey = 'formula_notes_v2';
  static const String _noteTimestampsKey = 'formula_notes_timestamps';
  static const String _legacyNotesKey = 'formula_notes';

  /// Load all notes for a specific formula from SharedPreferences
  /// Returns a List of Note objects
  static Future<List<Note>> loadNotes(String formulaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString('$_notesKey:$formulaId');
      
      if (notesJson == null || notesJson.isEmpty) {
        developer.log('No notes found for formula: $formulaId');
        return [];
      }

      final decoded = json.decode(notesJson) as List;
      final notes = decoded
          .map((item) => Note.fromJson(item as Map<String, dynamic>))
          .toList();

      developer.log('Loaded ${notes.length} notes for formula: $formulaId');
      return notes;
    } catch (e) {
      developer.log('Error loading notes for formula $formulaId: $e');
      // Try to migrate from legacy format
      return _migrateLegacyNotes(formulaId);
    }
  }

  /// Migrate notes from legacy format (single string with separator)
  static Future<List<Note>> _migrateLegacyNotes(String formulaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Try old storage format
      final allNotesJson = prefs.getString(_legacyNotesKey);
      if (allNotesJson == null) return [];
      
      final Map<String, dynamic> decoded = json.decode(allNotesJson);
      final legacyNoteText = decoded[formulaId];
      
      if (legacyNoteText == null) return [];
      
      // Parse legacy format
      const separator = '|||NOTE|||';
      final noteParts = (legacyNoteText as String).split(separator);
      
      List<Note> notes = [];
      for (int i = 0; i < noteParts.length; i++) {
        final content = noteParts[i].trim();
        if (content.isNotEmpty) {
          notes.add(Note.fromLegacy(content));
        }
      }
      
      // Save in new format
      if (notes.isNotEmpty) {
        await saveNotes(formulaId, notes);
        developer.log('Migrated ${notes.length} notes to new format for formula: $formulaId');
      }
      
      return notes;
    } catch (e) {
      developer.log('Error migrating legacy notes: $e');
      return [];
    }
  }

  /// Save notes for a specific formula
  static Future<bool> saveNotes(String formulaId, List<Note> notes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final nonEmptyNotes = notes
          .where((note) => note.content.trim().isNotEmpty)
          .toList();
      
      if (nonEmptyNotes.isEmpty) {
        // Remove notes if all empty
        await prefs.remove('$_notesKey:$formulaId');
        developer.log('Removed all notes for formula: $formulaId');
      } else {
        // Serialize notes as JSON
        final jsonList = nonEmptyNotes.map((note) => note.toJson()).toList();
        await prefs.setString('$_notesKey:$formulaId', json.encode(jsonList));
        developer.log('Saved ${nonEmptyNotes.length} notes for formula: $formulaId');
      }
      
      // Update timestamp
      final timestampsJson = prefs.getString(_noteTimestampsKey) ?? '{}';
      final Map<String, dynamic> timestamps = json.decode(timestampsJson);
      if (nonEmptyNotes.isNotEmpty) {
        timestamps[formulaId] = DateTime.now().toIso8601String();
      } else {
        timestamps.remove(formulaId);
      }
      await prefs.setString(_noteTimestampsKey, json.encode(timestamps));
      
      return true;
    } catch (e) {
      developer.log('Error saving notes: $e');
      return false;
    }
  }

  /// Get timestamp for when notes were last modified
  static Future<DateTime?> getNoteTimestamp(String formulaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampsJson = prefs.getString(_noteTimestampsKey);
      
      if (timestampsJson == null) return null;
      
      final Map<String, dynamic> timestamps = json.decode(timestampsJson);
      final timestamp = timestamps[formulaId];
      
      if (timestamp == null) return null;
      
      return DateTime.parse(timestamp.toString());
    } catch (e) {
      developer.log('Error loading note timestamp: $e');
      return null;
    }
  }

  /// Delete all notes for a specific formula
  static Future<bool> deleteNotes(String formulaId) async {
    return await saveNotes(formulaId, []);
  }

  /// Get all formula IDs that have notes
  static Future<Set<String>> getFormulasWithNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampsJson = prefs.getString(_noteTimestampsKey) ?? '{}';
      final Map<String, dynamic> timestamps = json.decode(timestampsJson);
      return timestamps.keys.toSet();
    } catch (e) {
      developer.log('Error getting formulas with notes: $e');
      return {};
    }
  }
}
