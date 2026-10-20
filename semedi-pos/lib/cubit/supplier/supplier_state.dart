part of 'supplier_cubit.dart';

sealed class SupplierState {}

final class SupplierInitial extends SupplierState {}

final class SupplierLoading extends SupplierState {}

final class SupplierLoaded extends SupplierState {
  final List<Supplier> suppliers;

  SupplierLoaded({required this.suppliers});
}

final class SupplierFailure extends SupplierState {
  final String message;

  SupplierFailure(this.message);
}
