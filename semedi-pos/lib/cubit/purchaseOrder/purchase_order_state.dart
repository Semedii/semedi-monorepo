part of 'purchase_order_cubit.dart';

sealed class PurchaseOrderState {}

final class PurchaseOrderInitial extends PurchaseOrderState {}

final class PurchaseOrderLoading extends PurchaseOrderState {}

final class PurchaseOrderLoaded extends PurchaseOrderState {
  final List<PurchaseOrder> orders;
  final List<Supplier> suppliers;

  PurchaseOrderLoaded({required this.orders, required this.suppliers});
}

final class PurchaseOrderFailure extends PurchaseOrderState {
  final String message;

  PurchaseOrderFailure(this.message);
}
