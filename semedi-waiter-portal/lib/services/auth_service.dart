import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_api_client/my_api_client.dart';

import '../network/dio_client.dart';

class AuthService {
  final DefaultApi _defaultApi;
  final DioClient _dioClient;

  AuthService(this._defaultApi, this._dioClient);

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  String? _token;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  // CALL IN MAIN AFTER LOCATOR
  Future<void> initialize() async {
    _token = await _storage.read(key: _tokenKey);
    if (_token != null) {
      _dioClient.addAuthInterceptor(_token!);
      print('AUTO-AUTH SUCCESS — TOKEN LOADED');
    }
  }

  Future<String> login(String phone, String password) async {
    final credentials = UserLogin(
      // CLEAN CONSTRUCTORS BABY
      phoneNumber: phone,
      password: password,
    );

    try {
      final response =
          await _defaultApi.loginApiAuthLoginPost(userLogin: credentials);

      final token = response.data?.accessToken;

      if (token == null || token.isEmpty) throw Exception('No token returned');

      _token = token;
      await _storage.write(key: _tokenKey, value: _token);
      _dioClient.addAuthInterceptor(_token!);
      print('LOGIN SUCCESS — TOKEN: $_token');

      return _token!;
    } catch (e) {
      print('Login failed: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    await _storage.delete(key: _tokenKey);
    _dioClient.updateToken(null);
    print('LOGOUT SUCCESS — TOKEN WIPED');
  }
}
