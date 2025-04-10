part of 'order_cubit.dart';

sealed class OrderState {}

final class OrderInitial extends OrderState {}

final class OrderLoaded extends OrderState {
  final List<OrderModel>? activeOrders;
  final int? numberOfPaidOrders;
  final double totalRevenue;

  OrderLoaded({
    required this.activeOrders,
    required this.numberOfPaidOrders,
    required this.totalRevenue,
  });

  OrderLoaded copyWith({
    List<OrderModel>? activeOrders,
    int? numberOfPaidOrders,
    double? totalRevenue,
  }) {
    return OrderLoaded(
      activeOrders: activeOrders ?? this.activeOrders,
      numberOfPaidOrders: numberOfPaidOrders ?? this.numberOfPaidOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
    );
  }
}

final class OrderLoading extends OrderState {}

final class OrderLoadingFailed extends OrderState {
  final String message;

  OrderLoadingFailed({required this.message});
}
