import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_kitchen/models/kitchen_user.dart';
import 'package:semedi_kitchen/services/auth_service.dart';
import 'package:semedi_kitchen/services/secure_storage_service.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService;
  final SecureStorageService _secureStorageService;
  LoginCubit(
    this._authService,
    this._secureStorageService,
  ) : super(LoginInitial());

  onEmailChanged(String? email) {
    var currentState = state as LoginInitial;
    emit(currentState.copyWith(email: email));
  }

  onPasswordChanged(String? password) {
    var currentState = state as LoginInitial;
    emit(currentState.copyWith(password: password));
  }

  onLogIn() async {
    var currentState = state as LoginInitial;
    emit(LoginLoading());
    try {
      String? token = await _authService.signInWithEmailAndPassword(
        currentState.email!,
        currentState.password!,
      );
      await _authService.getUserFromKitchenList();
      if (token != null) {
        await _secureStorageService.write('auth_token', token);
        emit(LoginSuccess());
      } else {
        emit(LoginFailure(message: "Login failed"));
      }
    } catch (e) {
      if (e is! StateError) {
        _authService.logout();
        emit(LoginFailure(message: e.toString()));
      }
    }
    emit(LoginInitial());
  }
}
