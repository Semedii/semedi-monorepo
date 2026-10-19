part of 'inventory_cubit.dart';

sealed class InventoryState {}

final class InventoryInitial extends InventoryState {}

final class InventoryLoading extends InventoryState {}

final class InventoryLoaded extends InventoryState {
  final List<InventoryItem> items;

  InventoryLoaded({required this.items});
}

final class InventoryFailure extends InventoryState {
  final String message;

  InventoryFailure(this.message);
}
