import 'package:bloc_test/bloc_test.dart';
import 'package:daktari/domain/app_exception.dart';
import 'package:daktari/domain/entities/appointment.dart';
import 'package:daktari/presentation/bloc/appointments/appointments_bloc.dart';
import 'package:daktari/presentation/bloc/categories/categories_bloc.dart';
import 'package:daktari/presentation/bloc/status.dart';
import 'package:daktari/presentation/pages/appointment_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockAppointmentRepository repository;
  final now = DateTime(2026, 10, 14, 12);
  final past = appointment(id: 'appointment-1', date: '2026-10-01');
  final upcoming = appointment(id: 'appointment-2', date: '2026-10-20');
  final cancelled = appointment(
    id: 'appointment-3',
    date: '2026-10-21',
    status: AppointmentStatus.cancelled,
  );

  setUp(() {
    mockHydratedStorage();
    repository = MockAppointmentRepository();
  });

  group('AppointmentsBloc', () {
    blocTest<AppointmentsBloc, AppointmentsState>(
      'confirms an appointment',
      setUp: () =>
          when(
            () => repository.updateStatus(
              'appointment-2',
              AppointmentStatus.confirmed,
            ),
          ).thenAnswer(
            (_) async => upcoming.copyWith(status: AppointmentStatus.confirmed),
          ),
      build: () => AppointmentsBloc(repository: repository),
      seed: () =>
          AppointmentsState(status: Status.loaded, appointments: [upcoming]),
      act: (bloc) => bloc.add(
        const AppointmentStatusChangeRequested(
          'appointment-2',
          AppointmentStatus.confirmed,
        ),
      ),
      skip: 1,
      expect: () => [
        AppointmentsState(
          status: Status.loaded,
          appointments: [
            upcoming.copyWith(status: AppointmentStatus.confirmed),
          ],
          action: Status.loaded,
        ),
      ],
    );

    blocTest<AppointmentsBloc, AppointmentsState>(
      'reports a rejected status change without losing data',
      setUp: () => when(
        () => repository.updateStatus(any(), AppointmentStatus.completed),
      ).thenThrow(const AppException('This status change is not allowed')),
      build: () => AppointmentsBloc(repository: repository),
      seed: () =>
          AppointmentsState(status: Status.loaded, appointments: [upcoming]),
      act: (bloc) => bloc.add(
        const AppointmentStatusChangeRequested(
          'appointment-2',
          AppointmentStatus.completed,
        ),
      ),
      skip: 1,
      expect: () => [
        AppointmentsState(
          status: Status.loaded,
          appointments: [upcoming],
          action: Status.failure,
          message: 'This status change is not allowed',
        ),
      ],
    );

    test('splits upcoming from history, newest history first', () {
      final state = AppointmentsState(
        appointments: [past, upcoming, cancelled],
      );
      expect(state.upcomingAt(now), [upcoming]);
      expect(state.historyAt(now), [cancelled, past]);
    });

    test('searches every term across the given text', () {
      final state = AppointmentsState(
        appointments: [past, upcoming, cancelled],
      );
      String text(Appointment a) => '${a.id} ${a.status.name} ${a.date}';

      expect(state.matching('cancelled', text).map((a) => a.id), [
        'appointment-3',
      ]);
      expect(state.matching('PENDING 2026-10-20', text).map((a) => a.id), [
        'appointment-2',
      ]);
      expect(state.matching('  ', text), hasLength(3));
    });
  });

  group('DoctorAction', () {
    List<DoctorAction> actions(Appointment a) =>
        DoctorAction.availableFor(a, now);

    test('a pending upcoming appointment can be confirmed or cancelled', () {
      expect(actions(upcoming), [DoctorAction.confirm, DoctorAction.cancel]);
    });

    test('a confirmed upcoming appointment can only be cancelled', () {
      expect(actions(upcoming.copyWith(status: AppointmentStatus.confirmed)), [
        DoctorAction.cancel,
      ]);
    });

    test('an appointment that has started can be completed', () {
      expect(actions(past.copyWith(status: AppointmentStatus.confirmed)), [
        DoctorAction.complete,
        DoctorAction.cancel,
      ]);
    });

    test('finished and cancelled appointments can be removed', () {
      expect(actions(cancelled), [DoctorAction.remove]);
      expect(actions(past.copyWith(status: AppointmentStatus.completed)), [
        DoctorAction.remove,
      ]);
    });
  });

  group('CategoriesBloc', () {
    late MockCategoryRepository categories;

    setUp(() => categories = MockCategoryRepository());

    blocTest<CategoriesBloc, CategoriesState>(
      'loads specialties for the profile forms',
      setUp: () => when(
        () => categories.categories(),
      ).thenAnswer((_) async => [dentistry]),
      build: () => CategoriesBloc(repository: categories),
      act: (bloc) => bloc.add(const CategoriesRequested()),
      expect: () => [
        const CategoriesState(status: Status.loading),
        const CategoriesState(status: Status.loaded, categories: [dentistry]),
      ],
    );
  });
}
