import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/services/auth_service.dart';
import 'package:semedi/services/secure_storage_service.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService;
  final SecureStorageService _secureStorage = SecureStorageService();
  LoginCubit(this._authService) : super(LoginInitial());

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
        await _secureStorage.write('auth_token', token);
        emit(LoginSuccess(token: token));
        emit(LoginInitial());
      } else {
        emit(LoginFailure(message: "Login failed"));
        emit(LoginInitial());
      }
    } catch (e) {
      emit(LoginFailure(message: e.toString()));
      emit(LoginInitial());
    }
  }
}
