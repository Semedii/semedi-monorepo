import 'package:flutter_test/flutter_test.dart';
import 'package:semedi_pos/models/discount.dart';

void main() {
  group('Discount', () {
    test('constructs with required fields', () {
      final d = Discount(name: 'Staff', percentage: 20.0);
      expect(d.name, 'Staff');
      expect(d.percentage, 20.0);
      expect(d.isActive, true);
    });

    test('constructs with isActive false', () {
      final d = Discount(name: 'Expired', percentage: 10.0, isActive: false);
      expect(d.isActive, false);
    });

    test('fromJson parses name and percentage', () {
      final json = {'name': 'Senior', 'percentage': '15.0', 'active': true};
      final d = Discount.fromJson(json);
      expect(d.name, 'Senior');
      expect(d.percentage, 15.0);
      expect(d.isActive, true);
    });

    test('fromJson defaults isActive to true when absent', () {
      final json = {'name': 'Happy Hour', 'percentage': '25.0'};
      final d = Discount.fromJson(json);
      expect(d.isActive, true);
    });

    test('percentage parsed as double from string', () {
      final d = Discount.fromJson({'name': 'X', 'percentage': '5.5'});
      expect(d.percentage, 5.5);
    });

    test('isActive is mutable', () {
      final d = Discount(name: 'Y', percentage: 10.0);
      d.isActive = false;
      expect(d.isActive, false);
    });
  });
}
