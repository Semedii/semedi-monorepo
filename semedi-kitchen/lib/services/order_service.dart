import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semedi_kitchen/models/order.dart';
import 'package:semedi_kitchen/services/secure_storage_service.dart';
import 'package:semedi_kitchen/services/service_locator.dart';
import 'package:semedi_kitchen/utils/order_status_enum.dart';

class OrderService {
  final db = FirebaseFirestore.instance;
  final _secureStorageService = getIt<SecureStorageService>();
  Stream<List<OrderModel>> getActiveOrders(String restuarant) {
    return db
        .collection('shops')
        .doc(restuarant)
        .collection('orders')
        .where(Filter.or(
          Filter('status', isEqualTo: OrderStatusEnum.ordered.name),
          Filter('status', isEqualTo: OrderStatusEnum.preparing.name),
          Filter('status', isEqualTo: OrderStatusEnum.ready.name),
        ))
        .orderBy('timestamp', descending: true)
        .withConverter<OrderModel>(
          fromFirestore: (snapshot, _) => OrderModel.fromFirestore(snapshot),
          toFirestore: (order, _) =>
              throw UnimplementedError("Adding order not allowed"),
        )
        .snapshots()
        .map((querySnapshot) {
      final orders = querySnapshot.docs.map((doc) => doc.data()).toList();

      return orders;
    });
  }

  Future<void> changeOrderStatus({
    required String orderNumber,
    required OrderStatusEnum status,
  }) async {
    try {
      String? restaurant = await _getRestaurantName();
      await db
          .collection('shops')
          .doc(restaurant)
          .collection('orders')
          .doc(orderNumber)
          .update({
        'status': status.name,
      });
    } catch (e) {
      throw Exception('Failed to update status: ${e.toString()}');
    }
  }

  Future<void> cancelOrder(String orderNumber) async {
    try {
      String? restaurant = await _getRestaurantName();
      var orderDoc = await db
          .collection('shops')
          .doc(restaurant)
          .collection('orders')
          .doc(orderNumber)
          .get();

      if (!orderDoc.exists) {
        print("Order not found.");
        return;
      }

      await db
          .collection('shops')
          .doc(restaurant)
          .collection('orders')
          .doc(orderNumber)
          .delete();
      print("Order has been canceled and deleted successfully.");
    } catch (e) {
      print("Failed to cancel order: ${e.toString()}");
    }
  }

  Future<String?> _getRestaurantName() async {
    String? restaurant = await _secureStorageService.read('restaurant');
    return restaurant;
  }
}
