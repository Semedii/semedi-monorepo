class OrderItem {
  final String itemName;
  final double itemPrice;
  final int itemQuantity;

  OrderItem(
      {required this.itemName,
      required this.itemPrice,
      required this.itemQuantity});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final menu = json['menu_items'];
    return OrderItem(
      itemName: menu['name'],
      itemPrice: (menu['price'] as num).toDouble(),
      itemQuantity: json['quantity'] as int,
    );
  }
}
