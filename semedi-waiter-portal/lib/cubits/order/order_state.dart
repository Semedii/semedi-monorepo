part of 'order_cubit.dart';

sealed class OrderState {}

final class OrderInitial extends OrderState {
  final List<MenuItem> selectedItems;
  final List<MenuItem> allMenuItems;
  final List<MenuItem> filteredMenuItems;
  final OrderStatusEnum status;
  final String searchQuery;
  final String? note;

  OrderInitial({
    required this.selectedItems,
    required this.allMenuItems,
    required this.filteredMenuItems,
    this.status = OrderStatusEnum.ordered,
    this.searchQuery = '',
    this.note,
  });

  OrderInitial copyWith({
    List<MenuItem>? selectedItems,
    List<MenuItem>? filteredMenuItems,
    OrderStatusEnum? status,
    String? searchQuery,
    String? note,
  }) {
    return OrderInitial(
      selectedItems: selectedItems ?? this.selectedItems,
      allMenuItems: allMenuItems,
      filteredMenuItems: filteredMenuItems ?? this.filteredMenuItems,
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
      note: note ?? this.note,
    );
  }
}

class OrderSuccess extends OrderState {}
