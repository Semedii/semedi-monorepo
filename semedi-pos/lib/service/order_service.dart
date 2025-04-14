import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semedi_pos/models/order.dart';
import 'package:semedi_pos/service/secure_storage_service%20copy.dart';
import 'package:semedi_pos/utils/order_status_enum.dart';

class OrderService {
  final db = FirebaseFirestore.instance;

  addTakeAwayOrder(OrderModel order) async {
    try {
      final orderNumber = await _getLastOrderNumber();
      String? restaurant = await _getRestaurantName();
      final orderRef = db
          .collection('shops')
          .doc(restaurant)
          .collection('orders')
          .doc(orderNumber.toString().padLeft(4, '0'));

      orderRef
          .withConverter<OrderModel>(
              fromFirestore: (snapshot, _) =>
                  OrderModel.fromFirestore(snapshot),
              toFirestore: (order, _) => order.toFirestore())
          .set(order);
    } catch (e) {
      throw Exception(e);
    }
  }

  Stream<List<OrderModel>> getActiveOrders(String restuarant) {
    return db
        .collection('shops')
        .doc(restuarant)
        .collection('orders')
        .where(Filter.or(
          Filter.and(
            Filter('status', isNotEqualTo: OrderStatusEnum.paid.name),
            Filter('waiter', isEqualTo: 'Cashier'),
          ),
          Filter('status', isEqualTo: OrderStatusEnum.delivered.name),
        ))
        .orderBy('status')
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

  Future<List<OrderModel>?> getOrdersByStatus(OrderStatusEnum status) async {
    String? restaurant = await _getRestaurantName();
    final querySnapshot = await db
        .collection('shops')
        .doc(restaurant)
        .collection('orders')
        .where('status', isEqualTo: status.name)
        .orderBy('status')
        .orderBy('timestamp', descending: true)
        .withConverter<OrderModel>(
          fromFirestore: (snapshot, _) => OrderModel.fromFirestore(snapshot),
          toFirestore: (order, _) =>
              throw UnimplementedError("Adding order not allowed"),
        )
        .get();

    final orders = querySnapshot.docs.map((doc) => doc.data()).toList();

    return orders;
  }

  Future<List<OrderModel>?> getOrdersByWaiter(String waiterName) async {
    String? restaurant = await _getRestaurantName();
    final querySnapshot = await db
        .collection('shops')
        .doc(restaurant)
        .collection('orders')
        .where('waiter', isEqualTo: waiterName)
        .orderBy('status')
        .orderBy('timestamp', descending: true)
        .withConverter<OrderModel>(
          fromFirestore: (snapshot, _) => OrderModel.fromFirestore(snapshot),
          toFirestore: (order, _) =>
              throw UnimplementedError("Adding order not allowed"),
        )
        .get();

    final orders = querySnapshot.docs.map((doc) => doc.data()).toList();

    return orders;
  }

  Future<List<OrderModel>?> getPaidAndUnpaidOrders() async {
    String? restaurant = await _getRestaurantName();
    final querySnapshot = await db
        .collection('shops')
        .doc(restaurant)
        .collection('orders')
        .where('status',
            whereIn: [OrderStatusEnum.paid.name, OrderStatusEnum.unpaid.name])
        .orderBy('status')
        .orderBy('timestamp', descending: true)
        .withConverter<OrderModel>(
          fromFirestore: (snapshot, _) => OrderModel.fromFirestore(snapshot),
          toFirestore: (order, _) =>
              throw UnimplementedError("Adding order not allowed"),
        )
        .get();

    final orders = querySnapshot.docs.map((doc) => doc.data()).toList();

    return orders;
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

  Future<int> _getLastOrderNumber() async {
    try {
      String? restaurant = await _getRestaurantName();
      final orderNumberRef = db
          .collection('shops')
          .doc(restaurant)
          .collection('metadata')
          .doc('orderNumber');

      var docSnapshot = await orderNumberRef.get();
      int orderNumber;
      if (docSnapshot.exists) {
        await orderNumberRef.update({'lastNumber': FieldValue.increment(1)});
        docSnapshot = await orderNumberRef.get();
        orderNumber = docSnapshot['lastNumber'];
      } else {
        orderNumber = 1;
        orderNumberRef.set({'lastNumber': orderNumber});
      }
      return orderNumber;
    } catch (e) {
      throw Exception(e);
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
    String? restaurant = await SecureStorageService().read('restaurant');
    return restaurant;
  }
}
