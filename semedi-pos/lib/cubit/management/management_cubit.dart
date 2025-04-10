import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/models/menu.dart';
import 'package:semedi_pos/models/waiter.dart';
import 'package:semedi_pos/service/management_service.dart';

part 'management_state.dart';

class ManagementCubit extends Cubit<ManagementState> {
  final ManagementService _managementService;
  ManagementCubit(this._managementService) : super(ManagementInitial());

  initPage() async {
    emit(ManagementLoading());
    final List<MenuItem> menuList = await _managementService.getMenuList();
    final List<Waiter> waiterList = await _managementService.getWaitersList();
    final int totalTableNumber = await _managementService.getTotalTableNumber();

    emit(ManagementLoaded(
      menuList: menuList,
      waiterList: waiterList,
      totalTableNumber: totalTableNumber,
    ));
  }

  onAddMenu(MenuItem newMenu) async {
    emit(ManagementLoading());
    await _managementService.addMenu(newMenu);
    initPage();
  }

  onEditMenu(MenuItem newMenu, MenuItem oldMenu) async {
    emit(ManagementLoading());
    await _managementService.updateMenu(oldItem: oldMenu, newItem: newMenu);
    initPage();
  }

  onDeleteMenu(MenuItem menu) async {
    emit(ManagementLoading());
    await _managementService.deleteMenu(menu);
    initPage();
  }

  onAddTable() async {
    emit(ManagementLoading());
    await _managementService.incrementTotalTables();
    initPage();
  }
}
