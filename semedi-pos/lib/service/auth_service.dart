import 'package:semedi_pos/service/secure_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SecureStorageService _secureStorage = SecureStorageService();
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response.session?.accessToken;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<User?> getCurrentUser() async {
    return _supabase.auth.currentUser;
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    await _secureStorage.clear();
  }
}
