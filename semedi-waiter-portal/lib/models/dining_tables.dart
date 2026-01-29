final class DiningTables {
  final String id;
  final int tableNumber;
  final String? status;
  final int? capacity;
  final String? location;

  DiningTables(
      {required this.id,
      required this.tableNumber,
      this.status,
      this.capacity,
      this.location});

  factory DiningTables.fromJson(Map<String, dynamic> json) {
    return DiningTables(
      id: json['id'],
      tableNumber: json['table_number'],
      status: json['status'],
      capacity: json['capacity'],
      location: json['location'],
    );
  }
}
