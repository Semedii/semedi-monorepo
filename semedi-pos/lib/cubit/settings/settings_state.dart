part of 'settings_cubit.dart';

sealed class SettingsState {}

final class SettingsInitial extends SettingsState {}

final class SettingsLoaded extends SettingsState {
  final bool thermalPrinterEnabled;
  final bool soundNotificationsEnabled;
  final bool autoRefreshEnabled;
  final String restaurantName;
  final String appVersion;

  SettingsLoaded({
    this.thermalPrinterEnabled = true,
    this.soundNotificationsEnabled = true,
    this.autoRefreshEnabled = true,
    this.restaurantName = '',
    this.appVersion = '1.0.0',
  });

  SettingsLoaded copyWith({
    bool? thermalPrinterEnabled,
    bool? soundNotificationsEnabled,
    bool? autoRefreshEnabled,
    String? restaurantName,
  }) {
    return SettingsLoaded(
      thermalPrinterEnabled:
          thermalPrinterEnabled ?? this.thermalPrinterEnabled,
      soundNotificationsEnabled:
          soundNotificationsEnabled ?? this.soundNotificationsEnabled,
      autoRefreshEnabled: autoRefreshEnabled ?? this.autoRefreshEnabled,
      restaurantName: restaurantName ?? this.restaurantName,
      appVersion: appVersion,
    );
  }
}
