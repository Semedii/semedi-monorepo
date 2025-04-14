part of 'take_away_cubit.dart';

sealed class TakeAwayState {}

class TakeAwayStateInitial extends TakeAwayState {
  final String? customerName;
  final String? note;
  final String? searchQuery;
  final List<MenuItem>? menuList;
  final Map<MenuItem, int>? selectedItems;
  final List<MenuItem>? filteredMenuItems;

  TakeAwayStateInitial(
      {this.customerName,
      this.menuList,
      this.note,
      this.searchQuery,
      this.selectedItems,
      this.filteredMenuItems});

  TakeAwayStateInitial copyWith({
    String? customerName,
    String? note,
    List<MenuItem>? menuList,
    String? searchQuery,
    Map<MenuItem, int>? selectedItems,
    List<MenuItem>? filteredMenuItems,
  }) {
    return TakeAwayStateInitial(
      customerName: customerName ?? this.customerName,
      note: note ?? this.note,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedItems: selectedItems ?? this.selectedItems,
      filteredMenuItems: filteredMenuItems ?? this.filteredMenuItems,
      menuList: menuList ?? this.menuList,
    );
  }
}
