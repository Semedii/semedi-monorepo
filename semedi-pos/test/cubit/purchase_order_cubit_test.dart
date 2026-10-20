import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:semedi_pos/cubit/purchaseOrder/purchase_order_cubit.dart';
import 'package:semedi_pos/models/purchase_order.dart';
import 'package:semedi_pos/models/purchase_order_item.dart';
import 'package:semedi_pos/models/supplier.dart';
import 'package:semedi_pos/service/purchase_order_service.dart';
import 'package:semedi_pos/service/supplier_service.dart';

class MockPurchaseOrderService extends Mock implements PurchaseOrderService {}

class MockSupplierService extends Mock implements SupplierService {}

PurchaseOrder _makeOrder({String id = 'po-1', String status = 'draft'}) {
  return PurchaseOrder(
    id: id,
    supplierId: 'sup-1',
    supplierName: 'Fresh Farms',
    status: status,
    createdAt: DateTime(2026, 1, 15),
    items: [
      PurchaseOrderItem(
        inventoryItemName: 'Tomatoes',
        unit: 'kg',
        orderedQuantity: 10.0,
        unitCost: 2.0,
      ),
    ],
  );
}

Supplier _makeSupplier({String id = 'sup-1'}) {
  return Supplier(id: id, name: 'Fresh Farms', phone: '0612345678');
}

