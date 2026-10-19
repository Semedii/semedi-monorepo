import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/discount.dart';
import 'package:semedi_pos/models/menu.dart';
import 'package:semedi_pos/models/menu_modifier.dart';
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
    final List<MenuModifier>? modifierList =
        await _managementService.getModifierList();
    final List<Discount>? discountList =
        await _managementService.getDiscountList();

    emit(ManagementLoaded(
      menuList: menuList ?? [],
      waiterList: waiterList,
      totalTableNumber: totalTableNumber,
      modifierList: modifierList ?? [],
      discountList: discountList ?? [],
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

  onAddModifier(MenuModifier modifier) async {
    emit(ManagementLoading());
    try {
      await _managementService.addModifier(modifier);
    } catch (e) {
      emit(ManagementFailure(e.toString()));
    }
    initPage();
  }

  onEditModifier(MenuModifier newModifier, MenuModifier oldModifier) async {
    emit(ManagementLoading());
    try {
      await _managementService.updateModifier(
          oldModifier: oldModifier, newModifier: newModifier);
    } catch (e) {
      emit(ManagementFailure(e.toString()));
    }
    initPage();
  }

  onDeleteModifier(MenuModifier modifier) async {
    emit(ManagementLoading());
    try {
      await _managementService.deleteModifier(modifier);
    } catch (e) {
      emit(ManagementFailure(e.toString()));
    }
    initPage();
  }

  onAddDiscount(Discount discount) async {
    emit(ManagementLoading());
    try {
      await _managementService.addDiscount(discount);
    } catch (e) {
      emit(ManagementFailure(e.toString()));
    }
    initPage();
  }

  onEditDiscount(Discount newDiscount, Discount oldDiscount) async {
    emit(ManagementLoading());
    try {
      await _managementService.updateDiscount(
          oldDiscount: oldDiscount, newDiscount: newDiscount);
    } catch (e) {
      emit(ManagementFailure(e.toString()));
    }
    initPage();
  }

  onDeleteDiscount(Discount discount) async {
    emit(ManagementLoading());
    try {
      await _managementService.deleteDiscount(discount);
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
