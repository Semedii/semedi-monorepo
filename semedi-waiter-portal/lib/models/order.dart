import 'package:semedi/utils/order_status_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String? paymentInfo;
  final bool? isKitchenRequired;

  OrderModel({
    this.customerName,
    this.tableNumber,
    this.paymentInfo,
    required this.itemsWithQuantity,
    required this.itemsWithPrices,
    required this.status,
    required this.total,
    required this.waiter,
    this.note,
    this.orderNumber,
    this.isKitchenRequired = true,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'customerName': customerName,
      'tableNumber': tableNumber,
      'itemsWithQuantity': itemsWithQuantity,
      'itemsWithPrices': itemsWithPrices,
      'status': status.name,
      'note': note,
      'timestamp': Timestamp.fromDate(timestamp),
      'total': total,
      'waiter': waiter,
      'namePhone': paymentInfo,
      'isKitchenRequired': isKitchenRequired,
    };
  }

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
      paymentInfo: data['namePhone'],
      isKitchenRequired: data['isKitchenRequired'] ?? true,
    );
  }

  // Add/modify items
  OrderModel copyWithItem({
    required Map<String, int> itemsWithQuantity,
    required Map<String, double> itemsWithPrices,
    required OrderStatusEnum status,
    String? note,
    required DateTime timestamp,
    required double total,
    required String waiter,
    bool isKitchenRequired = true,
  }) {
    return OrderModel(
      tableNumber: tableNumber,
      customerName: customerName,
      itemsWithQuantity: itemsWithQuantity,
      itemsWithPrices: itemsWithPrices,
      status: status,
      note: note ?? '',
      timestamp: timestamp,
      total: total,
      waiter: waiter,
      paymentInfo: paymentInfo,
      isKitchenRequired: isKitchenRequired,
    );
  }
}
