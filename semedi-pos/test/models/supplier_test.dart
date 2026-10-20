import 'package:flutter_test/flutter_test.dart';
import 'package:semedi_pos/models/supplier.dart';

void main() {
  group('Supplier', () {
    test('constructs with required fields', () {
      final s = Supplier(
        id: '1',
        name: 'Fresh Farms',
        phone: '0612345678',
      );
      expect(s.id, '1');
      expect(s.name, 'Fresh Farms');
      expect(s.phone, '0612345678');
      expect(s.email, isNull);
      expect(s.note, isNull);
    });

    test('constructs with optional fields', () {
      final s = Supplier(
        id: '2',
        name: 'City Meats',
        phone: '0698765432',
        email: 'contact@citymeats.com',
        note: 'Delivers on Tuesdays',
      );
      expect(s.email, 'contact@citymeats.com');
      expect(s.note, 'Delivers on Tuesdays');
    });

    test('fromJson parses all required fields', () {
      final json = {
        'id': '10',
        'name': 'Veggie World',
        'phone': '0611111111',
        'email': null,
        'note': null,
      };
      final s = Supplier.fromJson(json);
      expect(s.id, '10');
      expect(s.name, 'Veggie World');
      expect(s.phone, '0611111111');
      expect(s.email, isNull);
      expect(s.note, isNull);
    });

    test('fromJson parses optional fields when present', () {
      final json = {
        'id': '11',
        'name': 'Ocean Catch',
        'phone': '0622222222',
        'email': 'fish@ocean.com',
        'note': 'Minimum order 10kg',
      };
      final s = Supplier.fromJson(json);
      expect(s.email, 'fish@ocean.com');
      expect(s.note, 'Minimum order 10kg');
    });

    test('fromJson casts id to string', () {
      final json = {
        'id': 42,
        'name': 'Spice House',
        'phone': '0633333333',
        'email': null,
        'note': null,
      };
      final s = Supplier.fromJson(json);
      expect(s.id, '42');
    });

    test('toJson includes name and phone', () {
      final s = Supplier(
        id: '3',
        name: 'Grain Co',
        phone: '0644444444',
        note: 'Wholesale only',
      );
      final json = s.toJson();
      expect(json['name'], 'Grain Co');
      expect(json['phone'], '0644444444');
      expect(json['note'], 'Wholesale only');
      expect(json['email'], isNull);
    });

    test('toJson does not include id field', () {
      final s = Supplier(
        id: '99',
        name: 'Test',
        phone: '0600000000',
      );
      final json = s.toJson();
      expect(json.containsKey('id'), isFalse);
    });
  });
}
