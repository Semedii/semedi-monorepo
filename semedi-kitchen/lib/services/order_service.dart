import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semedi_kitchen/models/order.dart';
import 'package:semedi_kitchen/utils/order_status_enum.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final db = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;

  Stream<List<OrderModel>> getActiveOrders() {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['id']).asyncMap((_) async {
      final response = await _supabase.from('orders').select('''
              id, status, created_at, 
              profiles(full_name), 
              dining_tables(table_number), 
              order_items(quantity, menu_items(name, price))
            ''').neq('status', 'paid');

      return response.map((e) => OrderModel.fromJson(e)).toList();
    });
  }

  Future<void> changeOrderStatus({
    required String orderNumber,
    required OrderStatusEnum status,
  }) async {
    await _supabase
        .from('orders')
        .update({'status': status.name}).eq('id', orderNumber);
  }

  Future<void> cancelOrder(String orderNumber) async {
    await _supabase
        .from('orders')
        .update({'status': 'cancelled'}).eq('id', orderNumber);
  }
}
