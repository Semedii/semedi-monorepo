import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:semedi/models/order.dart';
import 'package:semedi/services/app_session_service.dart';
import 'package:semedi/services/menu_service.dart';
import 'package:semedi/services/order_service.dart';
import 'package:semedi/services/secure_storage_service.dart';
import 'package:semedi/utils/order_status_enum.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final OrderService _orderService;
  final SecureStorageService _secureStorageService;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  HomeCubit(OrderService orderService, this._secureStorageService)
      : _orderService = orderService,
        super(const HomeInitial());
  final AudioPlayer _audioPlayer = AudioPlayer();
  void listenToOrders() async {
    emit(const HomeLoading());
    final session = GetIt.instance<AppSessionService>();
    final int totalTables = await MenuService().getTotalTableNumber();

    List<OrderModel> previousOrders = [];

    _ordersSubscription?.cancel();

    _ordersSubscription = _orderService.getAllOrders().listen(
      (orders) async {
        if (_shouldPlaySound(previousOrders, orders)) {
          _playNotificationSound();
        }

        previousOrders = orders;
        if (!session.hasInitializedAfterLogin) {
          await Future.delayed(const Duration(seconds: 3));
          session.hasInitializedAfterLogin = true;
        }
        String? restaurantName = await _secureStorageService.read('restaurant');
        emit(HomeLoaded(orders, totalTables, restaurantName));
      },
      onError: (error) {
        emit(HomeError('Failed to load orders: $error'));
      },
    );
  }

  bool _shouldPlaySound(List<OrderModel> prev, List<OrderModel> current) {
    final prevReadyIds = prev
        .where((order) => order.status == OrderStatusEnum.ready)
        .map((order) => order.orderNumber)
        .toList();

    return current.any((order) =>
        order.status == OrderStatusEnum.ready &&
        !prevReadyIds.contains(order.orderNumber));
  }

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  bool isTableOccupied(int tableNumber) {
    if (state is! HomeLoaded) return false;
    final currentState = state as HomeLoaded;
    return currentState.orders.any((order) => order.tableNumber == tableNumber);
  }

  List<OrderModel> getActiveOrders() {
    final currentState = state as HomeLoaded;
    final activeOrders = currentState.orders
        .where((order) => order.status != OrderStatusEnum.paid)
        .toList();
    return activeOrders;
  }

  List<OrderModel> getPaidOrders() {
    final currentState = state as HomeLoaded;
    final activeOrders = currentState.orders
        .where((order) => order.status == OrderStatusEnum.paid)
        .toList();

    return activeOrders;
  }

  onDeliverOrder(String? orderNumber) {
    if (orderNumber != null) {
      _orderService.updateOrderStatus(
        orderNumber: orderNumber,
        newStatus: OrderStatusEnum.delivered,
      );
      listenToOrders();
    }
  }

  onRequestPay(String? orderNumber, String namePhone) {
    if (orderNumber != null) {
      _orderService.requestPay(
        orderNumber: orderNumber,
        namePhone: namePhone,
      );
      listenToOrders();
    }
  }

  onCancelOrder(String? orderNumber) {
    if (orderNumber != null) {
      _orderService.cancelOrder(
        orderNumber,
      );
      listenToOrders();
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
