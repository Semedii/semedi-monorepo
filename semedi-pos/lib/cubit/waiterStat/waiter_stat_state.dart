part of 'waiter_stat_cubit.dart';

sealed class WaiterStatState {}

final class WaiterStatInitial extends WaiterStatState {}

final class WaiterStatLoading extends WaiterStatState {}

final class WaiterStatLoaded extends WaiterStatState {
  final List<OrderModel>? waitersOrders;

  WaiterStatLoaded({required this.waitersOrders});
}
