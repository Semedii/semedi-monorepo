import 'package:supabase_flutter/supabase_flutter.dart';

class MenuItem {
  final String? id;
  final String name;
  final double price;
  bool isAvailable;
  List<String> searchKeywords;

  MenuItem({
    this.id,
    required this.name,
    required this.price,
    this.isAvailable = true,
    this.searchKeywords = const [],
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
        id: json['id'],
        name: json['name'],
        price: double.parse(json['price'].toString()),
        isAvailable: json['available']);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'available': isAvailable,
      'restaurant_id': Supabase
          .instance.client.auth.currentUser!.userMetadata?['restaurant_id'],
    };
  }
}
