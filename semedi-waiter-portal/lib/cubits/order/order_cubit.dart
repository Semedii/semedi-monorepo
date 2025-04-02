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
          tableNumber: tableNumber,
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

  void updateMenuItemAvailability(String itemName, bool isAvailable) {
    var currentState = state as OrderInitial;
    final updatedItems = currentState.allMenuItems.map((item) {
      if (item.name == itemName) {
        return MenuItem(
          name: item.name,
          price: item.price,
          isAvailable: isAvailable,
          searchKeywords: item.searchKeywords,
        );
      }
      return item;
    }).toList();

    emit(currentState.copyWith(
      allMenuItems: updatedItems,
      filteredMenuItems: updatedItems.where((item) {
        return item.name
                .toLowerCase()
                .contains(currentState.searchQuery.toLowerCase()) ||
            item.searchKeywords.any((k) => k
                .toLowerCase()
                .contains(currentState.searchQuery.toLowerCase()));
      }).toList(),
    ));
  }

  Future<void> submitOrder() async {
    var currentState = state as OrderInitial;

    emit(currentState.copyWith(status: OrderStatusEnum.preparing));

    if (currentState.selectedItems.isEmpty) {
      throw Exception('Please select at least one item');
    }

    // Here you would typically call your repository/API
    // await _orderRepository.submitOrder(state.tableNumber, state.selectedItems);
  }
}