void main() {
  late MockPurchaseOrderService mockOrderService;
  late MockSupplierService mockSupplierService;

  setUp(() {
    mockOrderService = MockPurchaseOrderService();
    mockSupplierService = MockSupplierService();
  });

  group('PurchaseOrderCubit', () {
    group('initPage', () {
      blocTest<PurchaseOrderCubit, PurchaseOrderState>(
        'emits [Loading, Loaded] when both services succeed',
        build: () {
          when(() => mockOrderService.getPurchaseOrders())
              .thenAnswer((_) async => [_makeOrder()]);
          when(() => mockSupplierService.getSuppliers())
              .thenAnswer((_) async => [_makeSupplier()]);
          return PurchaseOrderCubit(mockOrderService, mockSupplierService);
        },
        act: (cubit) => cubit.initPage(),
        expect: () => [
          isA<PurchaseOrderLoading>(),
          isA<PurchaseOrderLoaded>(),
        ],
      );

      blocTest<PurchaseOrderCubit, PurchaseOrderState>(
        'emits [Loading, Loaded] with correct orders and suppliers',
        build: () {
          when(() => mockOrderService.getPurchaseOrders())
              .thenAnswer((_) async => [
                    _makeOrder(id: 'po-1'),
                    _makeOrder(id: 'po-2'),
                  ]);
          when(() => mockSupplierService.getSuppliers())
              .thenAnswer((_) async => [_makeSupplier()]);
          return PurchaseOrderCubit(mockOrderService, mockSupplierService);
        },
        act: (cubit) => cubit.initPage(),
        expect: () => [
          isA<PurchaseOrderLoading>(),
          isA<PurchaseOrderLoaded>()
              .having((s) => s.orders.length, 'orders count', 2)
              .having((s) => s.suppliers.length, 'suppliers count', 1),
        ],
      );

      blocTest<PurchaseOrderCubit, PurchaseOrderState>(
        'emits [Loading, Failure] when order service throws',
        build: () {
          when(() => mockOrderService.getPurchaseOrders())
              .thenThrow(Exception('network error'));
          when(() => mockSupplierService.getSuppliers())
              .thenAnswer((_) async => []);
          return PurchaseOrderCubit(mockOrderService, mockSupplierService);
        },
        act: (cubit) => cubit.initPage(),
        expect: () => [
          isA<PurchaseOrderLoading>(),
          isA<PurchaseOrderFailure>(),
        ],
      );

      blocTest<PurchaseOrderCubit, PurchaseOrderState>(
        'emits [Loading, Failure] when supplier service throws',
        build: () {
          when(() => mockOrderService.getPurchaseOrders())
              .thenAnswer((_) async => []);
          when(() => mockSupplierService.getSuppliers())
              .thenThrow(Exception('supplier fetch failed'));
          return PurchaseOrderCubit(mockOrderService, mockSupplierService);
        },
        act: (cubit) => cubit.initPage(),
        expect: () => [
          isA<PurchaseOrderLoading>(),
          isA<PurchaseOrderFailure>(),
        ],
      );
    });

    group('onCreateOrder', () {
      blocTest<PurchaseOrderCubit, PurchaseOrderState>(
        'calls service and reloads on success',
        build: () {
          when(() => mockOrderService.createPurchaseOrder(
                supplierId: any(named: 'supplierId'),
                note: any(named: 'note'),
                items: any(named: 'items'),
              )).thenAnswer((_) async {});
          when(() => mockOrderService.getPurchaseOrders())
              .thenAnswer((_) async => [_makeOrder()]);
          when(() => mockSupplierService.getSuppliers())
              .thenAnswer((_) async => [_makeSupplier()]);
          return PurchaseOrderCubit(mockOrderService, mockSupplierService);
        },
        act: (cubit) => cubit.onCreateOrder(
          supplierId: 'sup-1',
          note: 'Rush order',
          items: [
            PurchaseOrderItem(
              inventoryItemName: 'Tomatoes',
              unit: 'kg',
              orderedQuantity: 10.0,
              unitCost: 2.0,
            ),
          ],
        ),
        expect: () => [
          isA<PurchaseOrderLoading>(),
          isA<PurchaseOrderLoading>(),
          isA<PurchaseOrderLoaded>(),
        ],
        verify: (_) {
          verify(() => mockOrderService.createPurchaseOrder(
                supplierId: any(named: 'supplierId'),
                note: any(named: 'note'),
                items: any(named: 'items'),
              )).called(1);
        },
      );

      blocTest<PurchaseOrderCubit, PurchaseOrderState>(
        'emits Failure when create throws',
        build: () {
          when(() => mockOrderService.createPurchaseOrder(
                supplierId: any(named: 'supplierId'),
                note: any(named: 'note'),
                items: any(named: 'items'),
              )).thenThrow(Exception('insert failed'));
          return PurchaseOrderCubit(mockOrderService, mockSupplierService);
        },
        act: (cubit) => cubit.onCreateOrder(
          supplierId: 'sup-1',
          items: [],
        ),
        expect: () => [
          isA<PurchaseOrderLoading>(),
          isA<PurchaseOrderFailure>(),
        ],
      );
    });

    group('onMarkOrdered', () {
      blocTest<PurchaseOrderCubit, PurchaseOrderState>(
        'updates status to ordered and reloads',
        build: () {
          when(() => mockOrderService.updateOrderStatus('po-1', 'ordered'))
              .thenAnswer((_) async {});
          when(() => mockOrderService.getPurchaseOrders())
              .thenAnswer((_) async => [_makeOrder(status: 'ordered')]);
          when(() => mockSupplierService.getSuppliers())
              .thenAnswer((_) async => []);
          return PurchaseOrderCubit(mockOrderService, mockSupplierService);
        },
        act: (cubit) => cubit.onMarkOrdered(_makeOrder()),
        verify: (_) {
          verify(() =>
                  mockOrderService.updateOrderStatus('po-1', 'ordered'))
              .called(1);
        },
        expect: () => [
          isA<PurchaseOrderLoading>(),
          isA<PurchaseOrderLoading>(),
          isA<PurchaseOrderLoaded>(),
        ],
      );
    });

    group('onMarkReceived', () {
      blocTest<PurchaseOrderCubit, PurchaseOrderState>(
        'updates status to received and reloads',
        build: () {
          when(() => mockOrderService.updateOrderStatus('po-1', 'received'))
              .thenAnswer((_) async {});
          when(() => mockOrderService.getPurchaseOrders())
              .thenAnswer((_) async => []);
          when(() => mockSupplierService.getSuppliers())
              .thenAnswer((_) async => []);
          return PurchaseOrderCubit(mockOrderService, mockSupplierService);
        },
        act: (cubit) =>
            cubit.onMarkReceived(_makeOrder(status: 'ordered')),
        verify: (_) {
          verify(() =>
                  mockOrderService.updateOrderStatus('po-1', 'received'))
              .called(1);
        },
        expect: () => [
          isA<PurchaseOrderLoading>(),
          isA<PurchaseOrderLoading>(),
          isA<PurchaseOrderLoaded>(),
        ],
      );
    });

    group('onReceiveItem', () {
      blocTest<PurchaseOrderCubit, PurchaseOrderState>(
        'calls receiveOrderItem and reloads',
        build: () {
          when(() => mockOrderService.receiveOrderItem(
                orderId: any(named: 'orderId'),
                item: any(named: 'item'),
                receivedQuantity: any(named: 'receivedQuantity'),
              )).thenAnswer((_) async {});
          when(() => mockOrderService.getPurchaseOrders())
              .thenAnswer((_) async => []);
          when(() => mockSupplierService.getSuppliers())
              .thenAnswer((_) async => []);
          return PurchaseOrderCubit(mockOrderService, mockSupplierService);
        },
        act: (cubit) {
          final order = _makeOrder(status: 'ordered');
          final item = order.items.first;
          return cubit.onReceiveItem(
            order: order,
            item: item,
            receivedQuantity: 10.0,
          );
        },
        expect: () => [
          isA<PurchaseOrderLoading>(),
          isA<PurchaseOrderLoading>(),
          isA<PurchaseOrderLoaded>(),
        ],
        verify: (_) {
          verify(() => mockOrderService.receiveOrderItem(
                orderId: any(named: 'orderId'),
                item: any(named: 'item'),
                receivedQuantity: any(named: 'receivedQuantity'),
              )).called(1);
        },
      );
    });

    group('onDeleteOrder', () {
      blocTest<PurchaseOrderCubit, PurchaseOrderState>(
        'deletes order and reloads',
        build: () {
          when(() => mockOrderService.deletePurchaseOrder('po-1'))
              .thenAnswer((_) async {});
          when(() => mockOrderService.getPurchaseOrders())
              .thenAnswer((_) async => []);
          when(() => mockSupplierService.getSuppliers())
              .thenAnswer((_) async => []);
          return PurchaseOrderCubit(mockOrderService, mockSupplierService);
        },
        act: (cubit) => cubit.onDeleteOrder(_makeOrder()),
        verify: (_) {
          verify(() => mockOrderService.deletePurchaseOrder('po-1')).called(1);
        },
        expect: () => [
          isA<PurchaseOrderLoading>(),
          isA<PurchaseOrderLoading>(),
          isA<PurchaseOrderLoaded>(),
        ],
      );

      blocTest<PurchaseOrderCubit, PurchaseOrderState>(
        'emits Failure when delete throws',
        build: () {
          when(() => mockOrderService.deletePurchaseOrder(any()))
              .thenThrow(Exception('delete failed'));
          return PurchaseOrderCubit(mockOrderService, mockSupplierService);
        },
        act: (cubit) => cubit.onDeleteOrder(_makeOrder()),
        expect: () => [
          isA<PurchaseOrderLoading>(),
          isA<PurchaseOrderFailure>(),
        ],
      );
    });
  });
}
