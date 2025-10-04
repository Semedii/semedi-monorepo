import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:semedi_pos/models/daily_summary.dart';
import 'package:semedi_pos/models/order_model.dart';
import 'package:semedi_pos/models/waiters_perfomance.dart';
import 'package:semedi_pos/service/secure_storage_service.dart';
import 'package:semedi_pos/utils/order_status_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final db = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;

  //todo
  addTakeOrder(OrderModel order) async {}

  //todo
  Stream<List<OrderModel>> getActiveOrders(String restuarant) {
    throw UnimplementedError();
  }

  Future<List<OrderModel>?> getOrdersByStatus(String status) async {
    final response = await _supabase
        .from('orders')
        .select(
            'id, dining_tables(table_number), status, created_at, profiles(full_name)')
        .eq('status', status);

    return (response as List<dynamic>)
        .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<OrderModel>?> getOrdersByWaiter(String waiterName) async {
    return [];
  }

  Future<List<OrderModel>?> getPaidAndUnpaidOrders() async {
    return [];
  }

  Future<void> changeOrderStatus({
    required String orderNumber,
    required OrderStatusEnum status,
  }) async {}

  Future<void> cancelOrder(String orderNumber) async {}

  Future<void> archiveSummary({
    required Map<String, double> salesData,
    required int totalOrders,
    required List<WaitersPerfomance> waitersPerfomanceList,
  }) async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      String? restaurant = await _getRestaurantName();
      final summary = DailySummary(
        date: date,
        restaurant: restaurant ?? '',
        dineIn: salesData['dineIn']!,
        takeAway: salesData['takeAway']!,
        totalSales: salesData['totalSales']!,
        dineInVat: salesData['dineInVat']!,
        takeAwayVat: salesData['takeAwayVat']!,
        totalVat: salesData['totalVat']!,
        dineInNet: salesData['dineInNet']!,
        takeAwayNet: salesData['takeAwayNet']!,
        totalNet: salesData['totalNet']!,
        unpaidDineIn: salesData['unPaidDineIn']!,
        unpaidTakeAway: salesData['unPaidTakeAway']!,
        unpaidTotal: salesData['unPaidTotal']!,
        noOfOrdersDineIn: salesData['noOfOrdersDineIn']!.toInt(),
        noOfOrdersTakeAway: salesData['noOfOrdersTakeAway']!.toInt(),
        totalOrders: totalOrders,
        waitersPerfomanceList: waitersPerfomanceList,
      );

      await FirebaseFirestore.instance
          .collection('shops')
          .doc(restaurant)
          .collection('summaryArchives')
          .doc('$restaurant-${date.replaceAll('/', '-')}')
          .set(summary.toMap());
      await _clearOrder();
      await _resetOrderNumber();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _clearOrder() async {
    try {
      String? restaurant = await _getRestaurantName();
      if (restaurant == null || restaurant.isEmpty) {
        throw Exception('Restaurant name not found');
      }

      final ordersRef = FirebaseFirestore.instance
          .collection('shops')
          .doc(restaurant)
          .collection('orders');

      await _deleteCollection(ordersRef);

      print('All orders deleted successfully');
    } catch (e) {
      print('Error deleting orders: $e');
      rethrow;
    }
  }

  _resetOrderNumber() async {
    try {
      String? restaurant = await _getRestaurantName();
      await db
          .collection('shops')
          .doc(restaurant)
          .collection('metadata')
          .doc('orderNumber')
          .delete();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _deleteCollection(CollectionReference collectionRef,
      {int batchSize = 100}) async {
    QuerySnapshot snapshot = await collectionRef.limit(batchSize).get();

    while (snapshot.docs.isNotEmpty) {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (DocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      snapshot = await collectionRef.limit(batchSize).get();
    }
  }

  Future<List<DailySummary>> getSalesHistory() async {
    String? restaurant = await _getRestaurantName();
    final summaryRef = db
        .collection('shops')
        .doc(restaurant)
        .collection('summaryArchives')
        .withConverter<DailySummary>(
          fromFirestore: DailySummary.fromFirestore,
          toFirestore: DailySummary.toFirestore,
        );
    final querySnapshot = await summaryRef.get();
    final summaryList = querySnapshot.docs.map((doc) => doc.data()).toList();

    return summaryList;
  }

  Future<String?> _getRestaurantName() async {
    String? restaurant = await SecureStorageService().read('restaurant');
    return restaurant;
  }
}
