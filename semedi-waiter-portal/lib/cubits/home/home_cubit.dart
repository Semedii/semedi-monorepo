import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/models/dining_tables.dart';
import 'package:semedi/models/order_model.dart';
import 'package:semedi/services/dining_tables_service.dart';
import 'package:semedi/services/order_service.dart';
import 'package:semedi/services/secure_storage_service.dart';
import 'package:semedi/utils/order_status_enum.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final OrderService _orderService;
  final SecureStorageService secureStorageService;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;
  StreamSubscription<List<DiningTables>>? _tablesSubscription;

  HomeCubit(OrderService orderService, this.secureStorageService)
      : _orderService = orderService,
        super(const HomeInitial());
  final AudioPlayer _audioPlayer = AudioPlayer();

  void listenToOrders() async {
    emit(const HomeLoading());

    final restaurantName = await secureStorageService.read('restaurant_name');

    List<OrderModel> previousOrders = [];
    List<DiningTables> previousDiningTables = [];

    _ordersSubscription?.cancel();
    _tablesSubscription?.cancel();

    _tablesSubscription = DiningTablesService().getDiningTablesStream().listen(
      (tables) {
        previousDiningTables = tables;
        emit(HomeLoaded(previousOrders, tables, restaurantName));
      },
      onError: (error) {
        emit(HomeError('Failed to load dining tables: $error'));
      },
    );
    _ordersSubscription = _orderService.getAllOrders().listen(
      (orders) async {
        if (_shouldPlaySound(previousOrders, orders)) {
          _playNotificationSound();
        }

        previousOrders = orders;
        emit(HomeLoaded(orders, previousDiningTables, restaurantName));
      },
      onError: (error) {
        emit(HomeError('Failed to load orders: $error'));
      },
    );
  }

  bool _shouldPlaySound(List<OrderModel> prev, List<OrderModel> current) {
    final prevReadyIds = prev
        .where((order) => order.status == OrderStatusEnum.ready.name)
        .map((order) => order.id)
        .toList();

    return current.any((order) =>
        order.status == OrderStatusEnum.ready.name &&
        !prevReadyIds.contains(order.id));
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
    return currentState.orders
        .where(
            (order) => order.status.toLowerCase() != OrderStatusEnum.paid.name)
        .any((order) => order.tableNumber == tableNumber);
  }

  List<OrderModel> getActiveOrders() {
    final currentState = state as HomeLoaded;
    final activeOrders = currentState.orders
        .where((order) => order.status != OrderStatusEnum.paid.name)
        .toList();
    return activeOrders;
  }

  List<OrderModel> getPaidOrders() {
    final currentState = state as HomeLoaded;
    final activeOrders = currentState.orders
        .where((order) => order.status == OrderStatusEnum.paid.name)
        .toList();

    return activeOrders;
  }

  onDeliverOrder(String? orderNumber) {
    if (orderNumber != null) {
      _orderService.updateOrderStatus(
        orderNumber: orderNumber,
        newStatus: OrderStatusEnum.served,
      );
      listenToOrders();
    }
  }

  onRequestPay(String? orderId, String namePhone) {
    if (orderId != null) {
      _orderService.requestPay(
        orderId: orderId,
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
