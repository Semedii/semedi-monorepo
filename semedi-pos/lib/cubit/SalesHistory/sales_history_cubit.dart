import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/daily_summary.dart';
import 'package:semedi_pos/service/order_service.dart';

part 'sales_history_state.dart';

class SalesHistoryCubit extends Cubit<SalesHistoryState> {
  final OrderService orderService;
  SalesHistoryCubit(this.orderService) : super(SalesHistoryInitial());

  initPage() async {
    emit(SalesHistoryLoading());
    final dailySummaryList = await orderService.getSalesHistory();
    emit(SalesHistoryLoaded(
      dailySummaryList: dailySummaryList,
      filteredList: dailySummaryList,
    ));
  }

  onFilterByMonth(String month) {
    if (state is! SalesHistoryLoaded) return;
    final current = state as SalesHistoryLoaded;
    final filtered = current.dailySummaryList
        .where((s) => s.date.contains(month))
        .toList();
    emit(SalesHistoryLoaded(
      dailySummaryList: current.dailySummaryList,
      filteredList: _applySort(filtered, current.sort),
      selectedMonth: month,
      sort: current.sort,
    ));
  }

  onClearFilter() {
    if (state is! SalesHistoryLoaded) return;
    final current = state as SalesHistoryLoaded;
    emit(SalesHistoryLoaded(
      dailySummaryList: current.dailySummaryList,
      filteredList: _applySort(current.dailySummaryList, current.sort),
      selectedMonth: null,
      sort: current.sort,
    ));
  }

  onSortChanged(SalesSort sort) {
    if (state is! SalesHistoryLoaded) return;
    final current = state as SalesHistoryLoaded;
    emit(SalesHistoryLoaded(
      dailySummaryList: current.dailySummaryList,
      filteredList: _applySort(current.filteredList, sort),
      selectedMonth: current.selectedMonth,
      sort: sort,
    ));
  }

  List<DailySummary> _applySort(List<DailySummary> list, SalesSort sort) {
    final sorted = List<DailySummary>.from(list);
    switch (sort) {
      case SalesSort.dateDesc:
        sorted.sort((a, b) => b.date.compareTo(a.date));
      case SalesSort.dateAsc:
        sorted.sort((a, b) => a.date.compareTo(b.date));
      case SalesSort.revenueDesc:
        sorted.sort((a, b) => b.totalSales.compareTo(a.totalSales));
      case SalesSort.revenueAsc:
        sorted.sort((a, b) => a.totalSales.compareTo(b.totalSales));
    }
    return sorted;
  }
}
