import 'package:semedi/models/order_item.dart';
import 'package:semedi/models/order_model.dart';
import 'package:semedi/services/secure_storage_service.dart';
import 'package:semedi/services/service_locator.dart';
import 'package:semedi/utils/order_status_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final secureStorageService = getIt<SecureStorageService>();
  final _supabase = Supabase.instance.client;

  addNewOrder(
    List<OrderItem> orderItems,
    String tableId,
    bool isKitchenRequired,
  ) async {
    // var response = await _supabase.rpc('create_order_with_items', params: {
    //   'order_data': {
    //     'table_id': tableId,
    //     'items': orderItems.map((e) => e.toJson()).toList(),
    //   }
    // });
    // return response;
  }

  getAllOrders() {
    // return _supabase
    //     .from('orders')
    //     .stream(primaryKey: ['id']).asyncMap((_) async {
    //   final response = await _supabase.from('orders').select('''
    //           id, order_number, status, created_at,
    //           users(full_name),
    //           dining_tables(table_number),
    //           order_items(quantity, note, menu_items(name, price))
    //         ''').neq('status', 'unpaid');

    //   return response.map((e) => OrderModel.fromJson(e)).toList();
    // });
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatusEnum newStatus,
  }) async {
    // try {
    //   await _supabase
    //       .from('orders')
    //       .update({'status': newStatus.name}).eq('id', orderId);
    // } catch (e) {
    //   throw Exception('Failed to update status: ${e.toString()}');
    // }
  }

  Future<void> requestPay({
    required String orderId,
    required String namePhone,
  }) async {
    // try {
    //   await _supabase.from('orders').update({
    //     'status': OrderStatusEnum.payPending.name,
    //     'note': namePhone
    //   }).eq('id', orderId);
    // } catch (e) {
    //   throw Exception('Failed to update status: ${e.toString()}');
    // }
  }

  Future<void> cancelOrder(String orderNumber) async {
    try {
      //todo
    } catch (e) {
      print("Failed to cancel order: ${e.toString()}");
    }
  }

  Future<List<OrderModel>> getOrderHistory() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay =
        DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final response = await _supabase
        .from('orders')
        .select('''
          id, order_number, status, created_at,
          users(full_name),
          dining_tables(table_number),
          order_items(quantity, note, menu_items(name, price))
        ''')
        .eq('status', 'paid')
        .gte('created_at', startOfDay)
        .lte('created_at', endOfDay)
        .order('created_at', ascending: false);

    return response.map((e) => OrderModel.fromJson(e)).toList();
  }
}
