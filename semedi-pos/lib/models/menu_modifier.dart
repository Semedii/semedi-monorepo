import 'package:supabase_flutter/supabase_flutter.dart';

class MenuModifier {
  final String name;
  final double extraCharge;
  bool isAvailable;

  MenuModifier({
    required this.name,
    this.extraCharge = 0.0,
    this.isAvailable = true,
  });

  factory MenuModifier.fromJson(Map<String, dynamic> json) {
    return MenuModifier(
      name: json['name'],
      extraCharge: double.parse(json['extra_charge'].toString()),
      isAvailable: json['available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'extra_charge': extraCharge,
      'available': isAvailable,
      'restaurant_id': Supabase.instance.client.auth.currentUser!.userMetadata?['restaurant_id'],
    };
  }
}
