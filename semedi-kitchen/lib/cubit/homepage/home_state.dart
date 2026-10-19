part of 'home_cubit.dart';

sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final List<OrderModel> activeOrders;
  final String restaurantName;
  final Map<String, OrderTimer> orderTimers;

  HomeLoaded({
    required this.activeOrders,
    required this.restaurantName,
    this.orderTimers = const {},
  });
}
