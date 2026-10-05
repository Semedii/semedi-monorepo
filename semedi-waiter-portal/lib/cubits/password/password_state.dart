part of 'password_cubit.dart';

sealed class PasswordState {}

final class PasswordInitial extends PasswordState {
  final String? currentPassword;
  final String? newPassword;
  final String? confirmNewPassword;

  PasswordInitial({
    this.currentPassword,
    this.newPassword,
    this.confirmNewPassword,
  });

  PasswordInitial copyWith(
      {String? currentPassword,
      String? newPassword,
      String? confirmNewPassword}) {
    return PasswordInitial(
        currentPassword: currentPassword ?? this.currentPassword,
        newPassword: newPassword ?? this.newPassword,
        confirmNewPassword: confirmNewPassword ?? this.confirmNewPassword);
  }
}

final class PasswordChangeSuccess extends PasswordState {}

final class PasswordChangeError extends PasswordState {
  final String error;

  PasswordChangeError({required this.error});
}
