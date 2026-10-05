class Waiter {
  final String name;
  final String email;
  final String restaurant;

  Waiter({
    required this.name,
    required this.email,
    required this.restaurant,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'restaurant': restaurant,
    };
  }
}
