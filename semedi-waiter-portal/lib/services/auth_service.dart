import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:semedi/models/waiter.dart';
import 'package:semedi/services/secure_storage_service.dart';
import 'package:semedi/services/service_locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final secureStorageService = getIt<SecureStorageService>();
  final _supabase = Supabase.instance.client;

  signInWithEmailAndPassword(String email, String password) async {
    try {
      final response = await _supabase.auth
          .signInWithPassword(email: email, password: password);

      final String? token = response.session?.accessToken;

      if (token != null) {
        return token;
      } else {
        throw Exception("Failed to get token");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> logout() async {
    await secureStorageService.clear();
  }
}
