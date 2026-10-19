import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:semedi/cubits/history/history_cubit.dart';
import 'package:semedi/models/order_item.dart';
import 'package:semedi/models/order_model.dart';
import 'package:semedi/services/order_service.dart';

class MockOrderService extends Mock implements OrderService {}

OrderModel _makeOrder({String id = 'o1'}) {
  return OrderModel(
    id: id,
    orderNumber: '0042',
    tableNumber: 7,
    waiterName: 'Zahra',
    status: 'paid',
    items: [
      OrderItem(
        itemId: 'mi1',
        itemName: 'Shawarma',
        itemPrice: 8.50,
        itemQuantity: 2,
      ),
    ],
    createdAt: DateTime(2026, 10, 19, 13, 0),
  );
}

void main() {
  late MockOrderService mockService;

  setUp(() {
    mockService = MockOrderService();
  });

  group('HistoryCubit', () {
    group('initPage', () {
      blocTest<HistoryCubit, HistoryState>(
        'emits [Loading, Loaded] when orders returned',
        build: () {
          when(() => mockService.getOrderHistory())
              .thenAnswer((_) async => [_makeOrder()]);
          return HistoryCubit(mockService);
        },
        act: (cubit) => cubit.initPage(),
        expect: () => [
          isA<HistoryLoading>(),
          isA<HistoryLoaded>(),
        ],
      );

      blocTest<HistoryCubit, HistoryState>(
        'loaded state contains correct order count',
        build: () {
          when(() => mockService.getOrderHistory()).thenAnswer(
            (_) async => [
              _makeOrder(id: 'o1'),
              _makeOrder(id: 'o2'),
            ],
          );
          return HistoryCubit(mockService);
        },
        act: (cubit) => cubit.initPage(),
        expect: () => [
          isA<HistoryLoading>(),
          isA<HistoryLoaded>().having(
            (s) => s.orders.length,
            'order count',
            2,
          ),
        ],
      );

      blocTest<HistoryCubit, HistoryState>(
        'emits [Loading, Loaded] with empty list when no history',
        build: () {
          when(() => mockService.getOrderHistory())
              .thenAnswer((_) async => []);
          return HistoryCubit(mockService);
        },
        act: (cubit) => cubit.initPage(),
        expect: () => [
          isA<HistoryLoading>(),
          isA<HistoryLoaded>().having(
            (s) => s.orders,
            'orders',
            isEmpty,
          ),
        ],
      );

      blocTest<HistoryCubit, HistoryState>(
        'emits [Loading, Failure] when service throws',
        build: () {
          when(() => mockService.getOrderHistory())
              .thenThrow(Exception('fetch failed'));
          return HistoryCubit(mockService);
        },
        act: (cubit) => cubit.initPage(),
        expect: () => [
          isA<HistoryLoading>(),
          isA<HistoryFailure>(),
        ],
      );

      blocTest<HistoryCubit, HistoryState>(
        'failure state carries error message',
        build: () {
          when(() => mockService.getOrderHistory())
              .thenThrow(Exception('server unreachable'));
          return HistoryCubit(mockService);
        },
        act: (cubit) => cubit.initPage(),
        expect: () => [
          isA<HistoryLoading>(),
          isA<HistoryFailure>().having(
            (s) => s.message,
            'message',
            contains('server unreachable'),
          ),
        ],
      );
    });
  });
}
