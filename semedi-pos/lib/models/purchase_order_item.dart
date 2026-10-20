class PurchaseOrderItem {
  final String inventoryItemName;
  final String unit;
  final double orderedQuantity;
  final double receivedQuantity;
  final double unitCost;

  PurchaseOrderItem({
    required this.inventoryItemName,
    required this.unit,
    required this.orderedQuantity,
    this.receivedQuantity = 0.0,
    required this.unitCost,
  });

  double get totalCost => orderedQuantity * unitCost;
  bool get isFullyReceived => receivedQuantity >= orderedQuantity;

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      inventoryItemName: json['inventory_item_name'],
      unit: json['unit'],
      orderedQuantity: double.parse(json['ordered_quantity'].toString()),
      receivedQuantity: double.parse(json['received_quantity'].toString()),
      unitCost: double.parse(json['unit_cost'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inventory_item_name': inventoryItemName,
      'unit': unit,
      'ordered_quantity': orderedQuantity,
      'received_quantity': receivedQuantity,
      'unit_cost': unitCost,
    };
  }
}
