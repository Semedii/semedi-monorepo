part of 'take_order_cubit.dart';

sealed class TakeOrderState {}

class TakeOrderStateInitial extends TakeOrderState {
  final String? customerName;
  final String? note;
  final String? searchQuery;
  final List<MenuItem>? menuList;
  final Map<MenuItem, int>? selectedItems;
  final List<MenuItem>? filteredMenuItems;

  TakeOrderStateInitial(
      {this.customerName,
      this.menuList,
      this.note,
      this.searchQuery,
      this.selectedItems,
      this.filteredMenuItems});

  TakeOrderStateInitial copyWith({
    String? customerName,
    String? note,
    List<MenuItem>? menuList,
    String? searchQuery,
    Map<MenuItem, int>? selectedItems,
    List<MenuItem>? filteredMenuItems,
  }) {
    return TakeOrderStateInitial(
      customerName: customerName ?? this.customerName,
      note: note ?? this.note,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedItems: selectedItems ?? this.selectedItems,
      filteredMenuItems: filteredMenuItems ?? this.filteredMenuItems,
      menuList: menuList ?? this.menuList,
    );
  }
}

class TakeOrderStateSuccess extends TakeOrderState {}

class TakeOrderStateFailure extends TakeOrderState {
  final String message;

  TakeOrderStateFailure({required this.message});
}
