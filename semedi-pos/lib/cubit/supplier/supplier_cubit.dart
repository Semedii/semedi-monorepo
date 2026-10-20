import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/supplier.dart';
import 'package:semedi_pos/service/supplier_service.dart';

part 'supplier_state.dart';

class SupplierCubit extends Cubit<SupplierState> {
  final SupplierService _supplierService;

  SupplierCubit(this._supplierService) : super(SupplierInitial());

  initPage() async {
    emit(SupplierLoading());
    try {
      final List<Supplier> suppliers = await _supplierService.getSuppliers();
      emit(SupplierLoaded(suppliers: suppliers));
    } catch (e) {
      emit(SupplierFailure(e.toString()));
    }
  }

  onAddSupplier(Supplier supplier) async {
    emit(SupplierLoading());
    try {
      await _supplierService.addSupplier(supplier);
    } catch (e) {
      emit(SupplierFailure(e.toString()));
    }
    initPage();
  }

  onEditSupplier(Supplier newSupplier, Supplier oldSupplier) async {
    emit(SupplierLoading());
    try {
      await _supplierService.updateSupplier(
          oldSupplier: oldSupplier, newSupplier: newSupplier);
    } catch (e) {
      emit(SupplierFailure(e.toString()));
    }
    initPage();
  }

  onDeleteSupplier(Supplier supplier) async {
    emit(SupplierLoading());
    try {
      await _supplierService.deleteSupplier(supplier);
    } catch (e) {
      emit(SupplierFailure(e.toString()));
    }
    initPage();
  }
}
