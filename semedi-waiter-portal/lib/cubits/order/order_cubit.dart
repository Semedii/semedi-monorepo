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
    var currentState = state as OrderInitial;
    if (currentState.selectedItems.isEmpty) {
      throw Exception('Please select at least one item');
    }
    final items = <String, int>{};
    final prices = <String, double>{};
    for (final item in currentState.selectedItems) {
      items[item.name] = (items[item.name] ?? 0) + 1;
      prices[item.name] = item.price;
    }
    const shopId = 'Barkulan';
    await FirebaseFirestore.instance
        .collection('shops')
        .doc(shopId)
        .collection('orders')
        .add({
      'tableNumber': tableNumber,
      'items': items,
      'prices': prices,
      'status': 'ordered',
      'timestamp': FieldValue.serverTimestamp(),
      'waiter': FirebaseAuth.instance.currentUser?.displayName,
    });

    // 5. Update state
    emit(OrderSuccess());
  }
}
