import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/models/menu.dart';
import 'package:semedi/services/order_service.dart';
import 'package:semedi/utils/order_status_enum.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderService _orderService = OrderService();

  OrderCubit() : super(OrderInitial());

  void initPage(List<MenuItem> menuItems) {
    emit(
      OrderIdle(
        selectedItems: [],
        allMenuItems: menuItems,
        filteredMenuItems: menuItems,
      ),
    );
  }

  void onSelectedItem(MenuItem item) {
    var currentState = state as OrderIdle;
    emit(currentState.copyWith(
      selectedItems: [...currentState.selectedItems, item],
    ));
  }

  void onRemoveItem(int index) {
    var currentState = state as OrderIdle;
    final newItems = List<MenuItem>.from(currentState.selectedItems);
    newItems.removeAt(index);
    emit(currentState.copyWith(selectedItems: newItems));
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

  getOrderItemQuantity() {
    var currentState = state as OrderIdle;
    final itemsWithQuantity =
        currentState.selectedItems.fold<Map<String, int>>({}, (map, item) {
      map[item.name] = (map[item.name] ?? 0) + 1;
      return map;
    });
    return itemsWithQuantity;
  }

  int getQuantityForItem(MenuItem item) {
    var currentState = state as OrderIdle;
    return currentState.selectedItems.where((i) => i.name == item.name).length;
  }

  getTotalPrice() {
    var currentState = state as OrderIdle;
    final total = currentState.selectedItems
        .fold<double>(0, (sum, item) => sum + item.price);
    return total;
  }

  submitOrder(int tableNumber) async {
    var currentState = state as OrderIdle;
    try {
      var orderNumber = await _orderService.submitOrder(
          currentState.selectedItems, tableNumber);
      emit(OrderSuccess(orderNumber: orderNumber.toString()));
    } catch (e) {
      emit(OrderFailure(error: e.toString()));
    }
  }
}
