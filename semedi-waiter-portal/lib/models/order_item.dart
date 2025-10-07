class OrderItem {
  final String? itemId;
  final String? itemName;
  final double? itemPrice;
  final int? itemQuantity;

  OrderItem({this.itemId, this.itemName, this.itemPrice, this.itemQuantity});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final menu = json['menu_items'];
    return OrderItem(
      itemName: menu['name'],
      itemPrice: (menu['price'] as num).toDouble(),
      itemQuantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'menu_item_id': itemId, 'quantity': itemQuantity};
  }

  OrderItem copyWith({
    String? itemId,
    String? itemName,
    double? itemPrice,
    int? itemQuantity,
  }) {
    return OrderItem(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      itemPrice: itemPrice ?? this.itemPrice,
      itemQuantity: itemQuantity ?? this.itemQuantity,
    );
  }
}
