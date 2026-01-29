import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semedi/models/dining_tables.dart';
import 'package:semedi/services/secure_storage_service.dart';
import 'package:semedi/services/service_locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiningTablesService {
  final db = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;
  final secureStorageService = getIt<SecureStorageService>();
  Future<List<DiningTables>> getDiningTables() async {
    final response = await _supabase
        .from('dining_tables')
        .select('id, table_number, status, capacity, location');

    return response.map((json) => DiningTables.fromJson(json)).toList();
  }
}
