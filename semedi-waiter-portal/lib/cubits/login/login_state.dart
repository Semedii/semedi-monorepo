part of 'login_cubit.dart';

sealed class LoginState {}

final class LoginInitial extends LoginState {
  final String? phone;
  final String? password;
  final bool isPasswordObscure;

  LoginInitial({this.phone, this.password, this.isPasswordObscure = true});

  LoginInitial copyWith({
    String? phone,
    String? password,
    bool? isPasswordObscure,
  }) {
    return LoginInitial(
      phone: phone ?? this.phone,
      password: password ?? this.password,
      isPasswordObscure: isPasswordObscure ?? this.isPasswordObscure,
    );
  }
}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  LoginSuccess();
}

class LoginFailure extends LoginState {
  final String message;

  LoginFailure({required this.message});
}
