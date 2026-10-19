part of 'order_cubit.dart';

sealed class OrderState {}

final class OrderInitial extends OrderState {}

final class OrderIdle extends OrderState {
  final List<OrderItem> orderItems;
  final List<MenuItem> allMenuItems;
  final List<MenuItem> filteredMenuItems;
  final OrderStatusEnum status;
  final String searchQuery;
  final bool isKitchenRequired;
  final bool isExpanded;
  final List<MenuModifier> availableModifiers;
  final Map<String, List<String>> itemModifiers;

  OrderIdle({
    required this.orderItems,
    required this.allMenuItems,
    required this.filteredMenuItems,
    this.status = OrderStatusEnum.pending,
    this.searchQuery = '',
    this.isKitchenRequired = true,
    this.isExpanded = false,
    this.availableModifiers = const [],
    this.itemModifiers = const {},
  });

  OrderIdle copyWith({
    List<OrderItem>? orderItems,
    List<MenuItem>? filteredMenuItems,
    OrderStatusEnum? status,
    String? searchQuery,
    String? note,
    bool? isKitchenRequired,
    bool? isExpanded,
    List<MenuModifier>? availableModifiers,
    Map<String, List<String>>? itemModifiers,
  }) {
    return OrderIdle(
      orderItems: orderItems ?? this.orderItems,
      allMenuItems: allMenuItems,
      filteredMenuItems: filteredMenuItems ?? this.filteredMenuItems,
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
      isKitchenRequired: isKitchenRequired ?? this.isKitchenRequired,
      isExpanded: isExpanded ?? this.isExpanded,
      availableModifiers: availableModifiers ?? this.availableModifiers,
      itemModifiers: itemModifiers ?? this.itemModifiers,
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
