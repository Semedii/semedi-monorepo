import 'package:semedi_pos/models/order_item.dart';

class OrderModel {
  final String id;
  final int tableNumber;
  final String waiterName;
  final String status;
  final List<OrderItem> items;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.tableNumber,
    required this.waiterName,
    required this.status,
    required this.items,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      tableNumber: json['dining_tables']['table_number'],
      waiterName: json['profiles']['full_name'] as String,
      status: json['status'] as String,
      items: [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'waiter_name': waiterName,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
