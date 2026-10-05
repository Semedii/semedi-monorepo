import 'package:cloud_firestore/cloud_firestore.dart';

class Waiter {
  final String name;
  final String email;
  final bool isDisabled;
  final String restaurant;

  Waiter({
    required this.name,
    required this.isDisabled,
    required this.email,
    required this.restaurant,
  });
  factory Waiter.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Waiter(
      name: data['name'],
      email: data['email'],
      restaurant: data['restaurant'],
      isDisabled: data['isDisabled'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'restaurant': restaurant,
      'isDisabled': isDisabled,
    };
  }
}
