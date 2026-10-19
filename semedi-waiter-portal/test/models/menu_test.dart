import 'package:flutter_test/flutter_test.dart';
import 'package:semedi_waiter_portal/models/menu.dart';

void main() {
  group('MenuItem', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'id': 'abc123',
        'name': 'Grilled Chicken',
        'price': 8.5,
        'available': true,
      };
      final item = MenuItem.fromJson(json);
      expect(item.id, equals('abc123'));
      expect(item.name, equals('Grilled Chicken'));
      expect(item.price, equals(8.5));
      expect(item.isAvailable, isTrue);
    });

    test('fromJson parses price as string', () {
      final json = {
        'id': 'xyz',
        'name': 'Burger',
        'price': '12.0',
        'available': false,
      };
      final item = MenuItem.fromJson(json);
      expect(item.price, equals(12.0));
      expect(item.isAvailable, isFalse);
    });

    test('default searchKeywords is empty', () {
      final item = MenuItem(id: '1', name: 'Pizza', price: 9.99);
      expect(item.searchKeywords, isEmpty);
    });

    test('default isAvailable is true', () {
      final item = MenuItem(id: '2', name: 'Salad', price: 5.0);
      expect(item.isAvailable, isTrue);
    });

    test('name field is accessible', () {
      final item = MenuItem(id: '3', name: 'Pasta', price: 7.5);
      expect(item.name, equals('Pasta'));
    });

    test('price is a double', () {
      final item = MenuItem(id: '4', name: 'Soup', price: 3.5);
      expect(item.price, isA<double>());
    });

    test('isAvailable can be set to false', () {
      final item = MenuItem(id: '5', name: 'Steak', price: 20.0, isAvailable: false);
      expect(item.isAvailable, isFalse);
    });
  });
}
