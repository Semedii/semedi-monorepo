import 'package:flutter_bloc/flutter_bloc.dart';

part 'password_state.dart';

class PasswordCubit extends Cubit<PasswordState> {
  PasswordCubit() : super(PasswordInitial());

  onCurrentPasswordFieldChanged(String? currentPassword) {
    var currentState = state as PasswordInitial;
    emit(currentState.copyWith(currentPassword: currentPassword));
  }

  onNewPasswordFieldChanged(String? newPassword) {
    var currentState = state as PasswordInitial;
    emit(currentState.copyWith(newPassword: newPassword));
  }

  onConfirmNewPasswordFieldChanged(String? confirmNewPassword) {
    var currentState = state as PasswordInitial;
    emit(currentState.copyWith(confirmNewPassword: confirmNewPassword));
  }

  onSubmit() {
    var currentState = state as PasswordInitial;
    print(
        "adsfasf ${currentState.currentPassword}, new ${currentState.newPassword}, con ${currentState.confirmNewPassword}");
  }
}
