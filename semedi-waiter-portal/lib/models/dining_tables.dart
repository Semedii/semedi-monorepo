final class DiningTables {
  final String id;
  final int tableNumber;
  final String? status;
  final int? capacity;
  final String? zone;

  DiningTables(
      {required this.id,
      required this.tableNumber,
      this.status,
      this.capacity,
      this.zone});

  factory DiningTables.fromJson(Map<String, dynamic> json) {
    return DiningTables(
      id: json['id'],
      tableNumber: json['number'],
      status: json['status'],
      capacity: json['capacity'],
      zone: json['zone']['name'],
    );
  }
}
