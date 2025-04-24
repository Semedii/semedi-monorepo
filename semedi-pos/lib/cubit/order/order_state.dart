part of 'order_cubit.dart';

sealed class OrderState {}

final class OrderInitial extends OrderState {}

final class OrderLoaded extends OrderState {
  final List<OrderModel>? activeOrders;
  final List<OrderModel>? paidOrders;
  final List<OrderModel>? unPaidOrders;
  final double totalRevenue;
  final String restaurant;
  final int tableNumbers;

  OrderLoaded({
    required this.activeOrders,
    required this.paidOrders,
    required this.unPaidOrders,
    required this.totalRevenue,
    required this.restaurant,
    required this.tableNumbers,
  });

  OrderLoaded copyWith({
    List<OrderModel>? activeOrders,
    List<OrderModel>? paidOrders,
    List<OrderModel>? unPaidOrders,
    double? totalRevenue,
  }) {
    return OrderLoaded(
      activeOrders: activeOrders ?? this.activeOrders,
      paidOrders: paidOrders ?? this.paidOrders,
      unPaidOrders: unPaidOrders ?? this.unPaidOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      restaurant: restaurant,
      tableNumbers: tableNumbers,
    );
  }
}

final class OrderLoading extends OrderState {}

final class OrderLoadingFailed extends OrderState {
  final String message;

  OrderLoadingFailed({required this.message});
}
