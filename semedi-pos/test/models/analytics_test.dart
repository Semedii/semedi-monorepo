import 'package:flutter_test/flutter_test.dart';
import 'package:semedi_pos/models/order_item.dart';
import 'package:semedi_pos/models/order_model.dart';

void main() {
  group('OrderModel analytics helpers', () {
    OrderModel _makeOrder({
      String id = 'o1',
      String status = 'paid',
      String waiter = 'Ali',
      double price = 10.0,
      int hour = 12,
    }) {
      return OrderModel(
        id: id,
        tableNumber: 1,
        waiterName: waiter,
        status: status,
        items: [
          OrderItem(
              itemName: 'Burger',
              itemPrice: price,
              itemQuantity: 1,
              modifiers: []),
        ],
        createdAt: DateTime(2024, 1, 1, hour),
      );
    }

    test('totalPrice sums item prices', () {
      final order = _makeOrder(price: 15.0);
      expect(order.totalPrice, equals(15.0));
    });

    test('totalPrice with multiple items', () {
      final order = OrderModel(
        id: 'o2',
        tableNumber: 2,
        waiterName: 'Sara',
        status: 'paid',
        items: [
          OrderItem(
              itemName: 'Pizza',
              itemPrice: 12.0,
              itemQuantity: 2,
              modifiers: []),
          OrderItem(
              itemName: 'Water',
              itemPrice: 1.5,
              itemQuantity: 1,
              modifiers: []),
        ],
        createdAt: DateTime(2024, 1, 1, 13),
      );
      expect(order.totalPrice, equals(25.5));
    });

    test('items list is accessible', () {
      final order = _makeOrder();
      expect(order.items, isNotEmpty);
      expect(order.items.first.itemName, equals('Burger'));
    });

    test('waiterName field accessible', () {
      final order = _makeOrder(waiter: 'Hassan');
      expect(order.waiterName, equals('Hassan'));
    });

    test('status field accessible', () {
      final order = _makeOrder(status: 'cancelled');
      expect(order.status, equals('cancelled'));
    });

    test('createdAt hour is correct', () {
      final order = _makeOrder(hour: 9);
      expect(order.createdAt.hour, equals(9));
    });

    test('order note defaults to null', () {
      final order = _makeOrder();
      expect(order.note, isNull);
    });

    test('order with note stores note', () {
      final order = OrderModel(
        id: 'o3',
        tableNumber: 3,
        waiterName: 'Fatima',
        status: 'ordered',
        items: [],
        createdAt: DateTime.now(),
        note: 'No onion',
      );
      expect(order.note, equals('No onion'));
    });
  });

  group('OrderItem', () {
    test('itemPrice is a double', () {
      final item = OrderItem(
          itemName: 'Salad', itemPrice: 5.0, itemQuantity: 1, modifiers: []);
      expect(item.itemPrice, isA<double>());
    });

    test('itemQuantity is an int', () {
      final item = OrderItem(
          itemName: 'Juice', itemPrice: 2.5, itemQuantity: 3, modifiers: []);
      expect(item.itemQuantity, isA<int>());
      expect(item.itemQuantity, equals(3));
    });

    test('modifiers default empty', () {
      final item = OrderItem(
          itemName: 'Tea', itemPrice: 1.0, itemQuantity: 1, modifiers: []);
      expect(item.modifiers, isEmpty);
    });

    test('modifiers list is stored', () {
      final item = OrderItem(
        itemName: 'Coffee',
        itemPrice: 2.0,
        itemQuantity: 1,
        modifiers: ['extra sugar', 'no milk'],
      );
      expect(item.modifiers.length, equals(2));
      expect(item.modifiers.contains('extra sugar'), isTrue);
    });
  });
}
