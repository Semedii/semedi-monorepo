import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/order.dart';
import 'package:semedi_pos/service/order_service.dart';
import 'package:semedi_pos/utils/order_status_enum.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderService _orderService;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  OrderCubit({required OrderService orderService})
      : _orderService = orderService,
        super(OrderInitial());

  void listenToOrders() async {
    emit(OrderLoading());

    final List<OrderModel> paidOrders =
        await _orderService.getPaidOrders() ?? [];
    double totalRevenue = 0.0;

    for (var e in paidOrders) {
      totalRevenue += e.total;
    }

    _ordersSubscription?.cancel();

    _ordersSubscription = _orderService.getActiveOrders().listen(
      (orders) {
        emit(OrderLoaded(
            activeOrders: orders,
            paidOrders: paidOrders,
            totalRevenue: totalRevenue));
      },
      onError: (error) {
        emit(OrderLoadingFailed(message: 'Failed to load orders: $error'));
      },
    );
  }

  void changeOrderStatus(String orderNumber, OrderStatusEnum status) async {
    try {
      await _orderService.changeOrderStatus(
          orderNumber: orderNumber, status: status);
      listenToOrders();
    } catch (e) {
      emit(OrderLoadingFailed(
          message: 'Failed to pay this order try again: $e'));
      listenToOrders();
    }
  }
}
