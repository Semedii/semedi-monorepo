import 'package:semedi/utils/order_status_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  String? orderNumber;
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
    this.orderNumber,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'tableNumber': tableNumber,
      'items': items,
      'prices': itemDetails,
      'status': status.name,
      'note': note,
      'timestamp': Timestamp.fromDate(timestamp),
      'total': total,
      'waiter': waiter,
    };
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawDetails = data['itemDetails'] ?? {};
    final itemDetails = <String, dynamic>{};

    if (rawDetails is Map) {
      rawDetails.forEach((key, value) {
        if (value is Map) {
          itemDetails[key] = value;
        } else if (value is num) {
          itemDetails[key] = {'price': value.toDouble()};
        }
      });
    }
    return OrderModel(
      orderNumber: doc.id,
      tableNumber: data['tableNumber'],
      items: Map<String, int>.from(data['items'] ?? {}),
      itemDetails: itemDetails,
      status: OrderStatusEnum.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => OrderStatusEnum.ordered,
      ),
      note: data['note'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      total: (data['total'] as num?)?.toDouble() ?? 0,
      waiter: data['waiter'] ?? "unknown",
    );
  }

  // Add/modify items
  OrderModel copyWithItem({
    required Map<String, int> items,
    required Map<String, dynamic> itemDetails,
    required OrderStatusEnum status,
    String? note,
    required DateTime timestamp,
    required double total,
    required String waiter,
  }) {
    return OrderModel(
      tableNumber: tableNumber,
      items: items,
      itemDetails: itemDetails,
      status: status,
      note: note ?? '',
      timestamp: timestamp,
      total: total,
      waiter: waiter,
    );
  }
}
