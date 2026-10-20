import 'package:semedi_pos/models/supplier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupplierService {
  final _supabase = Supabase.instance.client;

  Future<List<Supplier>> getSuppliers() async {
    try {
      final response = await _supabase
          .from('suppliers')
          .select()
          .order('name', ascending: true);
      return response.map((json) => Supplier.fromJson(json)).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> addSupplier(Supplier supplier) async {
    try {
      final existing = await _supabase
          .from('suppliers')
          .select('name')
          .ilike('name', supplier.name);
      if (existing.isNotEmpty) {
        throw Exception('Supplier with this name already exists');
      } else {
        await _supabase.from('suppliers').insert(supplier.toJson());
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateSupplier({
    required Supplier oldSupplier,
    required Supplier newSupplier,
  }) async {
    try {
      await _supabase
          .from('suppliers')
          .update(newSupplier.toJson())
          .eq('id', oldSupplier.id);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteSupplier(Supplier supplier) async {
    try {
      await _supabase.from('suppliers').delete().eq('id', supplier.id);
    } catch (e) {
      throw Exception(e);
    }
  }
}
