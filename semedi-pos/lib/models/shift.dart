import 'package:supabase_flutter/supabase_flutter.dart';

class Shift {
  final String id;
  final String cashierName;
  final double openingFloat;
  final double? closingFloat;
  final DateTime openedAt;
  final DateTime? closedAt;
  final bool isOpen;

  Shift({
    required this.id,
    required this.cashierName,
    required this.openingFloat,
    this.closingFloat,
    required this.openedAt,
    this.closedAt,
    this.isOpen = true,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'].toString(),
      cashierName: json['cashier_name'],
      openingFloat: double.parse(json['opening_float'].toString()),
      closingFloat: json['closing_float'] != null
          ? double.parse(json['closing_float'].toString())
          : null,
      openedAt: DateTime.parse(json['opened_at']),
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'])
          : null,
      isOpen: json['is_open'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cashier_name': cashierName,
      'opening_float': openingFloat,
      'closing_float': closingFloat,
      'opened_at': openedAt.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'is_open': isOpen,
      'restaurant_id': Supabase.instance.client.auth.currentUser!.userMetadata?['restaurant_id'],
    };
  }
}
