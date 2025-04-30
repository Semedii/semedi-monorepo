part of 'sales_history_cubit.dart';

sealed class SalesHistoryState {}

final class SalesHistoryInitial extends SalesHistoryState {}

final class SalesHistoryLoading extends SalesHistoryState {}

final class SalesHistoryLoaded extends SalesHistoryState {
  final List<DailySummary> dailySummaryList;

  SalesHistoryLoaded({required this.dailySummaryList});
}
