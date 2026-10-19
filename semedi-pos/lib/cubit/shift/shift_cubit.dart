import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/shift.dart';
import 'package:semedi_pos/service/shift_service.dart';

part 'shift_state.dart';

class ShiftCubit extends Cubit<ShiftState> {
  final ShiftService _shiftService;

  ShiftCubit(this._shiftService) : super(ShiftInitial());

  initPage() async {
    emit(ShiftLoading());
    try {
      final Shift? currentShift = await _shiftService.getCurrentShift();
      final List<Shift> shiftHistory = await _shiftService.getShiftHistory();
      emit(ShiftLoaded(currentShift: currentShift, shiftHistory: shiftHistory));
    } catch (e) {
      emit(ShiftFailure(e.toString()));
    }
  }

  onOpenShift(String cashierName, double openingFloat) async {
    emit(ShiftLoading());
    try {
      await _shiftService.openShift(
        cashierName: cashierName,
        openingFloat: openingFloat,
      );
    } catch (e) {
      emit(ShiftFailure(e.toString()));
    }
    initPage();
  }

  onCloseShift(double closingFloat) async {
    final currentState = state as ShiftLoaded;
    if (currentState.currentShift == null) return;
    emit(ShiftLoading());
    try {
      await _shiftService.closeShift(
        shiftId: currentState.currentShift!.id,
        closingFloat: closingFloat,
      );
    } catch (e) {
      emit(ShiftFailure(e.toString()));
    }
    initPage();
  }
}
