import 'package:semedi_pos/models/purchase_order.dart';
import 'package:semedi_pos/models/purchase_order_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PurchaseOrderService {
  final _supabase = Supabase.instance.client;

  Future<List<PurchaseOrder>> getPurchaseOrders() async {
    try {
      final response = await _supabase
          .from('purchase_orders')
          .select('*, suppliers(name), purchase_order_items(*)')
          .order('created_at', ascending: false);
      return response.map((json) => PurchaseOrder.fromJson(json)).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> createPurchaseOrder({
    required String supplierId,
    String? note,
    required List<PurchaseOrderItem> items,
  }) async {
    try {
      final response = await _supabase
          .from('purchase_orders')
          .insert({
            'supplier_id': supplierId,
            'status': 'draft',
            'note': note,
            'restaurant_id':
                _supabase.auth.currentUser!.userMetadata?['restaurant_id'],
          })
          .select('id')
          .single();
      final orderId = response['id'].toString();
      for (final item in items) {
        await _supabase.from('purchase_order_items').insert({
          ...item.toJson(),
          'purchase_order_id': orderId,
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _supabase
          .from('purchase_orders')
          .update({'status': status}).eq('id', orderId);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> receiveOrderItem({
    required String orderId,
    required PurchaseOrderItem item,
    required double receivedQuantity,
  }) async {
    try {
      await _supabase
          .from('purchase_order_items')
          .update({'received_quantity': receivedQuantity})
          .eq('purchase_order_id', orderId)
          .eq('inventory_item_name', item.inventoryItemName);

      final inventoryRows = await _supabase
          .from('inventory')
          .select('quantity')
          .ilike('name', item.inventoryItemName);

      if (inventoryRows.isNotEmpty) {
        final currentQty =
            double.parse(inventoryRows.first['quantity'].toString());
        final delta = receivedQuantity - item.receivedQuantity;
        await _supabase
            .from('inventory')
            .update({'quantity': currentQty + delta})
            .ilike('name', item.inventoryItemName);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deletePurchaseOrder(String orderId) async {
    try {
      await _supabase
          .from('purchase_order_items')
          .delete()
          .eq('purchase_order_id', orderId);
      await _supabase.from('purchase_orders').delete().eq('id', orderId);
    } catch (e) {
      throw Exception(e);
    }
  }
}
