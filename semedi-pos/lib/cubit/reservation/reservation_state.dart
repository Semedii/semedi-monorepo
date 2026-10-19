part of 'reservation_cubit.dart';

sealed class ReservationState {}

final class ReservationInitial extends ReservationState {}

final class ReservationLoading extends ReservationState {}

final class ReservationLoaded extends ReservationState {
  final List<Reservation> reservations;

  ReservationLoaded({required this.reservations});
}

final class ReservationFailure extends ReservationState {
  final String message;

  ReservationFailure(this.message);
}
