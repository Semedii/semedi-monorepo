import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semedi/services/secure_storage_service.dart';
import 'package:semedi/services/service_locator.dart';

class DiningTablesService {
  final db = FirebaseFirestore.instance;
  final secureStorageService = getIt<SecureStorageService>();
  getDiningTables() async {
    // final response = await _supabase
    //     .from('dining_tables')
    //     .select('id, table_number, status, capacity, location');

    // return response.map((json) => DiningTables.fromJson(json)).toList();
  }

  getDiningTablesStream() {
    // return _supabase.from('dining_tables').stream(primaryKey: ['id']).map(
    //     (rows) => rows.map((json) => DiningTables.fromJson(json)).toList());
  }
}
