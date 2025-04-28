import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/order.dart';
import 'package:semedi_pos/service/management_service.dart';
import 'package:semedi_pos/service/order_service.dart';
import 'package:semedi_pos/service/secure_storage_service%20copy.dart';
import 'package:semedi_pos/utils/order_status_enum.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderService _orderService;
  final ManagementService managementService;
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  OrderCubit({
    required OrderService orderService,
    required this.managementService,
  })  : _orderService = orderService,
        super(OrderInitial());

  void listenToOrders() async {
    emit(OrderLoading());

    final List<OrderModel> paidOrders =
        await _orderService.getOrdersByStatus(OrderStatusEnum.paid) ?? [];

    final List<OrderModel> unPaidOrders =
        await _orderService.getOrdersByStatus(OrderStatusEnum.unpaid) ?? [];

    double totalRevenue = 0.0;
    final int? exchangeRate = await managementService.getExchangeRate();

    for (var order in paidOrders) {
      totalRevenue += order.total;
    }
    for (var order in unPaidOrders) {
      totalRevenue += order.total;
    }

    _ordersSubscription?.cancel();
    String restaurant = await _getRestaurantName()!;
    int tableNumber = await ManagementService().getTotalTableNumber();
    _ordersSubscription = _orderService.getActiveOrders(restaurant).listen(
      (orders) async {
        final List<OrderModel> payPendingOrders =
            await _orderService.getOrdersByStatus(OrderStatusEnum.payPending) ??
                [];
        if (payPendingOrders.isNotEmpty) {
          await _playNotificationSound();
        } else {
          _audioPlayer.setReleaseMode(ReleaseMode.stop);
        }
        emit(OrderLoaded(
          activeOrders: orders,
          paidOrders: paidOrders,
          totalRevenue: totalRevenue,
          unPaidOrders: unPaidOrders,
          restaurant: restaurant,
          tableNumbers: tableNumber,
          exchangeRate: exchangeRate,
        ));
      },
      onError: (error) {
        emit(OrderLoadingFailed(message: 'Failed to load orders: $error'));
      },
    );
  }

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/notification.mp4'));
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void changeOrderStatus(String orderNumber, OrderStatusEnum status) async {
    try {
      await _orderService.changeOrderStatus(
          orderNumber: orderNumber, status: status);
      listenToOrders();
    } catch (e) {
      emit(OrderLoadingFailed(
          message: 'Failed to pay this order please try again: $e'));
      listenToOrders();
    }
  }

  getTakeAwayOrders() {
    var currentState = state as OrderLoaded;
    List<OrderModel>? takeAwayOrders = currentState.activeOrders
        ?.where((order) => order.customerName != null)
        .toList();
    return takeAwayOrders;
  }

  onCancelOrder(String? orderNumber) {
    if (orderNumber != null) {
      _orderService.cancelOrder(
        orderNumber,
      );
    }
  }

  onSetExchangeRate(String? exchangeRate) async {
    try {
      if (exchangeRate != null) {
        int exchangeRateInt = int.parse(exchangeRate);
        await managementService.setExchangeRate(exchangeRateInt);
      }
    } catch (e) {
      throw Exception(e);
    }
    listenToOrders();
  }

  _getRestaurantName() async {
    String? restaurant = await SecureStorageService().read('restaurant');
    return restaurant;
  }

  List<OrderModel>? getTableOrders(int tableNumber) {
    var currentState = state as OrderLoaded;
    List<OrderModel>? orders = currentState.activeOrders
        ?.where((order) => order.tableNumber == tableNumber)
        .toList();

    return orders;
  }

  bool isTablePayPending(int tableNumber) {
    var currentState = state as OrderLoaded;
    bool isPayPending = currentState.activeOrders
            ?.where((order) => order.tableNumber == tableNumber)
            .any((order) => order.status == OrderStatusEnum.payPending) ??
        false;
    return isPayPending;
  }

  bool isTableVacant(int tableNumber) {
    final currentState = state as OrderLoaded;
    final activeOrders = currentState.activeOrders ?? [];
    final hasOrder =
        activeOrders.any((order) => order.tableNumber == tableNumber);

    return !hasOrder;
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
