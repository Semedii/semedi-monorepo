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

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginFailure extends LoginState {
  final String message;

  LoginFailure({required this.message});
}
