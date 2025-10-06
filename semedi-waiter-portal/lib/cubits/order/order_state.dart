part of 'order_cubit.dart';

sealed class OrderState {}

final class OrderInitial extends OrderState {}

final class OrderIdle extends OrderState {
  final List<OrderItem> orderItems;
  final List<MenuItem> allMenuItems;
  final List<MenuItem> filteredMenuItems;
  final OrderStatusEnum status;
  final String searchQuery;
  final String? note;
  final bool isKitchenRequired;

  OrderIdle({
    required this.orderItems,
    required this.allMenuItems,
    required this.filteredMenuItems,
    this.status = OrderStatusEnum.ordered,
    this.searchQuery = '',
    this.note,
    this.isKitchenRequired = true,
  });

  OrderIdle copyWith({
    List<OrderItem>? orderItems,
    List<MenuItem>? filteredMenuItems,
    OrderStatusEnum? status,
    String? searchQuery,
    String? note,
    bool? isKitchenRequired,
  }) {
    return OrderIdle(
      orderItems: orderItems ?? this.orderItems,
      allMenuItems: allMenuItems,
      filteredMenuItems: filteredMenuItems ?? this.filteredMenuItems,
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
      note: note ?? this.note,
      isKitchenRequired: isKitchenRequired ?? this.isKitchenRequired,
    );
  }
}

class OrderLoading extends OrderState {}

class OrderSuccess extends OrderState {
  final String orderNumber;

  OrderSuccess({required this.orderNumber});
}

class OrderFailure extends OrderState {
  final String error;

  OrderFailure({required this.error});
}
