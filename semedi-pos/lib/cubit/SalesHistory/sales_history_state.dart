part of 'sales_history_cubit.dart';

sealed class SalesHistoryState {}

final class SalesHistoryInitial extends SalesHistoryState {}

final class SalesHistoryLoading extends SalesHistoryState {}

final class SalesHistoryLoaded extends SalesHistoryState {
  final List<DailySummary> dailySummaryList;
  final List<DailySummary> filteredList;
  final String? selectedMonth;
  final SalesSort sort;

  SalesHistoryLoaded({
    required this.dailySummaryList,
    required this.filteredList,
    this.selectedMonth,
    this.sort = SalesSort.dateDesc,
  });
}

enum SalesSort { dateDesc, dateAsc, revenueDesc, revenueAsc }
