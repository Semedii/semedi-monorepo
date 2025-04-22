import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String name;
  final double price;
  bool isAvailable;
  List<String> searchKeywords;

  MenuItem({
    required this.name,
    required this.price,
    this.isAvailable = true,
    this.searchKeywords = const [],
  });

  factory MenuItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null || data.isEmpty) {
      return MenuItem(name: '', price: 0.0, isAvailable: false);
    }

    return MenuItem(
      name: data['name'] ?? 'Unnamed Item',
      price: double.tryParse(data['price']?.toString() ?? '') ?? 0.0,
      isAvailable: data['isAvailable'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'isAvailable': isAvailable,
    };
  }
}
