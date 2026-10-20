import 'package:flutter_test/flutter_test.dart';
import 'package:semedi_pos/models/purchase_order.dart';
import 'package:semedi_pos/models/purchase_order_item.dart';

PurchaseOrderItem _makeItem({
  String name = 'Tomatoes',
  String unit = 'kg',
  double orderedQty = 10.0,
  double receivedQty = 0.0,
  double unitCost = 2.0,
}) {
  return PurchaseOrderItem(
    inventoryItemName: name,
    unit: unit,
    orderedQuantity: orderedQty,
    receivedQuantity: receivedQty,
    unitCost: unitCost,
  );
}

void main() {
  group('PurchaseOrderItem', () {
    test('totalCost is orderedQuantity times unitCost', () {
      final item = _makeItem(orderedQty: 5.0, unitCost: 3.0);
      expect(item.totalCost, 15.0);
    });

    test('isFullyReceived is false when receivedQuantity is zero', () {
      final item = _makeItem(orderedQty: 10.0, receivedQty: 0.0);
      expect(item.isFullyReceived, isFalse);
    });

    test('isFullyReceived is true when receivedQuantity equals orderedQuantity',
        () {
      final item = _makeItem(orderedQty: 10.0, receivedQty: 10.0);
      expect(item.isFullyReceived, isTrue);
    });

    test('isFullyReceived is true when receivedQuantity exceeds orderedQuantity',
        () {
      final item = _makeItem(orderedQty: 10.0, receivedQty: 12.0);
      expect(item.isFullyReceived, isTrue);
    });

    test('fromJson parses all fields', () {
      final json = {
        'inventory_item_name': 'Onions',
        'unit': 'kg',
        'ordered_quantity': 20,
        'received_quantity': 5,
        'unit_cost': 1.5,
      };
      final item = PurchaseOrderItem.fromJson(json);
      expect(item.inventoryItemName, 'Onions');
      expect(item.unit, 'kg');
      expect(item.orderedQuantity, 20.0);
      expect(item.receivedQuantity, 5.0);
      expect(item.unitCost, 1.5);
    });

    test('fromJson parses numeric strings', () {
      final json = {
        'inventory_item_name': 'Rice',
        'unit': 'bag',
        'ordered_quantity': '50',
        'received_quantity': '0',
        'unit_cost': '12.5',
      };
      final item = PurchaseOrderItem.fromJson(json);
      expect(item.orderedQuantity, 50.0);
      expect(item.unitCost, 12.5);
    });

    test('toJson includes all fields', () {
      final item = _makeItem(
          name: 'Salt', unit: 'kg', orderedQty: 30.0, unitCost: 0.5);
      final json = item.toJson();
      expect(json['inventory_item_name'], 'Salt');
      expect(json['unit'], 'kg');
      expect(json['ordered_quantity'], 30.0);
      expect(json['unit_cost'], 0.5);
    });
  });

  group('PurchaseOrder', () {
    final sampleDate = DateTime(2026, 1, 15);

    PurchaseOrder makeOrder({
      List<PurchaseOrderItem>? items,
      String status = 'draft',
    }) {
      return PurchaseOrder(
        id: 'po-1',
        supplierId: 'sup-1',
        supplierName: 'Fresh Farms',
        status: status,
        createdAt: sampleDate,
        items: items ?? [],
      );
    }

    test('totalCost sums all item costs', () {
      final order = makeOrder(items: [
        _makeItem(orderedQty: 10.0, unitCost: 2.0),
        _makeItem(orderedQty: 5.0, unitCost: 4.0),
      ]);
      expect(order.totalCost, 40.0);
    });

    test('totalCost is zero when no items', () {
      final order = makeOrder(items: []);
      expect(order.totalCost, 0.0);
    });

    test('receivedItemCount counts fully received items', () {
      final order = makeOrder(items: [
        _makeItem(orderedQty: 10.0, receivedQty: 10.0),
        _makeItem(orderedQty: 5.0, receivedQty: 2.0),
        _makeItem(orderedQty: 8.0, receivedQty: 8.0),
      ]);
      expect(order.receivedItemCount, 2);
    });

    test('isFullyReceived is false when no items', () {
      final order = makeOrder(items: []);
      expect(order.isFullyReceived, isFalse);
    });

    test('isFullyReceived is true when all items received', () {
      final order = makeOrder(items: [
        _makeItem(orderedQty: 10.0, receivedQty: 10.0),
        _makeItem(orderedQty: 5.0, receivedQty: 5.0),
      ]);
      expect(order.isFullyReceived, isTrue);
    });

    test('isFullyReceived is false when partial items received', () {
      final order = makeOrder(items: [
        _makeItem(orderedQty: 10.0, receivedQty: 10.0),
        _makeItem(orderedQty: 5.0, receivedQty: 0.0),
      ]);
      expect(order.isFullyReceived, isFalse);
    });

    test('fromJson parses fields correctly', () {
      final json = {
        'id': 'po-99',
        'supplier_id': 'sup-5',
        'suppliers': {'name': 'Ocean Catch'},
        'status': 'ordered',
        'created_at': '2026-03-10T10:00:00.000',
        'note': 'Urgent',
        'purchase_order_items': [
          {
            'inventory_item_name': 'Tuna',
            'unit': 'kg',
            'ordered_quantity': 20,
            'received_quantity': 0,
            'unit_cost': 15.0,
          }
        ],
      };
      final order = PurchaseOrder.fromJson(json);
      expect(order.id, 'po-99');
      expect(order.supplierName, 'Ocean Catch');
      expect(order.status, 'ordered');
      expect(order.items.length, 1);
      expect(order.items.first.inventoryItemName, 'Tuna');
      expect(order.note, 'Urgent');
    });

    test('fromJson defaults status to draft when absent', () {
      final json = {
        'id': 'po-1',
        'supplier_id': 'sup-1',
        'suppliers': {'name': 'Test'},
        'created_at': '2026-01-01T00:00:00.000',
        'purchase_order_items': [],
      };
      final order = PurchaseOrder.fromJson(json);
      expect(order.status, 'draft');
    });

    test('fromJson handles empty items list', () {
      final json = {
        'id': 'po-2',
        'supplier_id': 'sup-2',
        'suppliers': {'name': 'Grain Co'},
        'status': 'draft',
        'created_at': '2026-01-01T00:00:00.000',
        'purchase_order_items': [],
      };
      final order = PurchaseOrder.fromJson(json);
      expect(order.items, isEmpty);
    });

    test('toJson includes supplier_id and status', () {
      final order = makeOrder(status: 'ordered');
      final json = order.toJson();
      expect(json['supplier_id'], 'sup-1');
      expect(json['status'], 'ordered');
    });
  });
}
