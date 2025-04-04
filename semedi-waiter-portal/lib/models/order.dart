import 'package:semedi/utils/order_status_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final int tableNumber;
  final Map<String, int> items;
  final Map<String, dynamic> itemDetails;
  final OrderStatusEnum status;
  final String? note;
  final DateTime timestamp;
  final double total;
  final String waiter;

  OrderModel({
    required this.tableNumber,
    required this.items,
    required this.itemDetails,
    required this.status,
    required this.total,
    required this.waiter,
    this.note,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'tableNumber': tableNumber,
      'items': items, // {"Chicken Shawarma": 2}
      'prices': _getPriceSnapshot(), // {"Chicken Shawarma": 8.99}
      'status': status.name,
      'note': note,
      'timestamp': Timestamp.fromDate(timestamp),
      'total': total,
      'waiter': waiter,
    };
  }

  Map<String, double> _getPriceSnapshot() {
    return {for (var e in itemDetails.entries) e.key: e.value['price']};
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      tableNumber: data['tableNumber'],
      items: Map<String, int>.from(data['items']),
      itemDetails: Map<String, dynamic>.from(data['itemDetails']),
      status: OrderStatusEnum.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => OrderStatusEnum.ordered,
      ),
      note: data['note'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      total: data['total'],
      waiter: data['waiter'],
    );
  }

  // Add/modify items
  OrderModel copyWithItem({
    required String itemName,
    required int quantity,
    required double price,
    required String menuItemId,
  }) {
    final newItems = Map<String, int>.from(items);
    final newDetails = Map<String, dynamic>.from(itemDetails);

    newItems[itemName] = quantity;
    newDetails[itemName] = {
      'price': price,
      'menuItemId': menuItemId,
    };

    return OrderModel(
        tableNumber: tableNumber,
        items: newItems,
        itemDetails: newDetails,
        status: status,
        note: note,
        timestamp: timestamp,
        total: total,
        waiter: waiter);
  }
}
