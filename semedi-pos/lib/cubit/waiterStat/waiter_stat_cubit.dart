import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/order.dart';
import 'package:semedi_pos/service/order_service.dart';
import 'package:semedi_pos/utils/order_status_enum.dart';

part 'waiter_stat_state.dart';

class WaiterStatCubit extends Cubit<WaiterStatState> {
  final OrderService _orderService;
  WaiterStatCubit(this._orderService) : super(WaiterStatInitial());

  initPage(String waiterName) async {
    emit(WaiterStatLoading());
    List<OrderModel>? waitersOrders =
        await _orderService.getOrdersByWaiter(waiterName);
    waitersOrders?.sort((a, b) {
      if (a.status == b.status) {
        return b.timestamp.compareTo(a.timestamp);
      }
      return a.status == OrderStatusEnum.unpaid ? -1 : 1;
    });
    emit(WaiterStatLoaded(waitersOrders: waitersOrders));
  }

  void changeOrderStatus(
      String waitersName, String orderNumber, OrderStatusEnum status) async {
    try {
      await _orderService.changeOrderStatus(
          orderNumber: orderNumber, status: status);
      initPage(waitersName);
    } catch (e) {
      initPage(waitersName);
    }
  }
}
