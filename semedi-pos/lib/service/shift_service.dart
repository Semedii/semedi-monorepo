import 'package:semedi_pos/models/shift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShiftService {
  final _supabase = Supabase.instance.client;

  Future<Shift?> getCurrentShift() async {
    try {
      final response = await _supabase
          .from('shifts')
          .select()
          .eq('is_open', true)
          .maybeSingle();
      if (response == null) return null;
      return Shift.fromJson(response);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> openShift({
    required String cashierName,
    required double openingFloat,
  }) async {
    try {
      await _supabase.from('shifts').insert({
        'cashier_name': cashierName,
        'opening_float': openingFloat,
        'opened_at': DateTime.now().toIso8601String(),
        'is_open': true,
        'restaurant_id':
            _supabase.auth.currentUser!.userMetadata?['restaurant_id'],
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> closeShift({
    required String shiftId,
    required double closingFloat,
  }) async {
    try {
      await _supabase.from('shifts').update({
        'closing_float': closingFloat,
        'closed_at': DateTime.now().toIso8601String(),
        'is_open': false,
      }).eq('id', shiftId);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<Shift>> getShiftHistory() async {
    try {
      final response = await _supabase
          .from('shifts')
          .select()
          .order('opened_at', ascending: false)
          .limit(30);
      return response.map((json) => Shift.fromJson(json)).toList();
    } catch (e) {
      throw Exception(e);
    }
  }
}
