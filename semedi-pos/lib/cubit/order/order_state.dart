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
  final int? exchangeRate;
  final int lowStockCount;
  final Map<int, String> tableNotes;

  OrderLoaded({
    required this.activeOrders,
    required this.paidOrders,
    required this.unPaidOrders,
    required this.totalRevenue,
    required this.restaurant,
    required this.tableNumbers,
    this.exchangeRate,
    this.lowStockCount = 0,
    this.tableNotes = const {},
  });

  OrderLoaded copyWith({
    List<OrderModel>? activeOrders,
    List<OrderModel>? paidOrders,
    List<OrderModel>? unPaidOrders,
    double? totalRevenue,
    Map<int, String>? tableNotes,
  }) {
    return OrderLoaded(
      activeOrders: activeOrders ?? this.activeOrders,
      paidOrders: paidOrders ?? this.paidOrders,
      unPaidOrders: unPaidOrders ?? this.unPaidOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      restaurant: restaurant,
      tableNumbers: tableNumbers,
      exchangeRate: exchangeRate,
      lowStockCount: lowStockCount,
      tableNotes: tableNotes ?? this.tableNotes,
    );
  }
}

final class OrderLoading extends OrderState {}

final class OrderLoadingFailed extends OrderState {
  final String message;

  OrderLoadingFailed({required this.message});
}
