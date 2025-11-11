import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/order.dart';
import 'package:semedi_pos/models/order_model.dart' as order;
import 'package:semedi_pos/models/waiters_perfomance.dart';
import 'package:semedi_pos/service/order_service.dart';
import 'package:semedi_pos/utils/order_status_enum.dart';

part 'waiters_perfomance_state.dart';

class WaitersPerfomanceCubit extends Cubit<WaitersPerfomanceState> {
  final OrderService _orderService;
  WaitersPerfomanceCubit(this._orderService)
      : super(WaitersPerfomanceInitial());

  initPage() async {
    emit(WaitersPerfomanceLoading());

    List<order.OrderModel> pastOrders =
        await _orderService.getPaidAndUnpaidOrders() ?? [];

    Map<String, WaitersPerfomance> performanceMap = {};

    for (var order in pastOrders) {
      final waiterName = order.waiterName;

      final existingPerformance = performanceMap[waiterName];

      final isPaid = order.status == OrderStatusEnum.paid.name;

      if (existingPerformance != null) {
        performanceMap[waiterName] = WaitersPerfomance(
          name: waiterName,
          noOfPaidOrders: existingPerformance.noOfPaidOrders + (isPaid ? 1 : 0),
          noOfUnpaidOrders:
              existingPerformance.noOfUnpaidOrders + (isPaid ? 0 : 1),
          unpaidOrdersTotal: existingPerformance.unpaidOrdersTotal +
              (isPaid ? 0 : order.totalPrice),
          totalOrders: existingPerformance.totalOrders + 1,
          totalSales: existingPerformance.totalSales + order.totalPrice,
        );
      } else {
        performanceMap[waiterName] = WaitersPerfomance(
          name: waiterName,
          noOfPaidOrders: isPaid ? 1 : 0,
          noOfUnpaidOrders: isPaid ? 0 : 1,
          unpaidOrdersTotal: isPaid ? order.totalPrice : 0,
          totalOrders: 1,
          totalSales: order.totalPrice,
        );
      }
    }

    final performanceList = performanceMap.values.toList();

    emit(WaitersPerfomanceLoaded(
      //todo
      waitersPerfomance: performanceList,
      restaurant: 'restaurant',
    ));
  }

//todo
  endDay(Map<String, double> salesData) async {}
}
