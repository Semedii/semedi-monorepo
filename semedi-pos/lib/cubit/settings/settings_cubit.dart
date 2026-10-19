import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial());

  void initPage() {
    emit(SettingsLoaded());
  }

  void onTogglePrinter(bool value) {
    final current = state as SettingsLoaded;
    emit(current.copyWith(thermalPrinterEnabled: value));
  }

  void onToggleSound(bool value) {
    final current = state as SettingsLoaded;
    emit(current.copyWith(soundNotificationsEnabled: value));
  }

  void onToggleAutoRefresh(bool value) {
    final current = state as SettingsLoaded;
    emit(current.copyWith(autoRefreshEnabled: value));
  }
}
