import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:semedi/models/menu.dart';
import 'package:semedi/models/order.dart';
import 'package:semedi/utils/order_status_enum.dart';

class OrderService {
  final db = FirebaseFirestore.instance;
  addNewOrder(List<MenuItem> selectedItems, int tableNumber) async {
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
        ;
        orderNumber = 1;
        orderNumberRef.set({'lastNumber': 1});
      }
      OrderModel order = _prepareOrderData(selectedItems, tableNumber);
      final orderRef = db
          .collection('shops')
          .doc('Barkulan')
          .collection('orders')
          .doc(orderNumber.toString().padLeft(4, '0'));
      orderRef
          .withConverter<OrderModel>(
            fromFirestore: (snapshot, _) => OrderModel.fromFirestore(snapshot),
            toFirestore: (order, _) => order.toFirestore(),
          )
          .set(order);
      return orderNumber;
    } catch (e) {
      throw Exception(e);
    }
  }

  OrderModel _prepareOrderData(List<MenuItem> selectedItems, int tableNumber) {
    final items = <String, int>{};
    final itemDetails = <String, dynamic>{};
    double total = 0.0;

    for (final item in selectedItems) {
      final quantity = (items[item.name] ?? 0) + 1;
      items[item.name] = quantity;
      final itemTotal = item.price * quantity;
      itemDetails[item.name] = {
        'price': itemTotal,
        'name': item.name,
      };
      total += item.price;
    }

    return OrderModel(
      tableNumber: tableNumber,
      items: items,
      itemDetails: itemDetails,
      status: OrderStatusEnum.ordered,
      timestamp: DateTime.now(),
      total: total,
      waiter: FirebaseAuth.instance.currentUser?.email ?? "unknown",
    );
  }

  Stream<List<OrderModel>> getAllOrders() {
    return db
        .collection('shops')
        .doc('Barkulan')
        .collection('orders')
        .orderBy('timestamp', descending: true) // Newest orders first
        .withConverter<OrderModel>(
          fromFirestore: (snapshot, _) => OrderModel.fromFirestore(snapshot),
          toFirestore: (order, _) => order.toFirestore(),
        )
        .snapshots()
        .map((querySnapshot) =>
            querySnapshot.docs.map((doc) => doc.data()).toList());
  }
}
