import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/services/auth_service.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  void onEmailChanged(String? email) {
    var currentState = state as LoginInitial;
    emit(currentState.copyWith(email: email));
  }

  void onPasswordChanged(String? password) {
    var currentState = state as LoginInitial;
    emit(currentState.copyWith(password: password));
  }

  void onLogin() {
    var currentState = state as LoginInitial;
    AuthService().signInWithEmailAndPassword(
        currentState.email!, currentState.password!);
    print(
        "logging as ${currentState.email} with password of ${currentState.password}");
  }
}
