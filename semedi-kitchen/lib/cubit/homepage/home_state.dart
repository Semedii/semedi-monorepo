part of 'home_cubit.dart';

sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final List<OrderModel> activeOrders;
  final String restaurantName;
  final Map<String, OrderTimer> orderTimers;
  final String filterStatus;

  HomeLoaded({
    required this.activeOrders,
    required this.restaurantName,
    this.orderTimers = const {},
    this.filterStatus = 'all',
  });

  List<OrderModel> get filteredOrders {
    if (filterStatus == 'all') return activeOrders;
    return activeOrders
        .where((o) => o.status.toLowerCase() == filterStatus.toLowerCase())
        .toList();
  }

  HomeLoaded copyWith({String? filterStatus}) {
    return HomeLoaded(
      activeOrders: activeOrders,
      restaurantName: restaurantName,
      orderTimers: orderTimers,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }
}
