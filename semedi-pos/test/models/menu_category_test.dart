import 'package:flutter_test/flutter_test.dart';
import 'package:semedi_pos/models/menu_category.dart';

void main() {
  group('MenuCategory', () {
    test('constructs with required name', () {
      final cat = MenuCategory(name: 'Starters');
      expect(cat.name, 'Starters');
      expect(cat.iconName, isNull);
      expect(cat.sortOrder, 0);
    });

    test('constructs with all fields', () {
      final cat =
          MenuCategory(name: 'Drinks', iconName: 'local_bar', sortOrder: 2);
      expect(cat.name, 'Drinks');
      expect(cat.iconName, 'local_bar');
      expect(cat.sortOrder, 2);
    });

    test('fromJson parses name', () {
      final cat = MenuCategory.fromJson({'name': 'Mains', 'sort_order': 1});
      expect(cat.name, 'Mains');
      expect(cat.sortOrder, 1);
    });

    test('fromJson handles missing iconName', () {
      final cat = MenuCategory.fromJson({'name': 'Salads', 'sort_order': 3});
      expect(cat.iconName, isNull);
    });

    test('fromJson reads iconName', () {
      final cat = MenuCategory.fromJson(
          {'name': 'Desserts', 'icon_name': 'cake', 'sort_order': 4});
      expect(cat.iconName, 'cake');
    });

    test('toJson includes name and sortOrder', () {
      final cat = MenuCategory(name: 'Soups', sortOrder: 1);
      final json = cat.toJson();
      expect(json['name'], 'Soups');
      expect(json['sort_order'], 1);
    });

    test('sortOrder is mutable', () {
      final cat = MenuCategory(name: 'Sides', sortOrder: 5);
      cat.sortOrder = 10;
      expect(cat.sortOrder, 10);
    });
  });
}
