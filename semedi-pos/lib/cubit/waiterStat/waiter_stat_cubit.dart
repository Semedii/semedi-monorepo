import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/order.dart';
import 'package:semedi_pos/service/order_service.dart';

part 'waiter_stat_state.dart';

class WaiterStatCubit extends Cubit<WaiterStatState> {
  final OrderService _orderService;
  WaiterStatCubit(this._orderService) : super(WaiterStatInitial());

  initPage(String waiterName) async {
    emit(WaiterStatLoading());
    List<OrderModel>? waitersOrders =
        await _orderService.getOrdersByWaiter(waiterName);
    emit(WaiterStatLoaded(waitersOrders: waitersOrders));
  }
}
