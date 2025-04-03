part of 'auth_cubit.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthLoading extends AuthState {}
