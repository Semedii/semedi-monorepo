part of 'customer_cubit.dart';

sealed class CustomerState {}

final class CustomerInitial extends CustomerState {}

final class CustomerLoading extends CustomerState {}

final class CustomerLoaded extends CustomerState {
  final List<Customer> customers;
  final List<Customer> filtered;
  final String searchQuery;

  CustomerLoaded({
    required this.customers,
    required this.filtered,
    this.searchQuery = '',
  });
}

final class CustomerFailure extends CustomerState {
  final String message;

  CustomerFailure(this.message);
}
