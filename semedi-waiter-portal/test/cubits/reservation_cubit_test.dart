import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:semedi/cubits/reservation/reservation_cubit.dart';
import 'package:semedi/models/reservation.dart';
import 'package:semedi/services/reservation_service.dart';

class MockReservationService extends Mock implements ReservationService {}

Reservation _makeReservation({String id = 'r1'}) {
  return Reservation(
    id: id,
    guestName: 'Farhan Osman',
    phone: '+252615000001',
    guestCount: 2,
    tableNumber: 3,
    reservedAt: DateTime(2026, 10, 19, 18, 30),
    status: 'upcoming',
  );
}

void main() {
  late MockReservationService mockService;

  setUp(() {
    mockService = MockReservationService();
  });

  group('ReservationCubit (waiter portal)', () {
    group('initPage', () {
      blocTest<ReservationCubit, ReservationState>(
        'emits [Loading, Loaded] on success',
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
        'loaded state carries correct reservations',
        build: () {
          when(() => mockService.getTodayReservations()).thenAnswer(
            (_) async => [
              _makeReservation(id: 'r1'),
              _makeReservation(id: 'r2'),
              _makeReservation(id: 'r3'),
            ],
          );
          return ReservationCubit(mockService);
        },
        act: (cubit) => cubit.initPage(),
        expect: () => [
          isA<ReservationLoading>(),
          isA<ReservationLoaded>().having(
            (s) => s.reservations.length,
            'count',
            3,
          ),
        ],
      );

      blocTest<ReservationCubit, ReservationState>(
        'emits [Loading, Failure] when service throws',
        build: () {
          when(() => mockService.getTodayReservations())
              .thenThrow(Exception('connection timeout'));
          return ReservationCubit(mockService);
        },
        act: (cubit) => cubit.initPage(),
        expect: () => [
          isA<ReservationLoading>(),
          isA<ReservationFailure>(),
        ],
      );

      blocTest<ReservationCubit, ReservationState>(
        'emits empty Loaded when no reservations today',
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
            'reservations',
            isEmpty,
          ),
        ],
      );
    });

    group('onSeatGuest', () {
      blocTest<ReservationCubit, ReservationState>(
        'calls updateReservationStatus with seated and reloads',
        build: () {
          when(() => mockService.updateReservationStatus('r1', 'seated'))
              .thenAnswer((_) async {});
          when(() => mockService.getTodayReservations())
              .thenAnswer((_) async => []);
          return ReservationCubit(mockService);
        },
        act: (cubit) => cubit.onSeatGuest(_makeReservation()),
        verify: (_) {
          verify(() =>
                  mockService.updateReservationStatus('r1', 'seated'))
              .called(1);
        },
        expect: () => [
          isA<ReservationLoading>(),
          isA<ReservationLoading>(),
          isA<ReservationLoaded>(),
        ],
      );

      blocTest<ReservationCubit, ReservationState>(
        'emits Failure when seat throws',
        build: () {
          when(() => mockService.updateReservationStatus(any(), any()))
              .thenThrow(Exception('update failed'));
          return ReservationCubit(mockService);
        },
        act: (cubit) => cubit.onSeatGuest(_makeReservation()),
        expect: () => [
          isA<ReservationLoading>(),
          isA<ReservationFailure>(),
        ],
      );
    });

    group('onCancelReservation', () {
      blocTest<ReservationCubit, ReservationState>(
        'calls updateReservationStatus with cancelled and reloads',
        build: () {
          when(() => mockService.updateReservationStatus('r1', 'cancelled'))
              .thenAnswer((_) async {});
          when(() => mockService.getTodayReservations())
              .thenAnswer((_) async => []);
          return ReservationCubit(mockService);
        },
        act: (cubit) => cubit.onCancelReservation(_makeReservation()),
        verify: (_) {
          verify(() =>
                  mockService.updateReservationStatus('r1', 'cancelled'))
              .called(1);
        },
        expect: () => [
          isA<ReservationLoading>(),
          isA<ReservationLoading>(),
          isA<ReservationLoaded>(),
        ],
      );

      blocTest<ReservationCubit, ReservationState>(
        'emits Failure when cancel throws',
        build: () {
          when(() => mockService.updateReservationStatus(any(), any()))
              .thenThrow(Exception('cancel failed'));
          return ReservationCubit(mockService);
        },
        act: (cubit) => cubit.onCancelReservation(_makeReservation()),
        expect: () => [
          isA<ReservationLoading>(),
          isA<ReservationFailure>(),
        ],
      );
    });
  });
}
