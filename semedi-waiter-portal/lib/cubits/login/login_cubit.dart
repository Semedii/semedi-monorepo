import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/services/auth_service.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService;
  LoginCubit(this._authService) : super(LoginInitial());

  void onEmailChanged(String? email) {
    var currentState = state as LoginInitial;
    emit(currentState.copyWith(email: email));
  }

  void onPasswordChanged(String? password) {
    var currentState = state as LoginInitial;
    emit(currentState.copyWith(password: password));
  }

  void onLoginPressed() {
    var currentState = state as LoginInitial;
    _authService.signInWithEmailAndPassword(
      currentState.email!,
      currentState.password!,
    );
  }
}
