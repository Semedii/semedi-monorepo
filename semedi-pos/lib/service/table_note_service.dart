import 'package:semedi_pos/models/table_note.dart';

class TableNoteService {
  final Map<int, String> _notes = {};

  List<TableNote> getAllNotes() {
    return _notes.entries
        .map((e) => TableNote(tableNumber: e.key, note: e.value))
        .toList();
  }

  String? getNoteForTable(int tableNumber) {
    return _notes[tableNumber];
  }

  void saveNote(int tableNumber, String note) {
    if (note.trim().isEmpty) {
      _notes.remove(tableNumber);
    } else {
      _notes[tableNumber] = note.trim();
    }
  }

  void deleteNote(int tableNumber) {
    _notes.remove(tableNumber);
  }

  Map<int, String> get notesMap => Map.unmodifiable(_notes);
}
