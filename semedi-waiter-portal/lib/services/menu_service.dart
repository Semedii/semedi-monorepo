import 'package:semedi/models/menu.dart';
import 'package:semedi/services/secure_storage_service.dart';
import 'package:semedi/services/service_locator.dart';

class MenuService {
  final secureStorageService = getIt<SecureStorageService>();
  getMenu() async {
    // final response =
    //     await _supabase.from('menu_items').select('id, name, price, available');

    // return response.map((json) => MenuItem.fromJson(json)).toList();
  }
}
