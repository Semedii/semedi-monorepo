import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/reservation.dart';
import 'package:semedi_pos/service/reservation_service.dart';

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

  onAddReservation({
    required String guestName,
    required String phone,
    required int guestCount,
    required int tableNumber,
    required DateTime reservedAt,
    String? note,
  }) async {
    emit(ReservationLoading());
    try {
      final reservation = Reservation(
        id: '',
        guestName: guestName,
        phone: phone,
        guestCount: guestCount,
        tableNumber: tableNumber,
        reservedAt: reservedAt,
        note: note,
      );
      await _reservationService.addReservation(reservation);
    } catch (e) {
      emit(ReservationFailure(e.toString()));
    }
    initPage();
  }

  onSeatGuest(Reservation reservation) async {
    emit(ReservationLoading());
    try {
      await _reservationService.updateReservationStatus(reservation.id, 'seated');
    } catch (e) {
      emit(ReservationFailure(e.toString()));
    }
    initPage();
  }

  onCancelReservation(Reservation reservation) async {
    emit(ReservationLoading());
    try {
      await _reservationService.updateReservationStatus(reservation.id, 'cancelled');
    } catch (e) {
      emit(ReservationFailure(e.toString()));
    }
    initPage();
  }

  onDeleteReservation(Reservation reservation) async {
    emit(ReservationLoading());
    try {
      await _reservationService.deleteReservation(reservation.id);
    } catch (e) {
      emit(ReservationFailure(e.toString()));
    }
    initPage();
  }
}
