import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/models/order_model.dart';
import 'package:semedi/services/order_service.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final OrderService _orderService;

  HistoryCubit(this._orderService) : super(HistoryInitial());

  Future<void> initPage() async {
    emit(HistoryLoading());
    try {
      final orders = await _orderService.getOrderHistory();
      emit(HistoryLoaded(orders));
    } catch (e) {
      emit(HistoryFailure(e.toString()));
    }
  }
}
