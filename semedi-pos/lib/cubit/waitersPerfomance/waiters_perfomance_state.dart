part of 'waiters_perfomance_cubit.dart';

sealed class WaitersPerfomanceState {}

final class WaitersPerfomanceInitial extends WaitersPerfomanceState {}

final class WaitersPerfomanceLoading extends WaitersPerfomanceState {}

final class WaitersPerfomanceLoaded extends WaitersPerfomanceState {
  final List<WaitersPerfomance> waitersPerfomance;

  WaitersPerfomanceLoaded({required this.waitersPerfomance});
}
