import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_state.dart';

class WaiterSettingsCubit extends Cubit<WaiterSettingsState> {
  WaiterSettingsCubit() : super(WaiterSettingsInitial());

  void initPage() {
    emit(WaiterSettingsLoaded());
  }

  void onToggleVibration(bool value) {
    final current = state as WaiterSettingsLoaded;
    emit(current.copyWith(vibrationEnabled: value));
  }

  void onToggleScreen(bool value) {
    final current = state as WaiterSettingsLoaded;
    emit(current.copyWith(keepScreenOn: value));
  }

  void onSetTableView(String view) {
    final current = state as WaiterSettingsLoaded;
    emit(current.copyWith(defaultTableView: view));
  }
}
