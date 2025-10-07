import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
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
}
