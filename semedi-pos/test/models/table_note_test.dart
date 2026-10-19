import 'package:flutter_test/flutter_test.dart';
import 'package:semedi_pos/models/table_note.dart';

void main() {
  group('TableNote', () {
    test('constructs correctly', () {
      const note = TableNote(tableNumber: 3, note: 'VIP guest');
      expect(note.tableNumber, 3);
      expect(note.note, 'VIP guest');
    });

    test('fromJson parses table_number and note', () {
      final json = {'table_number': 7, 'note': 'Allergy: nuts'};
      final note = TableNote.fromJson(json);
      expect(note.tableNumber, 7);
      expect(note.note, 'Allergy: nuts');
    });

    test('toJson returns correct map', () {
      const note = TableNote(tableNumber: 2, note: 'Birthday celebration');
      final json = note.toJson();
      expect(json['table_number'], 2);
      expect(json['note'], 'Birthday celebration');
    });

    test('fromJson round-trip is consistent', () {
      const original = TableNote(tableNumber: 5, note: 'Extra napkins');
      final restored = TableNote.fromJson(original.toJson());
      expect(restored.tableNumber, original.tableNumber);
      expect(restored.note, original.note);
    });
  });
}
