import 'dart:convert';

/// Model for a formula note with a title and content
class Note {
  final String title;
  final String content;

  Note({
    required this.title,
    required this.content,
  });

  /// Convert Note to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }

  /// Create Note from JSON
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );
  }

  /// Create Note from legacy format (only content, no title)
  factory Note.fromLegacy(String content) {
    return Note(
      title: '',
      content: content,
    );
  }

  @override
  String toString() => 'Note(title: $title, content: $content)';
}

/// Helper class to serialize/deserialize a list of notes
class NotesSerializer {
  static String encode(List<Note> notes) {
    final jsonList = notes.map((note) => note.toJson()).toList();
    return json.encode(jsonList);
  }

  static List<Note> decode(String encoded) {
    try {
      if (encoded.isEmpty) {
        return [];
      }
      final decoded = json.decode(encoded) as List;
      return decoded.map((item) => Note.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback to legacy format if it's just plain text separated by separator
      return [];
    }
  }
}
