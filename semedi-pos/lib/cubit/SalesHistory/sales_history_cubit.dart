import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/daily_summary.dart';
import 'package:semedi_pos/service/order_service.dart';

part 'sales_history_state.dart';

class SalesHistoryCubit extends Cubit<SalesHistoryState> {
  final OrderService orderService;
  SalesHistoryCubit(this.orderService) : super(SalesHistoryInitial());

  initPage() async {
    emit(SalesHistoryLoading());
    List<DailySummary> dailySummaryList = await orderService.getSalesHistory();
    emit(SalesHistoryLoaded(dailySummaryList: dailySummaryList));
  }
}
