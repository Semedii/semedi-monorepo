import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/authentication/auth_provider.dart';
import 'package:semedi_pos/service/auth_service.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService;
  final AuthProvider _authProvider;
  LoginCubit(this._authProvider, this._authService) : super(LoginInitial());

  void onEmailChanged(String? email) {
    var currentState = state as LoginInitial;
    emit(currentState.copyWith(email: email));
  }

  void onPasswordChanged(String? password) {
    var currentState = state as LoginInitial;
    emit(currentState.copyWith(password: password));
  }

  void onLogin() async {
    var currentState = state as LoginInitial;

    emit(LoginLoading());
    try {
      String? token = await _authService.login(
        currentState.email!,
        currentState.password!,
      );

      if (token != null) {
        await _authProvider.login(token);
        emit(LoginSuccess());
      } else {
        emit(LoginFailure(message: "Login failed"));
        emit(LoginInitial());
      }
    } catch (e) {
      if (e is! StateError) {
        _authService.logout();
        emit(LoginFailure(message: e.toString()));
        emit(LoginInitial());
      }
    }
    emit(LoginInitial());
  }
}
