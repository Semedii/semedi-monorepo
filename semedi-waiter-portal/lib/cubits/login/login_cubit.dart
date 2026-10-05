import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/authentication/auth_provider.dart';
import 'package:semedi/services/auth_service.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService;
  final AuthProvider _authProvider;
  LoginCubit(this._authService, this._authProvider) : super(LoginInitial());

  void onPhoneChanged(String? phone) {
    var currentState = state as LoginInitial;
    emit(currentState.copyWith(phone: phone));
  }

  void onPasswordChanged(String? password) {
    var currentState = state as LoginInitial;
    emit(currentState.copyWith(password: password));
  }

  void onLoginPressed() async {
    var currentState = state as LoginInitial;
    emit(LoginLoading());
    try {
      await _authService.login(
        currentState.phone!,
        currentState.password!,
      );
      _authProvider.refreshState();
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginFailure(message: e.toString()));
      emit(LoginInitial());
    }
  }
}
