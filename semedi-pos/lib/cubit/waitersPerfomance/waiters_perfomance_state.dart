part of 'waiters_perfomance_cubit.dart';

sealed class WaitersPerfomanceState {}

final class WaitersPerfomanceInitial extends WaitersPerfomanceState {}

final class WaitersPerfomanceLoading extends WaitersPerfomanceState {}

final class WaitersPerfomanceLoaded extends WaitersPerfomanceState {
  final List<WaitersPerfomance> waitersPerfomance;
  final String restaurant;

  WaitersPerfomanceLoaded(
      {required this.waitersPerfomance, required this.restaurant});
}

final class ClearDataSuccess extends WaitersPerfomanceState {}

final class ClearDataFailure extends WaitersPerfomanceState {
  final String message;

  ClearDataFailure({required this.message});
}
