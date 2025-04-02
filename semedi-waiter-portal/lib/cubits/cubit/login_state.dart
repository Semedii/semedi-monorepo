part of 'login_cubit.dart';

sealed class LoginState {}

final class LoginInitial extends LoginState {
  final String? email;
  final String? password;
  final bool isPasswordObscure;

  LoginInitial({this.email, this.password, this.isPasswordObscure = true});

  LoginInitial copyWith({
    String? email,
    String? password,
    bool? isPasswordObscure,
  }) {
    return LoginInitial(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordObscure: isPasswordObscure ?? this.isPasswordObscure,
    );
  }
}
