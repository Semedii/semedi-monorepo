import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/purchase_order.dart';
import 'package:semedi_pos/models/purchase_order_item.dart';
import 'package:semedi_pos/models/supplier.dart';
import 'package:semedi_pos/service/purchase_order_service.dart';
import 'package:semedi_pos/service/supplier_service.dart';

part 'purchase_order_state.dart';

class PurchaseOrderCubit extends Cubit<PurchaseOrderState> {
  final PurchaseOrderService _purchaseOrderService;
  final SupplierService _supplierService;

  PurchaseOrderCubit(this._purchaseOrderService, this._supplierService)
      : super(PurchaseOrderInitial());

  initPage() async {
    emit(PurchaseOrderLoading());
    try {
      final List<PurchaseOrder> orders =
          await _purchaseOrderService.getPurchaseOrders();
      final List<Supplier> suppliers = await _supplierService.getSuppliers();
      emit(PurchaseOrderLoaded(orders: orders, suppliers: suppliers));
    } catch (e) {
      emit(PurchaseOrderFailure(e.toString()));
    }
  }

  onCreateOrder({
    required String supplierId,
    String? note,
    required List<PurchaseOrderItem> items,
  }) async {
    emit(PurchaseOrderLoading());
    try {
      await _purchaseOrderService.createPurchaseOrder(
        supplierId: supplierId,
        note: note,
        items: items,
      );
    } catch (e) {
      emit(PurchaseOrderFailure(e.toString()));
    }
    initPage();
  }

  onMarkOrdered(PurchaseOrder order) async {
    emit(PurchaseOrderLoading());
    try {
      await _purchaseOrderService.updateOrderStatus(order.id, 'ordered');
    } catch (e) {
      emit(PurchaseOrderFailure(e.toString()));
    }
    initPage();
  }

  onMarkReceived(PurchaseOrder order) async {
    emit(PurchaseOrderLoading());
    try {
      await _purchaseOrderService.updateOrderStatus(order.id, 'received');
    } catch (e) {
      emit(PurchaseOrderFailure(e.toString()));
    }
    initPage();
  }

  onReceiveItem({
    required PurchaseOrder order,
    required PurchaseOrderItem item,
    required double receivedQuantity,
  }) async {
    emit(PurchaseOrderLoading());
    try {
      await _purchaseOrderService.receiveOrderItem(
        orderId: order.id,
        item: item,
        receivedQuantity: receivedQuantity,
      );
    } catch (e) {
      emit(PurchaseOrderFailure(e.toString()));
    }
    initPage();
  }

  onDeleteOrder(PurchaseOrder order) async {
    emit(PurchaseOrderLoading());
    try {
      await _purchaseOrderService.deletePurchaseOrder(order.id);
    } catch (e) {
      emit(PurchaseOrderFailure(e.toString()));
    }
    initPage();
  }
}
