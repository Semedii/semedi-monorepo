part of 'management_cubit.dart';

sealed class ManagementState {}

final class ManagementInitial extends ManagementState {}

final class ManagementLoading extends ManagementState {}

final class ManagementLoaded extends ManagementState {
  final List<MenuItem> menuList;
  final List<Waiter> waiterList;
  final int totalTableNumber;

  ManagementLoaded({
    required this.menuList,
    required this.waiterList,
    required this.totalTableNumber,
  });
}
