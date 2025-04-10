part of 'order_cubit.dart';

sealed class OrderState {}

final class OrderInitial extends OrderState {}

final class OrderLoaded extends OrderState {
  final List<OrderModel>? activeOrders;
  final List<OrderModel>? paidOrders;
  final double totalRevenue;

  OrderLoaded({
    required this.activeOrders,
    required this.paidOrders,
    required this.totalRevenue,
  });

  OrderLoaded copyWith({
    List<OrderModel>? activeOrders,
    List<OrderModel>? paidOrders,
    double? totalRevenue,
  }) {
    return OrderLoaded(
      activeOrders: activeOrders ?? this.activeOrders,
      paidOrders: paidOrders ?? this.paidOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
    );
  }
}

final class OrderLoading extends OrderState {}

final class OrderLoadingFailed extends OrderState {
  final String message;

  OrderLoadingFailed({required this.message});
}
