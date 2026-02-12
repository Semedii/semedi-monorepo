import 'dining_tables.dart';

class AreaZone {
  final String name;
  final List<DiningTables> tables;

  AreaZone({required this.name, required this.tables});

  static List<AreaZone> parseZones(Map<String, dynamic> jsonData) {
    final List<AreaZone> zones = [];

    jsonData.forEach((zoneName, tablesJson) {
      if (tablesJson is List) {
        final List<DiningTables> tables = tablesJson
            .map((tableJson) =>
                DiningTables.fromJson(tableJson as Map<String, dynamic>))
            .toList();

        zones.add(AreaZone(name: zoneName, tables: tables));
      }
    });

    return zones;
  }
}
