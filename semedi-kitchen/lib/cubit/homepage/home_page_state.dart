part of 'home_page_cubit.dart';

sealed class HomePageState {}

final class HomePageInitial extends HomePageState {}

final class HomepageLoading extends HomePageState {}

final class HomepageLoaded extends HomePageState {
  final List<OrderModel> activeOrders;
  final String restaurantName;

  HomepageLoaded({required this.activeOrders, required this.restaurantName});
}
