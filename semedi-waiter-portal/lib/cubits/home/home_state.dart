part of 'home_cubit.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<OrderModel> orders;
  final int totalTables;

  const HomeLoaded(this.orders, this.totalTables);
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);
}
