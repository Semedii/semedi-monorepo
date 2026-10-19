import 'package:semedi/models/menu_modifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModifierService {
  final _supabase = Supabase.instance.client;

  Future<List<MenuModifier>> getModifierList() async {
    try {
      final response = await _supabase
          .from('menu_modifiers')
          .select('name, extra_charge, available')
          .eq('available', true);
      return response.map((json) => MenuModifier.fromJson(json)).toList();
    } catch (e) {
      throw Exception(e);
    }
  }
}
