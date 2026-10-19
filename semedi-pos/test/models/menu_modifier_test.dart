import 'package:flutter_test/flutter_test.dart';
import 'package:semedi_pos/models/menu_modifier.dart';

void main() {
  group('MenuModifier', () {
    test('constructs with required fields', () {
      final modifier = MenuModifier(name: 'Extra Cheese');
      expect(modifier.name, 'Extra Cheese');
      expect(modifier.extraCharge, 0.0);
      expect(modifier.isAvailable, true);
    });

    test('constructs with all fields', () {
      final modifier = MenuModifier(
        name: 'Spicy',
        extraCharge: 1.5,
        isAvailable: false,
      );
      expect(modifier.name, 'Spicy');
      expect(modifier.extraCharge, 1.5);
      expect(modifier.isAvailable, false);
    });

    test('fromJson parses correctly', () {
      final json = {
        'name': 'No Onion',
        'extra_charge': '0.0',
        'available': false,
      };
      final modifier = MenuModifier.fromJson(json);
      expect(modifier.name, 'No Onion');
      expect(modifier.extraCharge, 0.0);
      expect(modifier.isAvailable, false);
    });

    test('fromJson defaults isAvailable to true when absent', () {
      final json = {'name': 'Gluten Free', 'extra_charge': '2.0'};
      final modifier = MenuModifier.fromJson(json);
      expect(modifier.isAvailable, true);
    });

    test('extraCharge parsed as double from string', () {
      final modifier =
          MenuModifier.fromJson({'name': 'X', 'extra_charge': '3.75'});
      expect(modifier.extraCharge, 3.75);
    });

    test('isAvailable is mutable', () {
      final modifier = MenuModifier(name: 'Y');
      modifier.isAvailable = false;
      expect(modifier.isAvailable, false);
    });
  });
}
