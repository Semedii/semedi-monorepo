part of 'login_cubit.dart';

sealed class LoginState {}

final class LoginInitial extends LoginState {
  final String? email;
  final String? password;

  LoginInitial({this.email, this.password});

  LoginInitial copyWith({String? email, String? password}) {
    return LoginInitial(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {}

final class LoginFailure extends LoginState {
  final String message;

  LoginFailure({required this.message});
}
