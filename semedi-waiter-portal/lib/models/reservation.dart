import 'package:supabase_flutter/supabase_flutter.dart';

class Reservation {
  final String id;
  final String guestName;
  final String phone;
  final int guestCount;
  final int tableNumber;
  final DateTime reservedAt;
  final String? note;
  final String status;

  Reservation({
    required this.id,
    required this.guestName,
    required this.phone,
    required this.guestCount,
    required this.tableNumber,
    required this.reservedAt,
    this.note,
    this.status = 'upcoming',
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'].toString(),
      guestName: json['guest_name'],
      phone: json['phone'],
      guestCount: json['guest_count'],
      tableNumber: json['table_number'],
      reservedAt: DateTime.parse(json['reserved_at']),
      note: json['note'],
      status: json['status'] ?? 'upcoming',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guest_name': guestName,
      'phone': phone,
      'guest_count': guestCount,
      'table_number': tableNumber,
      'reserved_at': reservedAt.toIso8601String(),
      'note': note,
      'status': status,
      'restaurant_id':
          Supabase.instance.client.auth.currentUser!.userMetadata?['restaurant_id'],
    };
  }
}
