import 'package:semedi_pos/models/purchase_order_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PurchaseOrder {
  final String id;
  final String supplierId;
  final String supplierName;
  final String status;
  final DateTime createdAt;
  final List<PurchaseOrderItem> items;
  final String? note;

  PurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.status,
    required this.createdAt,
    required this.items,
    this.note,
  });

  double get totalCost =>
      items.fold(0, (sum, item) => sum + item.totalCost);

  int get receivedItemCount =>
      items.where((item) => item.isFullyReceived).length;

  bool get isFullyReceived =>
      items.isNotEmpty && receivedItemCount == items.length;

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    final orderItems = (json['purchase_order_items'] as List<dynamic>? ?? [])
        .map((e) => PurchaseOrderItem.fromJson(e))
        .toList();
    return PurchaseOrder(
      id: json['id'].toString(),
      supplierId: json['supplier_id'].toString(),
      supplierName: json['suppliers']['name'],
      status: json['status'] ?? 'draft',
      createdAt: DateTime.parse(json['created_at']),
      items: orderItems,
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_id': supplierId,
      'status': status,
      'note': note,
      'restaurant_id':
          Supabase.instance.client.auth.currentUser!.userMetadata?['restaurant_id'],
    };
  }
}
