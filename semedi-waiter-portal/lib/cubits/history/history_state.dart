part of 'history_cubit.dart';

sealed class HistoryState {}

final class HistoryInitial extends HistoryState {}

final class HistoryLoading extends HistoryState {}

final class HistoryLoaded extends HistoryState {
  final List<OrderModel> orders;

  HistoryLoaded(this.orders);
}

final class HistoryFailure extends HistoryState {
  final String message;

  HistoryFailure(this.message);
}
