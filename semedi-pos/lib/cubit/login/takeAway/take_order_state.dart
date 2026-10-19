part of 'take_order_cubit.dart';

sealed class TakeOrderState {}

class TakeOrderStateInitial extends TakeOrderState {
  final String? customerName;
  final String? note;
  final String? searchQuery;
  final List<MenuItem>? menuList;
  final Map<MenuItem, int>? selectedItems;
  final List<MenuItem>? filteredMenuItems;
  final List<MenuModifier>? availableModifiers;
  final Map<MenuItem, List<String>>? itemModifiers;
  final String? selectedCategory;
  final List<String>? availableCategories;

  TakeOrderStateInitial({
    this.customerName,
    this.menuList,
    this.note,
    this.searchQuery,
    this.selectedItems,
    this.filteredMenuItems,
    this.availableModifiers,
    this.itemModifiers,
    this.selectedCategory,
    this.availableCategories,
  });

  TakeOrderStateInitial copyWith({
    String? customerName,
    String? note,
    List<MenuItem>? menuList,
    String? searchQuery,
    Map<MenuItem, int>? selectedItems,
    List<MenuItem>? filteredMenuItems,
    List<MenuModifier>? availableModifiers,
    Map<MenuItem, List<String>>? itemModifiers,
    String? selectedCategory,
    List<String>? availableCategories,
  }) {
    return TakeOrderStateInitial(
      customerName: customerName ?? this.customerName,
      note: note ?? this.note,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedItems: selectedItems ?? this.selectedItems,
      filteredMenuItems: filteredMenuItems ?? this.filteredMenuItems,
      menuList: menuList ?? this.menuList,
      availableModifiers: availableModifiers ?? this.availableModifiers,
      itemModifiers: itemModifiers ?? this.itemModifiers,
      selectedCategory: selectedCategory,
      availableCategories: availableCategories ?? this.availableCategories,
    );
  }
}

class TakeOrderStateSuccess extends TakeOrderState {}

class TakeOrderStateFailure extends TakeOrderState {
  final String message;

  TakeOrderStateFailure({required this.message});
}
