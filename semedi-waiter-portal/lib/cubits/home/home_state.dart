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

  const HomeLoaded(this.orders);
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);
}
