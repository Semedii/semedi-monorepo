import 'package:flutter_test/flutter_test.dart';
import 'package:semedi_waiter_portal/models/dining_tables.dart';
import 'package:semedi_waiter_portal/models/area_zone.dart';

void main() {
  group('DiningTables', () {
    test('fromJson parses required fields', () {
      final json = {
        'id': 't1',
        'number': 5,
        'status': 'available',
        'capacity': 4,
        'zone': {'name': 'Main Hall'},
      };
      final table = DiningTables.fromJson(json);
      expect(table.id, equals('t1'));
      expect(table.tableNumber, equals(5));
      expect(table.status, equals('available'));
      expect(table.capacity, equals(4));
      expect(table.zone, equals('Main Hall'));
    });

    test('optional fields can be null', () {
      final table = DiningTables(id: 'x', tableNumber: 1);
      expect(table.status, isNull);
      expect(table.capacity, isNull);
      expect(table.zone, isNull);
    });

    test('tableNumber is an int', () {
      final table = DiningTables(id: 'y', tableNumber: 3);
      expect(table.tableNumber, isA<int>());
    });

    test('id is accessible', () {
      final table = DiningTables(id: 'abc', tableNumber: 2);
      expect(table.id, equals('abc'));
    });
  });

  group('AreaZone', () {
    test('constructs with name and tables', () {
      final zone = AreaZone(
        name: 'Terrace',
        tables: [DiningTables(id: 'a', tableNumber: 1)],
      );
      expect(zone.name, equals('Terrace'));
      expect(zone.tables.length, equals(1));
    });

    test('parseZones returns list from map', () {
      final data = {
        'Main': [
          {
            'id': 'm1',
            'number': 1,
            'status': 'available',
            'capacity': 4,
            'zone': {'name': 'Main'},
          },
        ],
      };
      final zones = AreaZone.parseZones(data);
      expect(zones.length, equals(1));
      expect(zones.first.name, equals('Main'));
      expect(zones.first.tables.length, equals(1));
    });

    test('empty map returns empty list', () {
      final zones = AreaZone.parseZones({});
      expect(zones, isEmpty);
    });
  });
}
