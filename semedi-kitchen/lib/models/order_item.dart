class OrderItem {
  final String itemName;
  final double itemPrice;
  final int itemQuantity;
  final String? note;
  final List<String> modifiers;

  OrderItem({
    required this.itemName,
    required this.itemPrice,
    required this.itemQuantity,
    this.note,
    this.modifiers = const [],
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final menu = json['menu_items'];
    return OrderItem(
      itemName: menu['name'],
      itemPrice: (menu['price'] as num).toDouble(),
      itemQuantity: json['quantity'] as int,
      note: json['notes'],
      modifiers: List<String>.from(json['modifiers'] ?? []),
    );
  }
}
