class OrderItem {
  final String? itemId;
  final String? itemName;
  final double? itemPrice;
  final int? itemQuantity;
  final String? note;

  OrderItem(
      {this.itemId,
      this.itemName,
      this.itemPrice,
      this.itemQuantity,
      this.note});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final menu = json['menu_items'];
    return OrderItem(
        itemName: menu['name'],
        itemPrice: (menu['price'] as num).toDouble(),
        itemQuantity: json['quantity'] as int,
        note: json['notes']);
  }

  Map<String, dynamic> toJson() {
    return {'menu_item_id': itemId, 'quantity': itemQuantity, 'note': note};
  }

  OrderItem copyWith({
    String? itemId,
    String? itemName,
    double? itemPrice,
    int? itemQuantity,
    String? note,
  }) {
    return OrderItem(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      itemPrice: itemPrice ?? this.itemPrice,
      itemQuantity: itemQuantity ?? this.itemQuantity,
      note: note ?? this.note,
    );
  }
}
