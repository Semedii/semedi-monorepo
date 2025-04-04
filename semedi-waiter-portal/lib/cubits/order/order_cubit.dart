import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/models/menu.dart';
import 'package:semedi/utils/order_status_enum.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  OrderCubit({
    required int tableNumber,
    required List<MenuItem> menuItems,
  }) : super(OrderInitial(
          selectedItems: [],
          allMenuItems: menuItems,
          filteredMenuItems: menuItems,
        ));

  void onSelectedItem(MenuItem item) {
    var currentState = state as OrderInitial;
    emit(currentState.copyWith(
      selectedItems: [...currentState.selectedItems, item],
    ));
  }

  void onRemoveItem(int index) {
    var currentState = state as OrderInitial;
    final newItems = List<MenuItem>.from(currentState.selectedItems);
    newItems.removeAt(index);
    emit(currentState.copyWith(selectedItems: newItems));
  }

  void updateSearchQuery(String query) {
    var currentState = state as OrderInitial;
    final filtered = currentState.allMenuItems.where((item) {
      final itemName = item.name.toLowerCase();
      final keywords = item.searchKeywords.map((k) => k.toLowerCase()).toList();
      final queryLower = query.toLowerCase();

      return itemName.contains(queryLower) ||
          keywords.any((k) => k.contains(queryLower));
    }).toList();

    emit(currentState.copyWith(
      searchQuery: query,
      filteredMenuItems: filtered,
    ));
  }

  Future<void> submitOrder(int tableNumber) async {
    final currentState = state as OrderInitial;
    if (currentState.selectedItems.isEmpty) {
      throw Exception('Cannot submit empty order');
    }

    final orderData = _prepareOrderData(currentState, tableNumber);

    try {
      final formattedOrderNumber = await _createOrderInFirestore(orderData);
      emit(OrderSuccess(orderNumber: formattedOrderNumber));
    } catch (e) {
      emit(OrderFailure(error: 'Order submission failed: ${e.toString()}'));
      rethrow;
    }
  }

  Map<String, dynamic> _prepareOrderData(OrderInitial state, int tableNumber) {
    final items = <String, int>{};
    final prices = <String, double>{};
    double total = 0.0;

    for (final item in state.selectedItems) {
      final quantity = (items[item.name] ?? 0) + 1;
      items[item.name] = quantity;
      final itemTotal = item.price * quantity;
      prices[item.name] = itemTotal;
      total += item.price;
    }

    return {
      'tableNumber': tableNumber,
      'items': items,
      'prices': prices,
      'total': total,
      'status': 'ordered',
      'timestamp': FieldValue.serverTimestamp(),
      'waiter': FirebaseAuth.instance.currentUser?.displayName ?? 'Unknown',
    };
  }

  Future<String> _createOrderInFirestore(Map<String, dynamic> orderData) async {
    const shopId = 'Barkulan';
    final ordersRef = FirebaseFirestore.instance
        .collection('shops')
        .doc(shopId)
        .collection('orders');

    final counterRef = FirebaseFirestore.instance
        .collection('shops')
        .doc(shopId)
        .collection('metadata')
        .doc('order_counter');

    return await FirebaseFirestore.instance
        .runTransaction<String>((transaction) async {
      final counterSnapshot = await transaction.get(counterRef);
      final nextOrderNumber = (counterSnapshot.data()?['lastNumber'] ?? 0) + 1;

      final formattedOrderNumber = nextOrderNumber.toString().padLeft(4, '0');

      transaction.set(
        ordersRef.doc(formattedOrderNumber),
        {
          ...orderData,
          'orderNumber': nextOrderNumber,
          'formattedOrderNumber': formattedOrderNumber,
        },
      );
      transaction.set(counterRef, {'lastNumber': nextOrderNumber});

      return formattedOrderNumber;
    });
  }
}
