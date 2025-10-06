import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semedi_pos/models/daily_summary.dart';
import 'package:semedi_pos/models/order_model.dart';
import 'package:semedi_pos/utils/order_status_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final db = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;

  //todo
  addTakeOrder(OrderModel order) async {}

  Stream<List<OrderModel>> getActiveOrders() {
    return _supabase
        .from('orders')
        .select(
            'id, status, created_at, profiles(full_name),dining_tables(table_number), order_items(quantity, menu_items(name, price))')
        .eq('status', 'pending')
        .asStream()
        .map((rows) => rows.map((e) => OrderModel.fromJson(e)).toList());
  }

  Future<List<OrderModel>?> getOrdersByStatus(String status) async {
    final response = await _supabase
        .from('orders')
        .select(
            'id, status, created_at, profiles(full_name),dining_tables(table_number), order_items(quantity, menu_items(name, price))')
        .eq('status', status);

    return (response as List<dynamic>)
        .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

//todo
  Future<List<OrderModel>?> getOrdersByWaiter(String waiterName) async {
    final response = await _supabase
        .from('orders')
        .select(
            'id, status, created_at, profiles(full_name),dining_tables(table_number), order_items(quantity, menu_items(name, price))')
        .eq('profiles(full_name)', waiterName);

    return (response as List<dynamic>)
        .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<OrderModel>?> getPaidAndUnpaidOrders() async {
    final response = await _supabase
        .from('orders')
        .select(
            'id, status, created_at, profiles(full_name),dining_tables(table_number), order_items(quantity, menu_items(name, price))')
        .eq('status', 'paid');

    return (response as List<dynamic>)
        .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
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

  Future<List<DailySummary>> getSalesHistory() async {
    final summaryRef = db
        .collection('shops')
        .doc('restaurant')
        .collection('summaryArchives')
        .withConverter<DailySummary>(
          fromFirestore: DailySummary.fromFirestore,
          toFirestore: DailySummary.toFirestore,
        );
    final querySnapshot = await summaryRef.get();
    final summaryList = querySnapshot.docs.map((doc) => doc.data()).toList();

    return summaryList;
  }
}
