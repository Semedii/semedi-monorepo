import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryItem {
  final String name;
  final String unit;
  final double quantity;
  final double lowStockThreshold;

  InventoryItem({
    required this.name,
    required this.unit,
    required this.quantity,
    this.lowStockThreshold = 10.0,
  });

  bool get isLowStock => quantity <= lowStockThreshold;

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      name: json['name'],
      unit: json['unit'],
      quantity: double.parse(json['quantity'].toString()),
      lowStockThreshold:
          double.parse(json['low_stock_threshold'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit,
      'quantity': quantity,
      'low_stock_threshold': lowStockThreshold,
      'restaurant_id': Supabase.instance.client.auth.currentUser!.userMetadata?['restaurant_id'],
    };
  }
}
