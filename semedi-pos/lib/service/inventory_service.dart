import 'package:semedi_pos/models/inventory_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryService {
  final _supabase = Supabase.instance.client;

  Future<List<InventoryItem>> getInventoryList() async {
    try {
      final response = await _supabase
          .from('inventory')
          .select()
          .order('name', ascending: true);
      return response.map((json) => InventoryItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> addInventoryItem(InventoryItem item) async {
    try {
      final response = await _supabase
          .from('inventory')
          .select('name')
          .ilike('name', item.name);

      if (response.isNotEmpty) {
        throw Exception('Item with this name already exists');
      } else {
        await _supabase.from('inventory').insert(item.toJson());
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteInventoryItem(InventoryItem item) async {
    try {
      await _supabase.from('inventory').delete().eq('name', item.name);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateInventoryItem({
    required InventoryItem oldItem,
    required InventoryItem newItem,
  }) async {
    try {
      await _supabase
          .from('inventory')
          .update(newItem.toJson())
          .eq('name', oldItem.name);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> adjustQuantity(
      String itemName, double currentQuantity, double delta) async {
    try {
      await _supabase
          .from('inventory')
          .update({'quantity': currentQuantity + delta}).eq('name', itemName);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<InventoryItem>> getLowStockItems() async {
    try {
      final response = await _supabase.from('inventory').select();
      final all =
          response.map((json) => InventoryItem.fromJson(json)).toList();
      return all.where((item) => item.isLowStock).toList();
    } catch (e) {
      throw Exception(e);
    }
  }
}
