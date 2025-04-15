part of 'menu_cubit.dart';

sealed class MenuState {}

final class MenuInitial extends MenuState {}

final class MenuLoading extends MenuState {}

final class MenuLoaded extends MenuState {
  final List<MenuItem> menuList;

  MenuLoaded({required this.menuList});
}
