import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semedi/models/menu.dart';
import 'package:semedi/services/secure_storage_service.dart';
import 'package:semedi/services/service_locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuService {
  final db = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;
  final secureStorageService = getIt<SecureStorageService>();
  Future<List<MenuItem>> getMenu() async {
    final response =
        await _supabase.from('menu_items').select('id, name, price, available');

    return response.map((json) => MenuItem.fromJson(json)).toList();
  }
}
