import 'package:supabase_flutter/supabase_flutter.dart';

class Discount {
  final String name;
  final double percentage;
  bool isActive;

  Discount({
    required this.name,
    required this.percentage,
    this.isActive = true,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      name: json['name'],
      percentage: double.parse(json['percentage'].toString()),
      isActive: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'percentage': percentage,
      'active': isActive,
      'restaurant_id': Supabase.instance.client.auth.currentUser!.userMetadata?['restaurant_id'],
    };
  }
}
