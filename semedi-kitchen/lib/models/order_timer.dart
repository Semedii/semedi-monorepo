class OrderTimer {
  final String orderId;
  final DateTime startedAt;

  OrderTimer({required this.orderId, required this.startedAt});

  int get elapsedMinutes => DateTime.now().difference(startedAt).inMinutes;

  bool get isUrgent => elapsedMinutes >= 15;
  bool get isWarning => elapsedMinutes >= 8 && elapsedMinutes < 15;
}
