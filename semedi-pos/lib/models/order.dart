import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semedi_pos/utils/order_status_enum.dart';

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
  // Map<String, dynamic> toFirestore() {
  //   return {
  //     'tableNumber': tableNumber,
  //     'items': items,
  //     'prices': itemDetails,
  //     'status': status.name,
  //     'note': note,
  //     'timestamp': Timestamp.fromDate(timestamp),
  //     'total': total,
  //     'waiter': waiter,
  //   };
  // }
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Extract prices from Firestore
    final rawPrices = data['prices'] ?? {};
    final itemDetails = <String, double>{};

    if (rawPrices is Map) {
      rawPrices.forEach((itemName, priceData) {
        if (priceData is Map) {
          itemDetails[itemName] =
              (priceData['price'] as num?)?.toDouble() ?? 0.0;
        } else if (priceData is num) {
          itemDetails[itemName] = priceData.toDouble();
        }
      });
    }

    return OrderModel(
      orderNumber: doc.id,
      tableNumber: data['tableNumber'] ?? 'Unknown table', // Added fallback
      items: Map<String, int>.from(data['items'] ?? {}),
      itemDetails: itemDetails,
      status: OrderStatusEnum.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'ordered'), // Added fallback
        orElse: () => OrderStatusEnum.ordered,
      ),
      note: data['note'] ?? '', // Added fallback
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(), // Added fallback
      total: (data['total'] as num?)?.toDouble() ?? 0,
      waiter: data['waiter'] ?? "unknown",
    );
  }

  // // Add/modify items
  // OrderModel copyWithItem({
  //   required Map<String, int> items,
  //   required Map<String, dynamic> itemDetails,
  //   required OrderStatusEnum status,
  //   String? note,
  //   required DateTime timestamp,
  //   required double total,
  //   required String waiter,
  // }) {
  //   return OrderModel(
  //     tableNumber: tableNumber,
  //     items: items,
  //     itemDetails: itemDetails,
  //     status: status,
  //     note: note ?? '',
  //     timestamp: timestamp,
  //     total: total,
  //     waiter: waiter,
  //   );
  // }
}
