import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:semedi_pos/cubit/supplier/supplier_cubit.dart';
import 'package:semedi_pos/models/supplier.dart';
import 'package:semedi_pos/service/supplier_service.dart';

class MockSupplierService extends Mock implements SupplierService {}

Supplier _makeSupplier({String id = '1', String name = 'Fresh Farms'}) {
  return Supplier(
    id: id,
    name: name,
    phone: '0612345678',
    email: 'contact@freshfarms.com',
    note: 'Delivers on Mondays',
  );
}

void main() {
  late MockSupplierService mockService;

  setUp(() {
    mockService = MockSupplierService();
  });

  group('SupplierCubit', () {
    group('initPage', () {
      blocTest<SupplierCubit, SupplierState>(
        'emits [Loading, Loaded] when service returns suppliers',
        build: () {
          when(() => mockService.getSuppliers())
              .thenAnswer((_) async => [_makeSupplier()]);
          return SupplierCubit(mockService);
        },
        act: (cubit) => cubit.initPage(),
        expect: () => [
          isA<SupplierLoading>(),
          isA<SupplierLoaded>(),
        ],
      );

      blocTest<SupplierCubit, SupplierState>(
        'emits [Loading, Loaded] with correct supplier list',
        build: () {
          when(() => mockService.getSuppliers()).thenAnswer((_) async => [
                _makeSupplier(id: '1', name: 'Fresh Farms'),
                _makeSupplier(id: '2', name: 'City Meats'),
              ]);
          return SupplierCubit(mockService);
        },
        act: (cubit) => cubit.initPage(),
        expect: () => [
          isA<SupplierLoading>(),
          isA<SupplierLoaded>().having(
            (s) => s.suppliers.length,
            'suppliers count',
            2,
          ),
        ],
      );

      blocTest<SupplierCubit, SupplierState>(
        'emits [Loading, Loaded] with empty list when no suppliers',
        build: () {
          when(() => mockService.getSuppliers()).thenAnswer((_) async => []);
          return SupplierCubit(mockService);
        },
        act: (cubit) => cubit.initPage(),
        expect: () => [
          isA<SupplierLoading>(),
          isA<SupplierLoaded>().having(
            (s) => s.suppliers,
            'empty suppliers',
            isEmpty,
          ),
        ],
      );

      blocTest<SupplierCubit, SupplierState>(
        'emits [Loading, Failure] when service throws',
        build: () {
          when(() => mockService.getSuppliers())
              .thenThrow(Exception('network error'));
          return SupplierCubit(mockService);
        },
        act: (cubit) => cubit.initPage(),
        expect: () => [
          isA<SupplierLoading>(),
          isA<SupplierFailure>(),
        ],
      );
    });

    group('onAddSupplier', () {
      blocTest<SupplierCubit, SupplierState>(
        'calls service and reloads on success',
        build: () {
          when(() => mockService.addSupplier(any()))
              .thenAnswer((_) async {});
          when(() => mockService.getSuppliers())
              .thenAnswer((_) async => [_makeSupplier()]);
          return SupplierCubit(mockService);
        },
        act: (cubit) => cubit.onAddSupplier(_makeSupplier()),
        expect: () => [
          isA<SupplierLoading>(),
          isA<SupplierLoading>(),
          isA<SupplierLoaded>(),
        ],
        verify: (_) {
          verify(() => mockService.addSupplier(any())).called(1);
        },
      );

      blocTest<SupplierCubit, SupplierState>(
        'emits Failure when add throws',
        build: () {
          when(() => mockService.addSupplier(any()))
              .thenThrow(Exception('Supplier with this name already exists'));
          return SupplierCubit(mockService);
        },
        act: (cubit) => cubit.onAddSupplier(_makeSupplier()),
        expect: () => [
          isA<SupplierLoading>(),
          isA<SupplierFailure>(),
        ],
      );
    });

    group('onEditSupplier', () {
      blocTest<SupplierCubit, SupplierState>(
        'calls service with old and new supplier then reloads',
        build: () {
          when(() => mockService.updateSupplier(
                oldSupplier: any(named: 'oldSupplier'),
                newSupplier: any(named: 'newSupplier'),
              )).thenAnswer((_) async {});
          when(() => mockService.getSuppliers())
              .thenAnswer((_) async => [_makeSupplier()]);
          return SupplierCubit(mockService);
        },
        act: (cubit) {
          final old = _makeSupplier(name: 'Old Name');
          final updated = _makeSupplier(name: 'New Name');
          return cubit.onEditSupplier(updated, old);
        },
        expect: () => [
          isA<SupplierLoading>(),
          isA<SupplierLoading>(),
          isA<SupplierLoaded>(),
        ],
        verify: (_) {
          verify(() => mockService.updateSupplier(
                oldSupplier: any(named: 'oldSupplier'),
                newSupplier: any(named: 'newSupplier'),
              )).called(1);
        },
      );

      blocTest<SupplierCubit, SupplierState>(
        'emits Failure when edit throws',
        build: () {
          when(() => mockService.updateSupplier(
                oldSupplier: any(named: 'oldSupplier'),
                newSupplier: any(named: 'newSupplier'),
              )).thenThrow(Exception('update failed'));
          return SupplierCubit(mockService);
        },
        act: (cubit) =>
            cubit.onEditSupplier(_makeSupplier(), _makeSupplier()),
        expect: () => [
          isA<SupplierLoading>(),
          isA<SupplierFailure>(),
        ],
      );
    });

    group('onDeleteSupplier', () {
      blocTest<SupplierCubit, SupplierState>(
        'calls service and reloads on success',
        build: () {
          when(() => mockService.deleteSupplier(any()))
              .thenAnswer((_) async {});
          when(() => mockService.getSuppliers())
              .thenAnswer((_) async => []);
          return SupplierCubit(mockService);
        },
        act: (cubit) => cubit.onDeleteSupplier(_makeSupplier()),
        expect: () => [
          isA<SupplierLoading>(),
          isA<SupplierLoading>(),
          isA<SupplierLoaded>(),
        ],
        verify: (_) {
          verify(() => mockService.deleteSupplier(any())).called(1);
        },
      );

      blocTest<SupplierCubit, SupplierState>(
        'emits Failure when delete throws',
        build: () {
          when(() => mockService.deleteSupplier(any()))
              .thenThrow(Exception('delete failed'));
          return SupplierCubit(mockService);
        },
        act: (cubit) => cubit.onDeleteSupplier(_makeSupplier()),
        expect: () => [
          isA<SupplierLoading>(),
          isA<SupplierFailure>(),
        ],
      );
    });
  });
}
