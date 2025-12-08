class OrderItem {
  final String itemName;
  final double itemPrice;
  final int itemQuantity;
  final String? note;

  OrderItem(
      {required this.itemName,
      required this.itemPrice,
      required this.itemQuantity,
      this.note});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final menu = json['menu_items'];
    return OrderItem(
      itemName: menu['name'],
      itemPrice: (menu['price'] as num).toDouble(),
      itemQuantity: json['quantity'] as int,
      note: json['notes'],
    );
  }
}
