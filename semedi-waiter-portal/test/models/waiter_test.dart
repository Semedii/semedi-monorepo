import 'package:flutter_test/flutter_test.dart';
import 'package:semedi_waiter_portal/models/waiter.dart';

void main() {
  group('Waiter', () {
    test('constructs with required fields', () {
      final waiter = Waiter(
        name: 'Ali Hassan',
        email: 'ali@restaurant.com',
        restaurant: 'Semedi',
      );
      expect(waiter.name, equals('Ali Hassan'));
      expect(waiter.email, equals('ali@restaurant.com'));
      expect(waiter.restaurant, equals('Semedi'));
    });

    test('toFirestore returns correct keys', () {
      final waiter = Waiter(
        name: 'Sara',
        email: 'sara@res.com',
        restaurant: 'Semedi',
      );
      final map = waiter.toFirestore();
      expect(map.containsKey('name'), isTrue);
      expect(map.containsKey('email'), isTrue);
      expect(map.containsKey('restaurant'), isTrue);
    });

    test('toFirestore name value matches', () {
      final waiter = Waiter(
          name: 'Omar', email: 'omar@res.com', restaurant: 'Semedi');
      expect(waiter.toFirestore()['name'], equals('Omar'));
    });

    test('toFirestore email value matches', () {
      final waiter = Waiter(
          name: 'Fatima', email: 'fatima@res.com', restaurant: 'Semedi');
      expect(waiter.toFirestore()['email'], equals('fatima@res.com'));
    });

    test('waiter name is a string', () {
      final waiter = Waiter(
          name: 'Hassan', email: 'h@r.com', restaurant: 'Semedi');
      expect(waiter.name, isA<String>());
    });
  });
}
