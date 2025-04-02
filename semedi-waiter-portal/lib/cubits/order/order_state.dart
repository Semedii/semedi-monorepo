part of 'order_cubit.dart';

sealed class OrderState {}

final class OrderInitial extends OrderState {
  final List<MenuItem> selectedItems;
  final List<MenuItem> allMenuItems;
  final List<MenuItem> filteredMenuItems;
  final int tableNumber;
  final OrderStatusEnum status;
  final String searchQuery;
  final String? note;

  OrderInitial({
    required this.selectedItems,
    required this.allMenuItems,
    required this.filteredMenuItems,
    required this.tableNumber,
    this.status = OrderStatusEnum.preparing,
    this.searchQuery = '',
    this.note,
  });

  OrderInitial copyWith({
    List<MenuItem>? selectedItems,
    List<MenuItem>? allMenuItems,
    List<MenuItem>? filteredMenuItems,
    int? tableNumber,
    OrderStatusEnum? status,
    String? searchQuery,
    String? note,
  }) {
    return OrderInitial(
      selectedItems: selectedItems ?? this.selectedItems,
      allMenuItems: allMenuItems ?? this.allMenuItems,
      filteredMenuItems: filteredMenuItems ?? this.filteredMenuItems,
      tableNumber: tableNumber ?? this.tableNumber,
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
      note: note ?? this.note,
    );
  }
}
