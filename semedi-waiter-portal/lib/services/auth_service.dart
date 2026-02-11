import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  signInWithEmailAndPassword(String email, String password) async {
    // try {
    //   final response = await _supabase.auth
    //       .signInWithPassword(email: email, password: password);
    //   final restaurantData =
    //       await _supabase.from('restaurants').select('name').limit(1);
    //   final restaurantName = restaurantData.first['name'] as String;
    //   await _storage.write(key: 'restaurant_name', value: restaurantName);

    //   final String? token = response.session?.accessToken;

    //   if (token != null) {
    //     return token;
    //   } else {
    //     throw Exception("Failed to get token");
    //   }
    // } catch (e) {
    //   throw Exception(e);
    // }
  }
}
