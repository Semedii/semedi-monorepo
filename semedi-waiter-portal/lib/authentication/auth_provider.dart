import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/service_locator.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = getIt<AuthService>();

  bool get isAuthenticated => _authService.isAuthenticated;

  void refreshState() => notifyListeners();
}
