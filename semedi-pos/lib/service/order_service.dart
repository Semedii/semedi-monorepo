import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semedi_pos/models/order.dart';
import 'package:semedi_pos/utils/order_status_enum.dart';

class OrderService {
  final db = FirebaseFirestore.instance;

  Stream<List<OrderModel>> getActiveOrders() {
    return db
        .collection('shops')
        .doc('Barkulan')
        .collection('orders')
        .where('status', isEqualTo: OrderStatusEnum.delivered.name)
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
    final querySnapshot = await db
        .collection('shops')
        .doc('Barkulan')
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
    final querySnapshot = await db
        .collection('shops')
        .doc('Barkulan')
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
    final querySnapshot = await db
        .collection('shops')
        .doc('Barkulan')
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
      await db
          .collection('shops')
          .doc('Barkulan')
          .collection('orders')
          .doc(orderNumber)
          .update({
        'status': status.name,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update status: ${e.toString()}');
    }
  }
}
