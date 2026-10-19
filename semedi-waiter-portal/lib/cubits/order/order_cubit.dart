import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/models/menu.dart';
import 'package:semedi/models/customer.dart';
import 'package:semedi/models/menu_modifier.dart';
import 'package:semedi/models/order_item.dart';
import 'package:semedi/services/customer_service.dart';
import 'package:semedi/services/menu_service.dart';
import 'package:semedi/services/modifier_service.dart';
import 'package:semedi/services/order_service.dart';
import 'package:semedi/utils/order_status_enum.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderService _orderService = OrderService();
  final MenuService _menuService = MenuService();

  final ModifierService _modifierService = ModifierService();
  final CustomerService _customerService = CustomerService();

  OrderCubit() : super(OrderInitial());

  void initPage() async {
    List<MenuItem> allMenuItems = await _menuService.getMenu();
    List<MenuModifier> modifiers = [];
    try {
      modifiers = await _modifierService.getModifierList();
    } catch (e) {
      //todo
    }
    emit(
      OrderIdle(
        orderItems: [],
        allMenuItems: allMenuItems,
        filteredMenuItems: allMenuItems,
        availableModifiers: modifiers,
      ),
    );
  }

  void onSearchCustomer(String phone) async {
    var currentState = state as OrderIdle;
    try {
      final customer = await _customerService.searchCustomer(phone);
      emit(currentState.copyWith(selectedCustomer: customer));
    } catch (e) {
      //todo
    }
  }

  void onClearCustomer() {
    var currentState = state as OrderIdle;
    emit(currentState.copyWith(clearCustomer: true));
  }

  void onCreateCustomer(String name, String phone) async {
    try {
      await _customerService.addCustomer(name, phone);
      onSearchCustomer(phone);
    } catch (e) {
      //todo
    }
  }

  void onToggleModifier(String itemName, String modifierName) {
    var currentState = state as OrderIdle;
    final updated = Map<String, List<String>>.from(currentState.itemModifiers);
    final current = List<String>.from(updated[itemName] ?? []);
    if (current.contains(modifierName)) {
      current.remove(modifierName);
    } else {
      current.add(modifierName);
    }
    updated[itemName] = current;
    emit(currentState.copyWith(itemModifiers: updated));
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

  submitOrder(String tableId) async {
    var currentState = state as OrderIdle;
    emit(OrderLoading());
    try {
      String orderNumber = await _orderService.addNewOrder(
        currentState.orderItems,
        tableId,
        currentState.isKitchenRequired,
      );
      emit(OrderSuccess(orderNumber: orderNumber));
    } catch (e) {
      emit(OrderFailure(error: e.toString()));
      emit(currentState);
    }
  }
}
