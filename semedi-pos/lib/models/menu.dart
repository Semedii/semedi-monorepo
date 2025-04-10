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
    final data = doc.data() as Map<String, dynamic>;

    return MenuItem(
      name: data['name'],
      price: double.parse(data['price'].toString()),
      isAvailable: data['isAvailable'],
    );
  }
}
