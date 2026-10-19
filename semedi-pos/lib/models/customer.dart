import 'package:supabase_flutter/supabase_flutter.dart';

class Customer {
  final String id;
  final String name;
  final String phone;
  final int loyaltyPoints;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.loyaltyPoints = 0,
    required this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'].toString(),
      name: json['name'],
      phone: json['phone'],
      loyaltyPoints: json['loyalty_points'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'loyalty_points': loyaltyPoints,
      'restaurant_id': Supabase.instance.client.auth.currentUser!.userMetadata?['restaurant_id'],
    };
  }
}
