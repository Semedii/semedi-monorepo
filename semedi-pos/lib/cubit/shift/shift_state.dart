part of 'shift_cubit.dart';

sealed class ShiftState {}

final class ShiftInitial extends ShiftState {}

final class ShiftLoading extends ShiftState {}

final class ShiftLoaded extends ShiftState {
  final Shift? currentShift;
  final List<Shift> shiftHistory;

  ShiftLoaded({
    this.currentShift,
    required this.shiftHistory,
  });
}

final class ShiftFailure extends ShiftState {
  final String message;

  ShiftFailure(this.message);
}
