import 'package:cloud_firestore/cloud_firestore.dart';

class KitchenUser {
  final String email;
  final String name;
  final String restaurant;

  KitchenUser({
    required this.email,
    required this.name,
    required this.restaurant,
  });

  factory KitchenUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KitchenUser(
      email: data['email'],
      name: data['name'],
      restaurant: data['restaurant'],
    );
  }
}
