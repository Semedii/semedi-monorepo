import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:semedi_pos/cubit/reservation/reservation_cubit.dart';
import 'package:semedi_pos/models/reservation.dart';
import 'package:semedi_pos/service/reservation_service.dart';

class MockReservationService extends Mock implements ReservationService {}

Reservation _makeReservation({String id = '1'}) {
  return Reservation(
    id: id,
    guestName: 'Ali Hassan',
    phone: '+252612345678',
    guestCount: 4,
    tableNumber: 5,
    reservedAt: DateTime(2026, 10, 19, 19, 0),
    status: 'upcoming',
  );
}

void main() {
  late MockReservationService mockService;

  setUp(() {
    mockService = MockReservationService();
  });

  group('ReservationCubit', () {
    group('initPage', () {
      blocTest<ReservationCubit, ReservationState>(
        'emits [Loading, Loaded] when service returns reservations',
        build: () {
          when(() => mockService.getTodayReservations())
              .thenAnswer((_) async => [_makeReservation()]);
          return ReservationCubit(mockService);
        },
        act: (cubit) => cubit.initPage(),
        expect: () => [
          isA<ReservationLoading>(),
          isA<ReservationLoaded>(),
        ],
      );

      blocTest<ReservationCubit, ReservationState>(
        'emits [Loading, Loaded] with correct reservations',
        build: () {
          final reservations = [
            _makeReservation(id: '1'),
            _makeReservation(id: '2'),
          ];
          when(() => mockService.getTodayReservations())
              .thenAnswer((_) async => reservations);
          return ReservationCubit(mockService);
        },
        act: (cubit) => cubit.initPage(),
        expect: () => [
          isA<ReservationLoading>(),
          isA<ReservationLoaded>().having(
            (s) => s.reservations.length,
            'reservations count',
            2,
          ),
        ],
      );

      blocTest<ReservationCubit, ReservationState>(
        'emits [Loading, Failure] when service throws',
        build: () {
          when(() => mockService.getTodayReservations())
              .thenThrow(Exception('network error'));
          return ReservationCubit(mockService);
        },
        act: (cubit) => cubit.initPage(),
        expect: () => [
          isA<ReservationLoading>(),
          isA<ReservationFailure>(),
        ],
      );

      blocTest<ReservationCubit, ReservationState>(
        'emits [Loading, Loaded] with empty list when no reservations',
        build: () {
          when(() => mockService.getTodayReservations())
              .thenAnswer((_) async => []);
          return ReservationCubit(mockService);
        },
        act: (cubit) => cubit.initPage(),
        expect: () => [
          isA<ReservationLoading>(),
          isA<ReservationLoaded>().having(
            (s) => s.reservations,
            'empty reservations',
            isEmpty,
          ),
        ],
      );
    });

    group('onAddReservation', () {
      blocTest<ReservationCubit, ReservationState>(
        'calls service and reloads on success',
        build: () {
          when(() => mockService.addReservation(any()))
              .thenAnswer((_) async {});
          when(() => mockService.getTodayReservations())
              .thenAnswer((_) async => [_makeReservation()]);
          return ReservationCubit(mockService);
        },
        act: (cubit) => cubit.onAddReservation(
          guestName: 'Ali Hassan',
          phone: '+252612345678',
          guestCount: 4,
          tableNumber: 5,
          reservedAt: DateTime(2026, 10, 19, 19, 0),
        ),
        expect: () => [
          isA<ReservationLoading>(),
          isA<ReservationLoading>(),
          isA<ReservationLoaded>(),
        ],
        verify: (_) {
          verify(() => mockService.addReservation(any())).called(1);
        },
      );

      blocTest<ReservationCubit, ReservationState>(
        'emits Failure when add throws',
        build: () {
          when(() => mockService.addReservation(any()))
              .thenThrow(Exception('insert failed'));
          return ReservationCubit(mockService);
        },
        act: (cubit) => cubit.onAddReservation(
          guestName: 'Ali Hassan',
          phone: '+252612345678',
          guestCount: 4,
          tableNumber: 5,
          reservedAt: DateTime(2026, 10, 19, 19, 0),
        ),
        expect: () => [
          isA<ReservationLoading>(),
          isA<ReservationFailure>(),
        ],
      );
    });

    group('onSeatGuest', () {
      blocTest<ReservationCubit, ReservationState>(
        'updates status to seated and reloads',
        build: () {
          when(() => mockService.updateReservationStatus('1', 'seated'))
              .thenAnswer((_) async {});
          when(() => mockService.getTodayReservations())
              .thenAnswer((_) async => []);
          return ReservationCubit(mockService);
        },
        act: (cubit) => cubit.onSeatGuest(_makeReservation()),
        verify: (_) {
          verify(() =>
                  mockService.updateReservationStatus('1', 'seated'))
              .called(1);
        },
        expect: () => [
          isA<ReservationLoading>(),
          isA<ReservationLoading>(),
          isA<ReservationLoaded>(),
        ],
      );
    });

    group('onCancelReservation', () {
      blocTest<ReservationCubit, ReservationState>(
        'updates status to cancelled and reloads',
        build: () {
          when(() => mockService.updateReservationStatus('1', 'cancelled'))
              .thenAnswer((_) async {});
          when(() => mockService.getTodayReservations())
              .thenAnswer((_) async => []);
          return ReservationCubit(mockService);
        },
        act: (cubit) => cubit.onCancelReservation(_makeReservation()),
        verify: (_) {
          verify(() =>
                  mockService.updateReservationStatus('1', 'cancelled'))
              .called(1);
        },
        expect: () => [
          isA<ReservationLoading>(),
          isA<ReservationLoading>(),
          isA<ReservationLoaded>(),
        ],
      );
    });

    group('onDeleteReservation', () {
      blocTest<ReservationCubit, ReservationState>(
        'deletes reservation and reloads',
        build: () {
          when(() => mockService.deleteReservation('1'))
              .thenAnswer((_) async {});
          when(() => mockService.getTodayReservations())
              .thenAnswer((_) async => []);
          return ReservationCubit(mockService);
        },
        act: (cubit) => cubit.onDeleteReservation(_makeReservation()),
        verify: (_) {
          verify(() => mockService.deleteReservation('1')).called(1);
        },
        expect: () => [
          isA<ReservationLoading>(),
          isA<ReservationLoading>(),
          isA<ReservationLoaded>(),
        ],
      );
    });
  });
}
