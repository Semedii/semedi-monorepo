import 'order_item.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final int tableNumber;
  final String waiterName;
  final String status;
  final List<OrderItem> items;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.tableNumber,
    required this.waiterName,
    required this.status,
    required this.items,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final orderItems = (json['order_items'] as List<dynamic>? ?? [])
        .map((e) => OrderItem.fromJson(e))
        .toList();

    return OrderModel(
      id: (json['id'] as String),
      orderNumber: json['order_number'],
      tableNumber: json['dining_tables']['table_number'],
      waiterName: json['users']['full_name'],
      status: json['status'],
      items: orderItems,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  double get totalPrice {
    return items.fold(
        0, (sum, item) => sum + (item.itemPrice! * item.itemQuantity!));
  }
}
