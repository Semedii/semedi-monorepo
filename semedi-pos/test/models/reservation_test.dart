import 'package:flutter_test/flutter_test.dart';
import 'package:semedi_pos/models/reservation.dart';

void main() {
  group('Reservation', () {
    final sampleDate = DateTime(2025, 6, 15, 19, 30);

    test('constructs with required fields', () {
      final r = Reservation(
        id: 'abc',
        guestName: 'Alice',
        phone: '0612345678',
        guestCount: 4,
        tableNumber: 5,
        reservedAt: sampleDate,
      );
      expect(r.id, 'abc');
      expect(r.guestName, 'Alice');
      expect(r.phone, '0612345678');
      expect(r.guestCount, 4);
      expect(r.tableNumber, 5);
      expect(r.status, 'upcoming');
      expect(r.note, isNull);
    });

    test('constructs with optional note and status', () {
      final r = Reservation(
        id: 'xyz',
        guestName: 'Bob',
        phone: '0698765432',
        guestCount: 2,
        tableNumber: 3,
        reservedAt: sampleDate,
        note: 'Window seat please',
        status: 'confirmed',
      );
      expect(r.note, 'Window seat please');
      expect(r.status, 'confirmed');
    });

    test('fromJson parses all required fields', () {
      final json = {
        'id': '1',
        'guest_name': 'Charlie',
        'phone': '0611111111',
        'guest_count': 6,
        'table_number': 8,
        'reserved_at': '2025-12-25T20:00:00.000',
        'note': null,
        'status': 'upcoming',
      };
      final r = Reservation.fromJson(json);
      expect(r.id, '1');
      expect(r.guestName, 'Charlie');
      expect(r.guestCount, 6);
      expect(r.tableNumber, 8);
      expect(r.reservedAt.year, 2025);
      expect(r.reservedAt.month, 12);
    });

    test('fromJson defaults status to upcoming when absent', () {
      final json = {
        'id': '2',
        'guest_name': 'Dan',
        'phone': '0622222222',
        'guest_count': 1,
        'table_number': 1,
        'reserved_at': '2025-01-01T12:00:00.000',
      };
      final r = Reservation.fromJson(json);
      expect(r.status, 'upcoming');
    });

    test('toJson includes guest_name and phone', () {
      final r = Reservation(
        id: '3',
        guestName: 'Eve',
        phone: '0633333333',
        guestCount: 3,
        tableNumber: 2,
        reservedAt: sampleDate,
      );
      final json = r.toJson();
      expect(json['guest_name'], 'Eve');
      expect(json['phone'], '0633333333');
      expect(json['guest_count'], 3);
    });
  });
}
