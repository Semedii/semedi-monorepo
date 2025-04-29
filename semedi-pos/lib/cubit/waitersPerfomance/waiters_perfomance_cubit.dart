import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/order.dart';
import 'package:semedi_pos/models/waiters_perfomance.dart';
import 'package:semedi_pos/service/order_service.dart';
import 'package:semedi_pos/service/secure_storage_service.dart';
import 'package:semedi_pos/utils/order_status_enum.dart';

part 'waiters_perfomance_state.dart';

class WaitersPerfomanceCubit extends Cubit<WaitersPerfomanceState> {
  final OrderService _orderService;
  WaitersPerfomanceCubit(this._orderService)
      : super(WaitersPerfomanceInitial());

  initPage() async {
    emit(WaitersPerfomanceLoading());

    List<OrderModel> pastOrders =
        await _orderService.getPaidAndUnpaidOrders() ?? [];

    Map<String, WaitersPerfomance> performanceMap = {};

    for (var order in pastOrders) {
      final waiterName = order.waiter;

      final existingPerformance = performanceMap[waiterName];

      final isPaid = order.status == OrderStatusEnum.paid;

      if (existingPerformance != null) {
        performanceMap[waiterName] = WaitersPerfomance(
          name: waiterName,
          noOfPaidOrders: existingPerformance.noOfPaidOrders + (isPaid ? 1 : 0),
          noOfUnpaidOrders:
              existingPerformance.noOfUnpaidOrders + (isPaid ? 0 : 1),
          unpaidOrdersTotal: existingPerformance.unpaidOrdersTotal +
              (isPaid ? 0 : order.total),
          totalOrders: existingPerformance.totalOrders + 1,
          totalSales: existingPerformance.totalSales + order.total,
        );
      } else {
        performanceMap[waiterName] = WaitersPerfomance(
          name: waiterName,
          noOfPaidOrders: isPaid ? 1 : 0,
          noOfUnpaidOrders: isPaid ? 0 : 1,
          unpaidOrdersTotal: isPaid ? 0 : order.total,
          totalOrders: 1,
          totalSales: order.total,
        );
      }
    }

    final performanceList = performanceMap.values.toList();
    String restaurant = await _getRestaurantName();
    emit(WaitersPerfomanceLoaded(
      waitersPerfomance: performanceList,
      restaurant: restaurant,
    ));
  }

  clearData() async {
    emit(WaitersPerfomanceLoading());
    try {
      await _orderService.clearOrder();
      await _orderService.resetOrderNumber();
      emit(ClearDataSuccess());
      initPage();
    } catch (e) {
      emit(ClearDataFailure(message: e.toString()));
      initPage();
    }
  }

  _getRestaurantName() async {
    String? restaurant = await SecureStorageService().read('restaurant');
    return restaurant;
  }
}
