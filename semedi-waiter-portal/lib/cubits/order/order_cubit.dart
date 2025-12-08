import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/models/menu.dart';
import 'package:semedi/models/order_item.dart';
import 'package:semedi/services/menu_service.dart';
import 'package:semedi/services/order_service.dart';
import 'package:semedi/utils/order_status_enum.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderService _orderService = OrderService();
  final MenuService _menuService = MenuService();

  OrderCubit() : super(OrderInitial());

  void initPage() async {
    List<MenuItem> allMenuItems = await _menuService.getMenu();
    emit(
      OrderIdle(
        orderItems: [],
        allMenuItems: allMenuItems,
        filteredMenuItems: allMenuItems,
      ),
    );
  }

  void onSelectedItem(MenuItem item) {
    var currentState = state as OrderIdle;
    List<OrderItem> updatedItems = List.from(currentState.orderItems);
    int existingIndex = updatedItems.indexWhere((i) => i.itemId == item.id);
    if (existingIndex != -1) {
      final OrderItem existingItem = updatedItems[existingIndex];
      updatedItems[existingIndex] =
          existingItem.copyWith(itemQuantity: existingItem.itemQuantity! + 1);
    } else {
      updatedItems.add(OrderItem(
          itemId: item.id,
          itemName: item.name,
          itemPrice: item.price,
          itemQuantity: 1));
    }
    emit(currentState.copyWith(orderItems: updatedItems));
  }

  void onNoteChanged(String? note, int index) {
    var currentState = state as OrderIdle;
    final items = List<OrderItem>.from(currentState.orderItems);
    if (index < 0 || index >= items.length) return;

    items[index] = items[index].copyWith(note: note);

    emit(currentState.copyWith(orderItems: items));
  }

  void onIsKitchenRequiredChanged(bool? isKitchenRequired) {
    var currentState = state as OrderIdle;
    emit(currentState.copyWith(isKitchenRequired: isKitchenRequired));
  }

  void onDecrementItem(int index) {
    var currentState = state as OrderIdle;
    final newItems = List<OrderItem>.from(currentState.orderItems);
    final item = newItems[index];

    if (item.itemQuantity != null && item.itemQuantity! > 1) {
      newItems[index] = item.copyWith(itemQuantity: item.itemQuantity! - 1);
    } else {
      newItems.removeAt(index);
    }

    emit(currentState.copyWith(orderItems: newItems));
  }

  void onIncrementItem(int index) {
    var currentState = state as OrderIdle;
    final newItems = List<OrderItem>.from(currentState.orderItems);
    final item = newItems[index];

    if (item.itemQuantity != null) {
      newItems[index] = item.copyWith(itemQuantity: item.itemQuantity! + 1);
    }

    emit(currentState.copyWith(orderItems: newItems));
  }

  void updateSearchQuery(String query) {
    var currentState = state as OrderIdle;
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

  double calculateOrderTotal() {
    var currentState = state as OrderIdle;
    double total = 0;

    for (var order in currentState.orderItems) {
      total += (order.itemPrice! * order.itemQuantity!);
    }

    return total;
  }

  submitOrder(int tableNumber) async {
    var currentState = state as OrderIdle;
    emit(OrderLoading());
    try {
      var orderNumber = await _orderService.addNewOrder(
        currentState.orderItems,
        tableNumber,
        currentState.isKitchenRequired,
      );
      emit(OrderSuccess(orderNumber: orderNumber.toString()));
    } catch (e) {
      emit(OrderFailure(error: e.toString()));
      emit(currentState);
    }
  }
}
