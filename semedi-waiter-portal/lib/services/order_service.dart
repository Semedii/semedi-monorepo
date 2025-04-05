import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:semedi/models/menu.dart';
import 'package:semedi/models/order.dart';
import 'package:semedi/utils/order_status_enum.dart';

class OrderService {
  final db = FirebaseFirestore.instance;

  submitOrder(
    List<MenuItem> selectedItems,
    int tableNumber,
    String? note,
  ) async {
    String? existingOrderNumber = await _getActiveOrderForTable(tableNumber);
    if (existingOrderNumber != null) {
      return await addItemsToExistingOrder(
          orderNumber: existingOrderNumber,
          newItems: selectedItems,
          note: note);
    } else {
      return await addNewOrder(selectedItems, tableNumber, note);
    }
  }

  addNewOrder(
    List<MenuItem> selectedItems,
    int tableNumber,
    String? note,
  ) async {
    try {
      int orderNumber = await _getLastOrderNumber();
      OrderModel order = _prepareOrderData(selectedItems, tableNumber, note);
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

  OrderModel _prepareOrderData(
    List<MenuItem> selectedItems,
    int tableNumber,
    String? note,
  ) {
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
      note: note,
      items: items,
      itemDetails: itemDetails,
      status: OrderStatusEnum.ordered,
      timestamp: DateTime.now(),
      total: total,
      waiter: FirebaseAuth.instance.currentUser?.email ?? "unknown",
    );
  }

  Stream<List<OrderModel>> getActiveOrders() {
    return db
        .collection('shops')
        .doc('Barkulan')
        .collection('orders')
        .where('status', isNotEqualTo: OrderStatusEnum.paid.name)
        .orderBy(
            'status') // Primary sort by status (Firestore sorts alphabetically)
        .orderBy('timestamp', descending: true) // Secondary sort
        .withConverter<OrderModel>(
          fromFirestore: (snapshot, _) => OrderModel.fromFirestore(snapshot),
          toFirestore: (order, _) => order.toFirestore(),
        )
        .snapshots()
        .map((querySnapshot) {
      // Client-side sorting to prioritize 'ready' status
      final orders = querySnapshot.docs.map((doc) => doc.data()).toList();
      orders.sort((a, b) {
        if (a.status == OrderStatusEnum.ready &&
            b.status != OrderStatusEnum.ready) {
          return -1; // 'ready' comes first
        } else if (a.status != OrderStatusEnum.ready &&
            b.status == OrderStatusEnum.ready) {
          return 1;
        }
        return b.timestamp.compareTo(a.timestamp); // Fallback to timestamp
      });
      return orders;
    });
  }

  _getActiveOrderForTable(int tableNumber) async {
    try {
      final query = await db
          .collection('shops')
          .doc('Barkulan')
          .collection('orders')
          .where('tableNumber', isEqualTo: tableNumber)
          .where('status', isNotEqualTo: OrderStatusEnum.paid.name)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      return query.docs.first.id;
    } catch (e) {
      throw Exception('Failed to check table status: ${e.toString()}');
    }
  }

  addItemsToExistingOrder({
    required String orderNumber,
    required List<MenuItem> newItems,
    String? note,
  }) async {
    try {
      final orderRef = db
          .collection('shops')
          .doc('Barkulan')
          .collection('orders')
          .doc(orderNumber);

      final docSnapshot = await orderRef.get();
      if (!docSnapshot.exists) {
        throw Exception("Order not found");
      }

      final currentOrder = OrderModel.fromFirestore(docSnapshot);
      String? prevNote = (docSnapshot.data() as Map<String, dynamic>)['note'];
      String? newNote = (prevNote != null && prevNote.isNotEmpty)
          ? "$prevNote, \n $note"
          : note;

      final updatedOrder =
          _updateOrderWithNewItems(currentOrder, newItems, newNote);

      await orderRef.update(updatedOrder.toFirestore());
      return currentOrder.orderNumber;
    } catch (e) {
      throw Exception("Failed to update order: $e");
    }
  }

  OrderModel _updateOrderWithNewItems(
    OrderModel currentOrder,
    List<MenuItem> newItems,
    String? note,
  ) {
    final updatedItems = Map<String, int>.from(currentOrder.items);
    final updatedItemDetails =
        Map<String, dynamic>.from(currentOrder.itemDetails);
    double updatedTotal = currentOrder.total;

    for (final item in newItems) {
      final newQuantity = (updatedItems[item.name] ?? 0) + 1;
      updatedItems[item.name] = newQuantity;

      updatedItemDetails[item.name] = {
        'price': item.price * newQuantity,
        'name': item.name,
      };

      updatedTotal += item.price;
    }

    return currentOrder.copyWithItem(
      items: updatedItems,
      note: note,
      itemDetails: updatedItemDetails,
      status: OrderStatusEnum.ordered,
      total: updatedTotal,
      timestamp: DateTime.now(),
      waiter: FirebaseAuth.instance.currentUser?.email ?? "unknown",
    );
  }

  Future<void> updateOrderStatus({
    required String orderNumber,
    required OrderStatusEnum newStatus,
  }) async {
    try {
      await db
          .collection('shops')
          .doc('Barkulan')
          .collection('orders')
          .doc(orderNumber)
          .update({
        'status': newStatus.name,
        'timestamp': FieldValue.serverTimestamp(), // Update timestamp
      });
    } catch (e) {
      throw Exception('Failed to update status: ${e.toString()}');
    }
  }
}
