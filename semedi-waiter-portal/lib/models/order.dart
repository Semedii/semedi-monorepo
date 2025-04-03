import 'package:semedi/utils/order_status_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final int tableNumber;
  final Map<String, int> items; // ItemName : Quantity
  final Map<String, dynamic> itemDetails; // Supplemental data
  final OrderStatusEnum status;
  final String? note;
  final DateTime timestamp;

  Order({
    required this.tableNumber,
    required this.items,
    required this.itemDetails,
    required this.status,
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
    };
  }

  Map<String, double> _getPriceSnapshot() {
    return {for (var e in itemDetails.entries) e.key: e.value['price']};
  }

  // Create from Firestore snapshot
  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      tableNumber: data['tableNumber'],
      items: Map<String, int>.from(data['items']),
      itemDetails: Map<String, dynamic>.from(data['itemDetails']),
      status: OrderStatusEnum.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => OrderStatusEnum.ordered,
      ),
      note: data['note'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Helper method to calculate total
  double get total {
    return items.entries.fold(0, (sum, entry) {
      final price = itemDetails[entry.key]['price'] ?? 0;
      return sum + (price * entry.value);
    });
  }

  // Add/modify items
  Order copyWithItem({
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

    return Order(
      tableNumber: tableNumber,
      items: newItems,
      itemDetails: newDetails,
      status: status,
      note: note,
      timestamp: timestamp,
    );
  }
}
