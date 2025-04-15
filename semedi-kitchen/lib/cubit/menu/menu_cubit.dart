import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_kitchen/models/menu.dart';
import 'package:semedi_kitchen/services/menu_service.dart';

part 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  final MenuService _menuService;
  MenuCubit(this._menuService) : super(MenuInitial());

  initPage() async {
    emit(MenuLoading());
    final List<MenuItem> menuList = await _menuService.getMenuList();
    emit(MenuLoaded(menuList: menuList));
  }

  onMenuToggle(MenuItem menu) async {
    emit(MenuLoading());
    await _menuService.disableOrEnableMenu(menu: menu);
    initPage();
  }
}
