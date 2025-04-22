import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:semedi_kitchen/models/order.dart';
import 'package:semedi_kitchen/services/app_session_service.dart';
import 'package:semedi_kitchen/services/order_service.dart';
import 'package:semedi_kitchen/services/secure_storage_service.dart';
import 'package:semedi_kitchen/utils/order_status_enum.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final OrderService _orderService;
  final SecureStorageService _secureStorageService;
  HomeCubit(this._orderService, this._secureStorageService)
      : super(HomeInitial());
  StreamSubscription<List<OrderModel>>? _ordersSubscription;
  final session = GetIt.instance<AppSessionService>();
  void listenToOrders() async {
    emit(HomeLoading());

    _ordersSubscription?.cancel();
    if (!session.hasInitializedAfterLogin) {
      await Future.delayed(const Duration(seconds: 3));
      session.hasInitializedAfterLogin = true;
    }
    String? restaurant = await _secureStorageService.read('restaurant');
    _ordersSubscription = _orderService.getActiveOrders(restaurant!).listen(
      (orders) {
        emit(HomeLoaded(
          activeOrders: orders,
          restaurantName: restaurant,
        ));
      },
      onError: (error) {
        throw Exception(error);
      },
    );
  }

  onOrderStatusChange(String orderNumber, OrderStatusEnum status) async {
    try {
      await _orderService.changeOrderStatus(
        orderNumber: orderNumber,
        status: status,
      );
    } catch (e) {
      throw Exception(e);
    }
    listenToOrders();
  }

  onCancelOrder(String orderNumber) async {
    try {
      await _orderService.cancelOrder(orderNumber);
    } catch (e) {
      throw Exception(e);
    }
    listenToOrders();
  }

  getNewOrdersNumber() {
    var currentState = state as HomeLoaded;
    int number = currentState.activeOrders
        .where((order) => order.status == OrderStatusEnum.ordered)
        .length;
    return number;
  }

  getPreparingOrdersNumber() {
    var currentState = state as HomeLoaded;
    int number = currentState.activeOrders
        .where((order) => order.status == OrderStatusEnum.preparing)
        .length;
    return number;
  }

  getReadyOrdersNumber() {
    var currentState = state as HomeLoaded;
    int number = currentState.activeOrders
        .where((order) => order.status == OrderStatusEnum.ready)
        .length;
    return number;
  }
}
