import 'package:cloud_firestore/cloud_firestore.dart';

class Cashier {
  final String email;
  final String name;
  final String restaurant;

  Cashier({required this.email, required this.name, required this.restaurant});
  factory Cashier.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Cashier(
      email: data['name'],
      name: data['email'],
      restaurant: data['restaurant'],
    );
  }
}
