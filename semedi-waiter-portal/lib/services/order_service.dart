import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semedi/models/menu.dart';
import 'package:semedi/models/order.dart';
import 'package:semedi/services/secure_storage_service.dart';
import 'package:semedi/services/service_locator.dart';
import 'package:semedi/utils/order_status_enum.dart';

class OrderService {
  final db = FirebaseFirestore.instance;
  final secureStorageService = getIt<SecureStorageService>();
  submitOrder(
    List<MenuItem> selectedItems,
    int tableNumber,
    String? note,
  ) async {
    String? waiter = await secureStorageService.read('waiter_name');
    String? existingOrderNumber = await _getActiveOrderForTable(tableNumber);
    if (existingOrderNumber != null) {
      return await addItemsToExistingOrder(
        orderNumber: existingOrderNumber,
        newItems: selectedItems,
        note: note,
        waiter: waiter,
      );
    } else {
      return await addNewOrder(selectedItems, tableNumber, note, waiter);
    }
  }

  addNewOrder(
    List<MenuItem> selectedItems,
    int tableNumber,
    String? note,
    String? waiter,
  ) async {
    try {
      String? restaurantName = await _getRestaurantName();
      int orderNumber = await _getLastOrderNumber() + 1;
      OrderModel order =
          _prepareOrderData(selectedItems, tableNumber, note, waiter);
      final orderRef = db
          .collection('shops')
          .doc(restaurantName)
          .collection('orders')
          .doc(orderNumber.toString().padLeft(4, '0'));

      orderRef
          .withConverter<OrderModel>(
            fromFirestore: (snapshot, _) => OrderModel.fromFirestore(snapshot),
            toFirestore: (order, _) => order.toFirestore(),
          )
          .set(order);
      await _incrementOrderNumber(restaurantName!, orderNumber);
      return orderNumber;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<int> _getLastOrderNumber() async {
    try {
      String? restaurantName = await _getRestaurantName();
      final orderNumberRef = db
          .collection('shops')
          .doc(restaurantName)
          .collection('metadata')
          .doc('orderNumber');

      var docSnapshot = await orderNumberRef.get();
      int orderNumber;
      if (docSnapshot.exists) {
        orderNumber = docSnapshot['lastNumber'];
      } else {
        orderNumber = 1;
      }
      return orderNumber;
    } catch (e) {
      throw Exception(e);
    }
  }

  _incrementOrderNumber(String restaurantName, int orderNumber) async {
    try {
      final orderNumberRef = db
          .collection('shops')
          .doc(restaurantName)
          .collection('metadata')
          .doc('orderNumber');
      var docSnapshot = await orderNumberRef.get();
      if (docSnapshot.exists) {
        await orderNumberRef.update({'lastNumber': FieldValue.increment(1)});
      } else {
        orderNumberRef.set({'lastNumber': orderNumber});
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  OrderModel _prepareOrderData(
    List<MenuItem> selectedItems,
    int tableNumber,
    String? note,
    String? waiter,
  ) {
    final itemsWithQuantity = <String, int>{};
    final itemsWithPrices = <String, double>{};
    double total = 0.0;

    for (final item in selectedItems) {
      final quantity = (itemsWithQuantity[item.name] ?? 0) + 1;
      itemsWithQuantity[item.name] = quantity;
      final itemTotal = item.price * quantity;
      itemsWithPrices[item.name] = itemTotal;

      total += item.price;
    }

    return OrderModel(
      tableNumber: tableNumber,
      note: note,
      itemsWithQuantity: itemsWithQuantity,
      itemsWithPrices: itemsWithPrices,
      status: OrderStatusEnum.ordered,
      timestamp: DateTime.now(),
      total: total,
      waiter: waiter ?? "unknown",
    );
  }

  Stream<List<OrderModel>> getAllOrders(
    String? waiterName,
    String? restaurantName,
  ) {
    return db
        .collection('shops')
        .doc(restaurantName)
        .collection('orders')
        .orderBy('status')
        .where('waiter', isEqualTo: waiterName)
        .orderBy('timestamp', descending: true)
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
      String? restaurantName = await _getRestaurantName();
      final query = await db
          .collection('shops')
          .doc(restaurantName)
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
    String? waiter,
  }) async {
    try {
      String? restaurantName = await _getRestaurantName();
      final orderRef = db
          .collection('shops')
          .doc(restaurantName)
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
          _updateOrderWithNewItems(currentOrder, newItems, newNote, waiter);

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
    String? waiter,
  ) {
    final itemsWithQuantity =
        Map<String, int>.from(currentOrder.itemsWithQuantity);
    final itemsWithPrices =
        Map<String, double>.from(currentOrder.itemsWithPrices);
    double total = currentOrder.total;

    for (final item in newItems) {
      final newQuantity = (itemsWithQuantity[item.name] ?? 0) + 1;
      itemsWithQuantity[item.name] = newQuantity;

      itemsWithPrices[item.name] = item.price * newQuantity;

      total += item.price;
    }

    return currentOrder.copyWithItem(
      itemsWithQuantity: itemsWithQuantity,
      note: note,
      itemsWithPrices: itemsWithPrices,
      status: OrderStatusEnum.ordered,
      total: total,
      timestamp: DateTime.now(),
      waiter: waiter ?? "unknown",
    );
  }

  Future<void> updateOrderStatus({
    required String orderNumber,
    required OrderStatusEnum newStatus,
  }) async {
    try {
      String? restaurantName = await _getRestaurantName();
      await db
          .collection('shops')
          .doc(restaurantName)
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

  Future<void> requestPay({
    required String orderNumber,
    required String namePhone,
  }) async {
    try {
      String? restaurantName = await _getRestaurantName();
      await db
          .collection('shops')
          .doc(restaurantName)
          .collection('orders')
          .doc(orderNumber)
          .update({
        'status': OrderStatusEnum.payPending.name,
        'namePhone': namePhone,
      });
    } catch (e) {
      throw Exception('Failed to update status: ${e.toString()}');
    }
  }

  Future<void> cancelOrder(String orderNumber) async {
    try {
      String? restaurantName = await _getRestaurantName();
      var orderDoc = await db
          .collection('shops')
          .doc(restaurantName)
          .collection('orders')
          .doc(orderNumber)
          .get();

      if (!orderDoc.exists) {
        print("Order not found.");
        return;
      }

      await db
          .collection('shops')
          .doc(restaurantName)
          .collection('orders')
          .doc(orderNumber)
          .delete();
      print("Order has been canceled and deleted successfully.");
    } catch (e) {
      print("Failed to cancel order: ${e.toString()}");
    }
  }

  _getRestaurantName() async {
    String? restaurantName = await secureStorageService.read('restaurant');
    return restaurantName;
  }
}
