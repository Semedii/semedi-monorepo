import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/menu.dart';
import 'package:semedi_pos/models/order.dart';
import 'package:semedi_pos/service/management_service.dart';
import 'package:semedi_pos/service/order_service.dart';
import 'package:semedi_pos/utils/order_status_enum.dart';
part 'take_order_state.dart';

class TakeOrderCubit extends Cubit<TakeOrderState> {
  TakeOrderCubit() : super(TakeOrderStateInitial());

  initPage() async {
    List<MenuItem>? menuList = await ManagementService().getMenuList();
    emit(TakeOrderStateInitial(menuList: menuList));
  }

  void onCustomerNameChange(String name) {
    var currentState = state as TakeOrderStateInitial;
    emit(currentState.copyWith(customerName: name));
  }

  void onNoteChange(String note) {
    var currentState = state as TakeOrderStateInitial;
    emit(currentState.copyWith(note: note));
  }

  void onSearchQueryChange(String query) {
    var currentState = state as TakeOrderStateInitial;
    final filtered = currentState.menuList!
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    emit(
        currentState.copyWith(searchQuery: query, filteredMenuItems: filtered));
  }

  void onAddItem(MenuItem item) {
    var currentState = state as TakeOrderStateInitial;
    Map<MenuItem, int>? updated =
        Map<MenuItem, int>.from(currentState.selectedItems ?? {});
    updated[item] = (updated[item] ?? 0) + 1;
    emit(currentState.copyWith(selectedItems: updated));
  }

  void onRemoveItem(MenuItem item) {
    var currentState = state as TakeOrderStateInitial;
    final items = Map<MenuItem, int>.from(currentState.selectedItems ?? {});

    if (items.containsKey(item)) {
      items[item] = (items[item]! - 1);
      if (items[item] == 0) items.remove(item);
    }

    emit(currentState.copyWith(selectedItems: items));
  }

  getTotalPrice() {
    var currentState = state as TakeOrderStateInitial;
    final total = currentState.selectedItems?.entries
        .fold<double>(0, (sum, item) => sum + item.key.price);
    return total;
  }

  onSubmit(int? tableNumber) async {
    final currentState = state as TakeOrderStateInitial;

    final selectedItems = currentState.selectedItems ?? {};
    final menuList = currentState.menuList ?? [];

    final itemsWithQuantity = {
      for (var entry in selectedItems.entries)
        if (entry.key.name.trim().isNotEmpty) entry.key.name: entry.value,
    };

    final itemsWithPrices = {
      for (var item in menuList)
        if (item.name.trim().isNotEmpty) item.name: item.price,
    };

    final newOrder = OrderModel(
      customerName: currentState.customerName,
      tableNumber: tableNumber,
      itemsWithQuantity: itemsWithQuantity,
      itemsWithPrices: itemsWithPrices,
      status: OrderStatusEnum.ordered,
      total: getTotalPrice(),
      waiter: "Cashier",
    );
    try {
      await OrderService().addTakeOrder(newOrder);
      emit(TakeOrderStateSuccess());
    } catch (e) {
      emit(TakeOrderStateFailure(message: e.toString()));
    }
  }
}
