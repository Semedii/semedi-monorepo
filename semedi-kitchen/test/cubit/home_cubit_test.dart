import 'package:flutter_test/flutter_test.dart';
import 'package:semedi_kitchen/models/order.dart';
import 'package:semedi_kitchen/models/order_item.dart';
import 'package:semedi_kitchen/models/order_timer.dart';

void main() {
  group('OrderTimer', () {
    test('elapsedMinutes returns correct minutes since startedAt', () {
      final startedAt = DateTime.now().subtract(const Duration(minutes: 5));
      final timer = OrderTimer(orderId: 'order-1', startedAt: startedAt);
      expect(timer.elapsedMinutes, 5);
    });

    test('isUrgent is false when elapsed is under 15 minutes', () {
      final startedAt = DateTime.now().subtract(const Duration(minutes: 14));
      final timer = OrderTimer(orderId: 'order-1', startedAt: startedAt);
      expect(timer.isUrgent, false);
    });

    test('isUrgent is true when elapsed is exactly 15 minutes', () {
      final startedAt = DateTime.now().subtract(const Duration(minutes: 15));
      final timer = OrderTimer(orderId: 'order-1', startedAt: startedAt);
      expect(timer.isUrgent, true);
    });

    test('isUrgent is true when elapsed is over 15 minutes', () {
      final startedAt = DateTime.now().subtract(const Duration(minutes: 25));
      final timer = OrderTimer(orderId: 'order-1', startedAt: startedAt);
      expect(timer.isUrgent, true);
    });

    test('isWarning is true when elapsed is between 8 and 14 minutes', () {
      final startedAt = DateTime.now().subtract(const Duration(minutes: 10));
      final timer = OrderTimer(orderId: 'order-1', startedAt: startedAt);
      expect(timer.isWarning, true);
    });

    test('isWarning is true at exactly 8 minutes', () {
      final startedAt = DateTime.now().subtract(const Duration(minutes: 8));
      final timer = OrderTimer(orderId: 'order-1', startedAt: startedAt);
      expect(timer.isWarning, true);
    });

    test('isWarning is false when elapsed is under 8 minutes', () {
      final startedAt = DateTime.now().subtract(const Duration(minutes: 5));
      final timer = OrderTimer(orderId: 'order-1', startedAt: startedAt);
      expect(timer.isWarning, false);
    });

    test('isWarning is false when urgent (15+ minutes)', () {
      final startedAt = DateTime.now().subtract(const Duration(minutes: 20));
      final timer = OrderTimer(orderId: 'order-1', startedAt: startedAt);
      expect(timer.isWarning, false);
    });

    test('neither isUrgent nor isWarning when elapsed under 8 minutes', () {
      final startedAt = DateTime.now().subtract(const Duration(minutes: 3));
      final timer = OrderTimer(orderId: 'order-1', startedAt: startedAt);
      expect(timer.isUrgent, false);
      expect(timer.isWarning, false);
    });

    test('orderId is stored correctly', () {
      final timer = OrderTimer(
        orderId: 'test-id-123',
        startedAt: DateTime.now(),
      );
      expect(timer.orderId, 'test-id-123');
    });
  });

  group('OrderItem', () {
    test('fromJson parses menu item fields correctly', () {
      final json = {
        'menu_items': {'name': 'Shawarma', 'price': 8.50},
        'quantity': 2,
        'notes': 'extra spicy',
        'modifiers': <String>[],
      };
      final item = OrderItem.fromJson(json);
      expect(item.itemName, 'Shawarma');
      expect(item.itemPrice, 8.50);
      expect(item.itemQuantity, 2);
      expect(item.note, 'extra spicy');
    });

    test('fromJson parses modifiers list', () {
      final json = {
        'menu_items': {'name': 'Burger', 'price': 6.0},
        'quantity': 1,
        'notes': null,
        'modifiers': ['no pickles', 'extra cheese'],
      };
      final item = OrderItem.fromJson(json);
      expect(item.modifiers, ['no pickles', 'extra cheese']);
    });

    test('fromJson uses empty modifiers list when field missing', () {
      final json = {
        'menu_items': {'name': 'Fries', 'price': 3.0},
        'quantity': 1,
        'notes': null,
      };
      final item = OrderItem.fromJson(json);
      expect(item.modifiers, isEmpty);
    });

    test('fromJson parses integer price as double', () {
      final json = {
        'menu_items': {'name': 'Rice', 'price': 4},
        'quantity': 1,
        'notes': null,
        'modifiers': <String>[],
      };
      final item = OrderItem.fromJson(json);
      expect(item.itemPrice, isA<double>());
      expect(item.itemPrice, 4.0);
    });

    test('default modifiers is const empty list', () {
      final item = OrderItem(
        itemName: 'Tea',
        itemPrice: 1.50,
        itemQuantity: 3,
      );
      expect(item.modifiers, isEmpty);
    });
  });

  group('OrderModel', () {
    OrderModel _makeOrder({List<OrderItem>? items}) {
      return OrderModel(
        id: 'o1',
        orderNumber: 42,
        tableNumber: 7,
        waiterName: 'Zahra',
        status: 'pending',
        items: items ??
            [
              OrderItem(
                  itemName: 'Salad', itemPrice: 5.0, itemQuantity: 1),
            ],
        createdAt: DateTime(2026, 10, 19, 12, 0),
      );
    }

    test('totalPrice sums itemPrice * itemQuantity for all items', () {
      final order = _makeOrder(items: [
        OrderItem(itemName: 'Burger', itemPrice: 5.0, itemQuantity: 2),
        OrderItem(itemName: 'Juice', itemPrice: 2.50, itemQuantity: 3),
      ]);
      expect(order.totalPrice, closeTo(17.5, 0.001));
    });

    test('totalPrice is 0.0 for empty items list', () {
      final order = _makeOrder(items: []);
      expect(order.totalPrice, 0.0);
    });

    test('totalPrice handles single item', () {
      final order = _makeOrder(items: [
        OrderItem(itemName: 'Coffee', itemPrice: 2.0, itemQuantity: 4),
      ]);
      expect(order.totalPrice, 8.0);
    });

    test('stores all fields correctly', () {
      final created = DateTime(2026, 10, 19, 8, 0);
      final order = OrderModel(
        id: 'abc-123',
        orderNumber: 99,
        tableNumber: 12,
        waiterName: 'Hassan',
        status: 'preparing',
        items: [],
        createdAt: created,
      );
      expect(order.id, 'abc-123');
      expect(order.orderNumber, 99);
      expect(order.tableNumber, 12);
      expect(order.waiterName, 'Hassan');
      expect(order.status, 'preparing');
      expect(order.createdAt, created);
    });
  });
}
