import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semedi_pos/models/order.dart';
import 'package:semedi_pos/utils/order_status_enum.dart';

class OrderService {
  final db = FirebaseFirestore.instance;

  addTakeAwayOrder(OrderModel order) async {
    try {
      final orderNumber = await _getLastOrderNumber();
      final orderRef = db
          .collection('shops')
          .doc('Barkulan')
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
      });
    } catch (e) {
      throw Exception('Failed to update status: ${e.toString()}');
    }
  }

  Future<int> _getLastOrderNumber() async {
    try {
      final orderNumberRef = db
          .collection('shops')
          .doc('Barkulan')
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
}
