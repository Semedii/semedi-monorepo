import 'package:semedi_pos/models/reservation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReservationService {
  final _supabase = Supabase.instance.client;

  Future<List<Reservation>> getTodayReservations() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
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

  Future<List<Reservation>> getUpcomingReservations() async {
    try {
      final response = await _supabase
          .from('reservations')
          .select()
          .eq('status', 'upcoming')
          .gte('reserved_at', DateTime.now().toIso8601String())
          .order('reserved_at', ascending: true);
      return response.map((json) => Reservation.fromJson(json)).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> addReservation(Reservation reservation) async {
    try {
      await _supabase.from('reservations').insert(reservation.toJson());
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

  Future<void> deleteReservation(String id) async {
    try {
      await _supabase.from('reservations').delete().eq('id', id);
    } catch (e) {
      throw Exception(e);
    }
  }
}
