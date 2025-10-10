import 'package:semedi_kitchen/models/menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuService {
  final _supabase = Supabase.instance.client;
  Future<List<MenuItem>?> getMenuList() async {
    final response = await _supabase.from('menu_items').select();

    return response.map((json) => MenuItem.fromJson(json)).toList();
  }

  Future<void> disableOrEnableMenu(
      {required MenuItem menu, required bool value}) async {
    try {
      await _supabase
          .from('menu_items')
          .update({'available': value})
          .eq('id', menu.id!)
          .select();
    } catch (e) {
      throw Exception('Failed to update status: ${e.toString()}');
    }
  }
}
