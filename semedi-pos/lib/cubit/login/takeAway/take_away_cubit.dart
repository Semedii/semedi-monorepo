import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/menu.dart';
import 'package:semedi_pos/service/management_service.dart';
part 'take_away_state.dart';

class TakeAwayCubit extends Cubit<TakeAwayState> {
  TakeAwayCubit() : super(TakeAwayStateInitial());

  initPage() async {
    List<MenuItem> menuList = await ManagementService().getMenuList();
    emit(TakeAwayStateInitial(menuList: menuList));
  }

  void onCustomerNameChange(String name) {
    var currentState = state as TakeAwayStateInitial;
    emit(currentState.copyWith(customerName: name));
  }

  void onNoteChange(String note) {
    var currentState = state as TakeAwayStateInitial;
    emit(currentState.copyWith(note: note));
  }

  void onSearchQueryChange(String query) {
    var currentState = state as TakeAwayStateInitial;
    final filtered = currentState.menuList!
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    emit(
        currentState.copyWith(searchQuery: query, filteredMenuItems: filtered));
  }

  void onAddItem(MenuItem item) {
    var currentState = state as TakeAwayStateInitial;
    Map<MenuItem, int>? updated =
        Map<MenuItem, int>.from(currentState.selectedItems ?? {});
    updated[item] = (updated[item] ?? 0) + 1;
    emit(currentState.copyWith(selectedItems: updated));
  }

  void onRemoveItem(MenuItem item) {
    var currentState = state as TakeAwayStateInitial;
    final items = Map<MenuItem, int>.from(currentState.selectedItems ?? {});

    if (items.containsKey(item)) {
      items[item] = (items[item]! - 1);
      if (items[item] == 0) items.remove(item);
    }

    emit(currentState.copyWith(selectedItems: items));
  }

  getTotalPrice() {
    var currentState = state as TakeAwayStateInitial;
    final total = currentState.selectedItems?.entries
        .fold<double>(0, (sum, item) => sum + item.key.price);
    return total;
  }

  onSubmit() {
    var currentState = state as TakeAwayStateInitial;
    print(
        "aaa ${currentState.customerName}, ${currentState.note}, ${currentState.selectedItems}, ");
  }
}
