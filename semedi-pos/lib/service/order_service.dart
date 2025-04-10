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

  Future<List<OrderModel>?> getPaidOrders() async {
    final querySnapshot = await db
        .collection('shops')
        .doc('Barkulan')
        .collection('orders')
        .where('status', isEqualTo: OrderStatusEnum.paid.name)
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

  Future<void> markOrderPaid({
    required String orderNumber,
  }) async {
    try {
      await db
          .collection('shops')
          .doc('Barkulan')
          .collection('orders')
          .doc(orderNumber)
          .update({
        'status': OrderStatusEnum.paid.name,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update status: ${e.toString()}');
    }
  }
}
