import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/models/order.dart';
import 'package:semedi/services/order_service.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final OrderService _orderService;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  HomeCubit({required OrderService orderService})
      : _orderService = orderService,
        super(const HomeInitial());

  void listenToOrders() {
    emit(const HomeLoading());

    _ordersSubscription?.cancel();

    _ordersSubscription = _orderService.getActiveOrders().listen(
      (orders) {
        emit(HomeLoaded(orders));
      },
      onError: (error) {
        emit(HomeError('Failed to load orders: $error'));
      },
    );
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
