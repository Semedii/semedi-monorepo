import 'package:supabase_flutter/supabase_flutter.dart';

class Supplier {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? note;

  Supplier({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.note,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'].toString(),
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'note': note,
      'restaurant_id':
          Supabase.instance.client.auth.currentUser!.userMetadata?['restaurant_id'],
    };
  }
}
