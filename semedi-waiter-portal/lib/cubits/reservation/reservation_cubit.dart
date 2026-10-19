import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/models/reservation.dart';
import 'package:semedi/services/reservation_service.dart';

part 'reservation_state.dart';

class ReservationCubit extends Cubit<ReservationState> {
  final ReservationService _reservationService;

  ReservationCubit(this._reservationService) : super(ReservationInitial());

  initPage() async {
    emit(ReservationLoading());
    try {
      final reservations = await _reservationService.getTodayReservations();
      emit(ReservationLoaded(reservations: reservations));
    } catch (e) {
      emit(ReservationFailure(e.toString()));
    }
  }

  onSeatGuest(Reservation reservation) async {
    emit(ReservationLoading());
    try {
      await _reservationService.updateReservationStatus(
          reservation.id, 'seated');
    } catch (e) {
      emit(ReservationFailure(e.toString()));
    }
    initPage();
  }

  onCancelReservation(Reservation reservation) async {
    emit(ReservationLoading());
    try {
      await _reservationService.updateReservationStatus(
          reservation.id, 'cancelled');
    } catch (e) {
      emit(ReservationFailure(e.toString()));
    }
    initPage();
  }
}
