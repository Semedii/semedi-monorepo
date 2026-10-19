import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/inventory_item.dart';
import 'package:semedi_pos/service/inventory_service.dart';

part 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  final InventoryService _inventoryService;

  InventoryCubit(this._inventoryService) : super(InventoryInitial());

  initPage() async {
    emit(InventoryLoading());
    try {
      final List<InventoryItem> items =
          await _inventoryService.getInventoryList();
      emit(InventoryLoaded(items: items));
    } catch (e) {
      emit(InventoryFailure(e.toString()));
    }
  }

  onAddItem(InventoryItem item) async {
    emit(InventoryLoading());
    try {
      await _inventoryService.addInventoryItem(item);
    } catch (e) {
      emit(InventoryFailure(e.toString()));
    }
    initPage();
  }

  onDeleteItem(InventoryItem item) async {
    emit(InventoryLoading());
    try {
      await _inventoryService.deleteInventoryItem(item);
    } catch (e) {
      emit(InventoryFailure(e.toString()));
    }
    initPage();
  }

  onEditItem(InventoryItem newItem, InventoryItem oldItem) async {
    emit(InventoryLoading());
    try {
      await _inventoryService.updateInventoryItem(
          oldItem: oldItem, newItem: newItem);
    } catch (e) {
      emit(InventoryFailure(e.toString()));
    }
    initPage();
  }

  onAdjustQuantity(InventoryItem item, double delta) async {
    emit(InventoryLoading());
    try {
      await _inventoryService.adjustQuantity(
          item.name, item.quantity, delta);
    } catch (e) {
      emit(InventoryFailure(e.toString()));
    }
    initPage();
  }
}
