import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semedi_kitchen/utils/order_status_enum.dart';

class OrderModel {
  String? orderNumber;
  final String? customerName;
  final int? tableNumber;
  final Map<String, int> itemsWithQuantity;
  final Map<String, double> itemsWithPrices;
  final OrderStatusEnum status;
  final String? note;
  final DateTime timestamp;
  final double total;
  final String waiter;

  OrderModel({
    this.customerName,
    this.tableNumber,
    required this.itemsWithQuantity,
    required this.itemsWithPrices,
    required this.status,
    required this.total,
    required this.waiter,
    this.note,
    this.orderNumber,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      orderNumber: doc.id,
      customerName: data['customerName'],
      tableNumber: data['tableNumber'],
      itemsWithQuantity: Map<String, int>.from(data['itemsWithQuantity'] ?? {}),
      itemsWithPrices: Map<String, double>.from(data['itemsWithPrices'] ?? {}),
      status: OrderStatusEnum.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => OrderStatusEnum.ordered,
      ),
      note: data['note'],
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : null,
      total: (data['total'] as num?)?.toDouble() ?? 0,
      waiter: data['waiter'] ?? "unknown",
    );
  }
}
