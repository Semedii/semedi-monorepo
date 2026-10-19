import 'package:semedi/models/reservation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReservationService {
  final _supabase = Supabase.instance.client;

  Future<List<Reservation>> getTodayReservations() async {
    try {
      final now = DateTime.now();
      final todayStart =
          DateTime(now.year, now.month, now.day).toIso8601String();
      final todayEnd =
          DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
      final response = await _supabase
          .from('reservations')
          .select()
          .gte('reserved_at', todayStart)
          .lte('reserved_at', todayEnd)
          .order('reserved_at', ascending: true);
      return response.map((json) => Reservation.fromJson(json)).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateReservationStatus(String id, String status) async {
    try {
      await _supabase
          .from('reservations')
          .update({'status': status}).eq('id', id);
    } catch (e) {
      throw Exception(e);
    }
  }
}
