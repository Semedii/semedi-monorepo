import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/order.dart';
import 'package:semedi_pos/service/order_service.dart';
import 'package:semedi_pos/service/secure_storage_service%20copy.dart';
import 'package:semedi_pos/utils/order_status_enum.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderService _orderService;
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  OrderCubit({required OrderService orderService})
      : _orderService = orderService,
        super(OrderInitial());

  void listenToOrders() async {
    emit(OrderLoading());

    final List<OrderModel> paidOrders =
        await _orderService.getOrdersByStatus(OrderStatusEnum.paid) ?? [];

    final List<OrderModel> unPaidOrders =
        await _orderService.getOrdersByStatus(OrderStatusEnum.unpaid) ?? [];

    final List<OrderModel> payPendingOrders =
        await _orderService.getOrdersByStatus(OrderStatusEnum.payPending) ?? [];

    // Check for unpaid orders and play sound if any exist
    if (payPendingOrders.isNotEmpty) {
      await _playNotificationSound();
    }

    double totalRevenue = 0.0;

    for (var order in paidOrders) {
      totalRevenue += order.total;
    }
    for (var order in unPaidOrders) {
      totalRevenue += order.total;
    }

    _ordersSubscription?.cancel();
    String restaurant = await _getRestaurantName()!;
    _ordersSubscription = _orderService.getActiveOrders(restaurant).listen(
      (orders) {
        emit(OrderLoaded(
          activeOrders: orders,
          paidOrders: paidOrders,
          totalRevenue: totalRevenue,
          unPaidOrders: unPaidOrders,
          restaurant: restaurant,
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

  onCancelOrder(String? orderNumber) {
    if (orderNumber != null) {
      _orderService.cancelOrder(
        orderNumber,
      );
    }
  }

  _getRestaurantName() async {
    String? restaurant = await SecureStorageService().read('restaurant');
    return restaurant;
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
