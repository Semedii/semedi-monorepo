import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/authentication/auth_provider.dart';
import 'package:semedi/services/auth_service.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService;
  final AuthProvider _authProvider;
  LoginCubit(this._authService, this._authProvider) : super(LoginInitial());

  void onEmailChanged(String? email) {
    var currentState = state as LoginInitial;
    emit(currentState.copyWith(email: email));
  }

  void onPasswordChanged(String? password) {
    var currentState = state as LoginInitial;
    emit(currentState.copyWith(password: password));
  }

  void onLoginPressed() async {
    var currentState = state as LoginInitial;
    emit(LoginLoading());
    try {
      String? token = await _authService.signInWithEmailAndPassword(
        currentState.email!,
        currentState.password!,
      );

      if (token != null) {
        _authProvider.login(token);
        emit(LoginSuccess(token: token));
      } else {
        emit(LoginFailure(message: "Login failed"));
        emit(LoginInitial());
      }
    } catch (e) {
      if (e is! StateError) {
        _authProvider.logout();
        emit(LoginFailure(message: e.toString()));
        emit(LoginInitial());
      }
    }
  }
}
