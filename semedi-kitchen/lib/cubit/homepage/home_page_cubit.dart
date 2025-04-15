import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_kitchen/models/order.dart';
import 'package:semedi_kitchen/services/order_service.dart';
import 'package:semedi_kitchen/services/secure_storage_service.dart';
import 'package:semedi_kitchen/utils/order_status_enum.dart';

part 'home_page_state.dart';

class HomePageCubit extends Cubit<HomePageState> {
  final OrderService _orderService;
  final SecureStorageService _secureStorageService;
  HomePageCubit(this._orderService, this._secureStorageService)
      : super(HomePageInitial());
  StreamSubscription<List<OrderModel>>? _ordersSubscription;
  void listenToOrders() async {
    emit(HomepageLoading());

    _ordersSubscription?.cancel();
    String? restaurant = await _secureStorageService.read('restaurant');
    _ordersSubscription = _orderService.getActiveOrders(restaurant!).listen(
      (orders) {
        emit(HomepageLoaded(
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
    var currentState = state as HomepageLoaded;
    int number = currentState.activeOrders
        .where((order) => order.status == OrderStatusEnum.ordered)
        .length;
    return number;
  }

  getPreparingOrdersNumber() {
    var currentState = state as HomepageLoaded;
    int number = currentState.activeOrders
        .where((order) => order.status == OrderStatusEnum.preparing)
        .length;
    return number;
  }

  getReadyOrdersNumber() {
    var currentState = state as HomepageLoaded;
    int number = currentState.activeOrders
        .where((order) => order.status == OrderStatusEnum.ready)
        .length;
    return number;
  }
}
