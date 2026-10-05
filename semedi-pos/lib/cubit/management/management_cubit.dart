import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/menu.dart';
import 'package:semedi_pos/models/waiter.dart';
import 'package:semedi_pos/service/management_service.dart';

import 'package:semedi_pos/service/secure_storage_service.dart';

part 'management_state.dart';

class ManagementCubit extends Cubit<ManagementState> {
  final ManagementService _managementService;
  ManagementCubit(this._managementService) : super(ManagementInitial());

  initPage() async {
    emit(ManagementLoading());
    final List<MenuItem>? menuList = await _managementService.getMenuList();
    final List<Waiter> waiterList = await _managementService.getWaitersList();
    final int totalTableNumber = await _managementService.getTotalTableNumber();

    emit(ManagementLoaded(
      menuList: menuList ?? [],
      waiterList: waiterList,
      totalTableNumber: totalTableNumber,
    ));
  }

  onAddMenu(MenuItem newMenu) async {
    emit(ManagementLoading());
    try {
      await _managementService.addMenu(newMenu);
    } catch (e) {
      emit(ManagementFailure(e.toString()));
    }
    initPage();
  }

  onEditMenu(MenuItem newMenu, MenuItem oldMenu) async {
    emit(ManagementLoading());
    try {
      await _managementService.updateMenu(oldItem: oldMenu, newItem: newMenu);
    } catch (e) {
      emit(ManagementFailure(e.toString()));
    }
    initPage();
  }

  onDeleteMenu(MenuItem menu) async {
    emit(ManagementLoading());
    try {
      await _managementService.deleteMenu(menu);
    } catch (e) {
      emit(ManagementFailure(e.toString()));
    }
    initPage();
  }

  onAddTable() async {
    emit(ManagementLoading());
    try {
      await _managementService.incrementTotalTables();
    } catch (e) {
      emit(ManagementFailure(e.toString()));
    }
    initPage();
  }

  onRemoveTable() async {
    emit(ManagementLoading());
    try {
      await _managementService.decrementTotalTables();
    } catch (e) {
      emit(ManagementFailure(e.toString()));
    }
    initPage();
  }

  onAddNewWaiter(String name, String email, String password) async {
    emit(ManagementLoading());
    String? restuarant = await SecureStorageService().read('restaurant');
    Waiter newWaiter = Waiter(
      name: name,
      isDisabled: false,
      email: email,
      restaurant: restuarant!,
    );
    try {
      await _managementService.addNewWaiter(newWaiter, password);
    } catch (e) {
      emit(ManagementFailure(e.toString()));
    }
    initPage();
  }
}
