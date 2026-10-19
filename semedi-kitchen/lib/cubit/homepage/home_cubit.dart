import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_kitchen/models/order.dart';
import 'package:semedi_kitchen/models/order_timer.dart';
import 'package:semedi_kitchen/services/order_service.dart';
import 'package:semedi_kitchen/services/secure_storage_service.dart';
import 'package:semedi_kitchen/utils/order_status_enum.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final OrderService _orderService;
  final SecureStorageService _secureStorageService;
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<List<OrderModel>>? _ordersSubscription;
  List<OrderModel> _previousOrders = [];

  Map<String, OrderTimer> _orderTimers = {};

  HomeCubit(this._orderService, this._secureStorageService)
      : super(HomeInitial());

  void listenToOrders() async {
    emit(HomeLoading());

    final restaurantData =
        await Supabase.instance.client.from('restaurants').select('name');

    _ordersSubscription?.cancel();

    _ordersSubscription = _orderService.getActiveOrders().listen(
      (orders) async {
        if (_shouldPlaySound(_previousOrders, orders)) {
          await _playNotificationSound();
        }

        _previousOrders = orders;

        for (final order in orders) {
          if (!_orderTimers.containsKey(order.id)) {
            _orderTimers[order.id] =
                OrderTimer(orderId: order.id, startedAt: order.createdAt);
          }
        }
        _orderTimers.removeWhere(
            (id, _) => !orders.any((o) => o.id == id));

        final sorted = List<OrderModel>.from(orders)
          ..sort((a, b) {
            final timerA = _orderTimers[a.id];
            final timerB = _orderTimers[b.id];
            final urgentA = timerA?.isUrgent ?? false;
            final urgentB = timerB?.isUrgent ?? false;
            if (urgentA && !urgentB) return -1;
            if (!urgentA && urgentB) return 1;
            return 0;
          });

        emit(HomeLoaded(
          activeOrders: sorted,
          restaurantName: (restaurantData.first['name'] as String),
          orderTimers: Map.from(_orderTimers),
        ));
      },
      onError: (error) {
        throw Exception(error);
      },
    );
  }

  bool _shouldPlaySound(List<OrderModel> prev, List<OrderModel> current) {
    final prevOrderedIds = prev
        .where((order) =>
            order.status.toLowerCase() ==
            OrderStatusEnum.pending.name.toLowerCase())
        .map((order) => order.id)
        .toList();

    return current.any((order) =>
        order.status == OrderStatusEnum.pending.name &&
        !prevOrderedIds.contains(order.id));
  }

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  onMarkComplete(String orderId) async {
    try {
      await _orderService.changeOrderStatus(
        orderNumber: orderId,
        status: OrderStatusEnum.ready,
      );
    } catch (e) {
      throw Exception(e);
    }
    listenToOrders();
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
        .where((order) => order.status == OrderStatusEnum.pending.name)
        .length;
    return number;
  }

  getPreparingOrdersNumber() {
    var currentState = state as HomeLoaded;
    int number = currentState.activeOrders
        .where((order) => order.status == OrderStatusEnum.pending.name)
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

  int getActiveOrdersCount() {
    return (state as HomeLoaded).activeOrders.length;
  }

  int getUrgentCount() {
    var currentState = state as HomeLoaded;
    return currentState.orderTimers.values
        .where((timer) => timer.isUrgent)
        .length;
  }

  double getAvgWaitMinutes() {
    var currentState = state as HomeLoaded;
    if (currentState.orderTimers.isEmpty) return 0;
    final total = currentState.orderTimers.values
        .fold<int>(0, (sum, t) => sum + t.elapsedMinutes);
    return total / currentState.orderTimers.length;
  }
}
