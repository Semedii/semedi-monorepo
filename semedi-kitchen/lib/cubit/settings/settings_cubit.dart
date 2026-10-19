import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_state.dart';

class KitchenSettingsCubit extends Cubit<KitchenSettingsState> {
  KitchenSettingsCubit() : super(KitchenSettingsInitial());

  void initPage() {
    emit(KitchenSettingsLoaded());
  }

  void onToggleDisplayCompleted(bool value) {
    final current = state as KitchenSettingsLoaded;
    emit(current.copyWith(displayCompletedOrders: value));
  }

  void onToggleSoundAlerts(bool value) {
    final current = state as KitchenSettingsLoaded;
    emit(current.copyWith(soundAlerts: value));
  }

  void onSetAutoMarkMinutes(int minutes) {
    final current = state as KitchenSettingsLoaded;
    emit(current.copyWith(autoMarkDoneAfterMinutes: minutes));
  }
}
