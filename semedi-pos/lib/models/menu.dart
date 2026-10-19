import 'package:supabase_flutter/supabase_flutter.dart';

class MenuItem {
  final String name;
  final double price;
  bool isAvailable;
  List<String> searchKeywords;
  final String? category;

  MenuItem({
    required this.name,
    required this.price,
    this.isAvailable = true,
    this.searchKeywords = const [],
    this.category,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
        name: json['name'],
        price: double.parse(json['price'].toString()),
        isAvailable: json['available'],
        category: json['category']);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'available': isAvailable,
      'category': category,
      'restaurant_id': Supabase
          .instance.client.auth.currentUser!.userMetadata?['restaurant_id'],
    };
  }
}
