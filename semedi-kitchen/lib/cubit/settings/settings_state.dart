part of 'settings_cubit.dart';

sealed class KitchenSettingsState {}

final class KitchenSettingsInitial extends KitchenSettingsState {}

final class KitchenSettingsLoaded extends KitchenSettingsState {
  final bool displayCompletedOrders;
  final bool soundAlerts;
  final int autoMarkDoneAfterMinutes;

  KitchenSettingsLoaded({
    this.displayCompletedOrders = false,
    this.soundAlerts = true,
    this.autoMarkDoneAfterMinutes = 30,
  });

  KitchenSettingsLoaded copyWith({
    bool? displayCompletedOrders,
    bool? soundAlerts,
    int? autoMarkDoneAfterMinutes,
  }) {
    return KitchenSettingsLoaded(
      displayCompletedOrders:
          displayCompletedOrders ?? this.displayCompletedOrders,
      soundAlerts: soundAlerts ?? this.soundAlerts,
      autoMarkDoneAfterMinutes:
          autoMarkDoneAfterMinutes ?? this.autoMarkDoneAfterMinutes,
    );
  }
}
