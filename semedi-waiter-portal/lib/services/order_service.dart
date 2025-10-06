import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:semedi/authentication/auth_provider.dart';
import 'package:semedi/models/order_item.dart';
import 'package:semedi/models/order_model.dart';
import 'package:semedi/services/secure_storage_service.dart';
import 'package:semedi/services/service_locator.dart';
import 'package:semedi/utils/order_status_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final db = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;
  final secureStorageService = getIt<SecureStorageService>();

  addNewOrder(
    List<OrderItem> orderItems,
    int tableNumber,
    String? note,
    bool isKitchenRequired,
  ) async {
    final token = getIt<AuthProvider>().token;
    final waiterId = JwtDecoder.decode(token ?? '')['sub'];
    await _supabase.rpc('create_order_with_items', params: {
      '_table_number': tableNumber,
      '_items': orderItems.map((e) => e.toJson()).toList(),
      '_waiter_id': waiterId
    });
  }

  Stream<List<OrderModel>> getAllOrders() {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['id']).asyncMap((_) async {
      final response = await _supabase.from('orders').select('''
              id, status, created_at, 
              profiles(full_name), 
              dining_tables(table_number), 
              order_items(quantity, menu_items(name, price))
            ''').neq('status', 'unpaid');

      return response.map((e) => OrderModel.fromJson(e)).toList();
    });
  }

  Future<void> updateOrderStatus({
    required String orderNumber,
    required OrderStatusEnum newStatus,
  }) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': newStatus.name}).eq('id', orderNumber);
    } catch (e) {
      throw Exception('Failed to update status: ${e.toString()}');
    }
  }

  Future<void> requestPay({
    required String orderNumber,
    required String namePhone,
  }) async {
    try {
      //todo
    } catch (e) {
      throw Exception('Failed to update status: ${e.toString()}');
    }
  }

  Future<void> cancelOrder(String orderNumber) async {
    try {
      //todo
    } catch (e) {
      print("Failed to cancel order: ${e.toString()}");
    }
  }
}
