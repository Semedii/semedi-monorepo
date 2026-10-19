part of 'settings_cubit.dart';

sealed class WaiterSettingsState {}

final class WaiterSettingsInitial extends WaiterSettingsState {}

final class WaiterSettingsLoaded extends WaiterSettingsState {
  final bool vibrationEnabled;
  final bool keepScreenOn;
  final String defaultTableView;

  WaiterSettingsLoaded({
    this.vibrationEnabled = true,
    this.keepScreenOn = true,
    this.defaultTableView = 'grid',
  });

  WaiterSettingsLoaded copyWith({
    bool? vibrationEnabled,
    bool? keepScreenOn,
    String? defaultTableView,
  }) {
    return WaiterSettingsLoaded(
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      defaultTableView: defaultTableView ?? this.defaultTableView,
    );
  }
}
