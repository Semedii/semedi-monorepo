import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/order_model.dart';
import 'package:semedi_pos/service/inventory_service.dart';
import 'package:semedi_pos/service/management_service.dart';
import 'package:semedi_pos/service/order_service.dart';
import 'package:semedi_pos/service/table_note_service.dart';
import 'package:semedi_pos/utils/order_status_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderService _orderService;
  final ManagementService managementService;
  final TableNoteService _tableNoteService = TableNoteService();
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
        await _orderService.getOrdersByStatus('paid') ?? [];

    final List<OrderModel> unPaidOrders =
        await _orderService.getOrdersByStatus('pending') ?? [];

    double totalRevenue = 0.0;
    final int? exchangeRate = await managementService.getExchangeRate();
    final lowStockItems = await InventoryService().getLowStockItems();

    final restaurantData =
        await Supabase.instance.client.from('restaurants').select('name');

    _ordersSubscription?.cancel();
    int tableNumber = await ManagementService().getTotalTableNumber();
    _ordersSubscription = _orderService.getActiveOrders().listen(
      (orders) async {
        final List<OrderModel> payPendingOrders =
            await _orderService.getOrdersByStatus('payPending') ?? [];
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
          //todo
          restaurant: (restaurantData.first['name'] as String),
          tableNumbers: tableNumber,
          exchangeRate: exchangeRate,
          lowStockCount: lowStockItems.length,
          tableNotes: _tableNoteService.notesMap,
        ));
      },
      onError: (error) {
        emit(OrderLoadingFailed(message: 'Failed to load orders: $error'));
      },
    ) as StreamSubscription<List<OrderModel>>?;
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

  void payAll(List<OrderModel> orders) async {
    try {
      for (var order in orders) {
        await _orderService.changeOrderStatus(
            orderNumber: order.id, status: OrderStatusEnum.paid);
      }
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
        //todo
        ?.where((order) => order.tableNumber == null) //todo
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
            .any((order) => order.status == OrderStatusEnum.payPending.name) ??
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

  void onSaveTableNote(int tableNumber, String note) {
    _tableNoteService.saveNote(tableNumber, note);
    final current = state as OrderLoaded;
    emit(current.copyWith(tableNotes: _tableNoteService.notesMap));
  }

  void onDeleteTableNote(int tableNumber) {
    _tableNoteService.deleteNote(tableNumber);
    final current = state as OrderLoaded;
    emit(current.copyWith(tableNotes: _tableNoteService.notesMap));
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
