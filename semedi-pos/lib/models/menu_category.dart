import 'package:supabase_flutter/supabase_flutter.dart';

class MenuCategory {
  final String name;
  final String? iconName;
  int sortOrder;

  MenuCategory({
    required this.name,
    this.iconName,
    this.sortOrder = 0,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      name: json['name'],
      iconName: json['icon_name'],
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon_name': iconName,
      'sort_order': sortOrder,
      'restaurant_id': Supabase.instance.client.auth.currentUser!.userMetadata?['restaurant_id'],
    };
  }
}
