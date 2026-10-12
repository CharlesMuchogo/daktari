import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daktari/domain/app_exception.dart';
import 'package:daktari/domain/repositories/auth_repository.dart';
import 'package:daktari/presentation/bloc/auth/auth_bloc.dart';
import 'package:daktari/presentation/bloc/status.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockAuthRepository auth;
  late MockUserRepository users;
  late MockNotificationRepository notifications;
  late StreamController<void> expiry;

  setUpAll(() {
    registerFallbackValue(SocialProvider.google);
  });

  setUp(() {
    mockHydratedStorage();
    auth = MockAuthRepository();
    users = MockUserRepository();
    notifications = MockNotificationRepository();
    expiry = StreamController<void>.broadcast();
    when(() => auth.sessionExpired).thenAnswer((_) => expiry.stream);
  });

  tearDown(() => expiry.close());

  AuthBloc build() => AuthBloc(
    authRepository: auth,
    userRepository: users,
    notificationRepository: notifications,
  );

  blocTest<AuthBloc, AuthState>(
    'starts unauthenticated without a stored session',
    setUp: () => when(() => auth.hasSession()).thenAnswer((_) async => false),
    build: build,
    act: (bloc) => bloc.add(const AuthStarted()),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
  );

  blocTest<AuthBloc, AuthState>(
    'restores a stored session and refreshes the user',
    setUp: () {
      when(() => auth.hasSession()).thenAnswer((_) async => true);
      when(() => users.me()).thenAnswer((_) async => doctor);
    },
    build: build,
    act: (bloc) => bloc.add(const AuthStarted()),
    expect: () => [
      const AuthState(status: AuthStatus.authenticated, action: Status.loading),
      const AuthState(
        status: AuthStatus.authenticated,
        user: doctor,
        action: Status.loaded,
      ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'keeps the session when refreshing the user fails offline',
    setUp: () {
      when(() => auth.hasSession()).thenAnswer((_) async => true);
      when(() => users.me()).thenThrow(const AppException('offline'));
    },
    build: build,
    seed: () => const AuthState(status: AuthStatus.authenticated, user: doctor),
    act: (bloc) => bloc.add(const AuthStarted()),
    expect: () => [
      const AuthState(
        status: AuthStatus.authenticated,
        user: doctor,
        action: Status.loading,
      ),
      const AuthState(
        status: AuthStatus.authenticated,
        user: doctor,
        action: Status.failure,
        message: 'offline',
      ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'logs in with email',
    setUp: () => when(
      () => auth.login(email: 'doc@example.com', password: 'secret1'),
    ).thenAnswer((_) async => doctor),
    build: build,
    seed: () => const AuthState(status: AuthStatus.unauthenticated),
    act: (bloc) => bloc.add(
      const LoginRequested(email: 'doc@example.com', password: 'secret1'),
    ),
    expect: () => [
      const AuthState(
        status: AuthStatus.unauthenticated,
        action: Status.loading,
        method: AuthMethod.email,
      ),
      const AuthState(
        status: AuthStatus.authenticated,
        user: doctor,
        action: Status.loaded,
        method: AuthMethod.email,
      ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'reports login failures',
    setUp: () => when(
      () => auth.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const AppException('Invalid credentials')),
    build: build,
    seed: () => const AuthState(status: AuthStatus.unauthenticated),
    act: (bloc) => bloc.add(const LoginRequested(email: 'x', password: 'y')),
    skip: 1,
    expect: () => [
      const AuthState(
        status: AuthStatus.unauthenticated,
        action: Status.failure,
        method: AuthMethod.email,
        message: 'Invalid credentials',
      ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'a cancelled social login goes back to idle',
    setUp: () =>
        when(() => auth.socialLogin(any())).thenAnswer((_) async => null),
    build: build,
    seed: () => const AuthState(status: AuthStatus.unauthenticated),
    act: (bloc) => bloc.add(const SocialLoginRequested(SocialProvider.google)),
    expect: () => [
      const AuthState(
        status: AuthStatus.unauthenticated,
        action: Status.loading,
        method: AuthMethod.google,
      ),
      const AuthState(
        status: AuthStatus.unauthenticated,
        action: Status.initial,
        method: AuthMethod.google,
      ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'logging out unregisters push before ending the session',
    setUp: () {
      when(() => notifications.unregister()).thenAnswer((_) async {});
      when(() => auth.logout()).thenAnswer((_) async {});
    },
    build: build,
    seed: () => const AuthState(status: AuthStatus.authenticated, user: doctor),
    act: (bloc) => bloc.add(const LogoutRequested()),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
    verify: (_) =>
        verifyInOrder([() => notifications.unregister(), () => auth.logout()]),
  );

  blocTest<AuthBloc, AuthState>(
    'signs out when the session expires',
    build: build,
    seed: () => const AuthState(status: AuthStatus.authenticated, user: doctor),
    act: (_) => expiry.add(null),
    expect: () => [
      const AuthState(
        status: AuthStatus.unauthenticated,
        message: 'Your session has expired. Sign in again.',
      ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'turns away a patient account that signs in',
    setUp: () {
      when(
        () => auth.login(email: 'pat@example.com', password: 'secret1'),
      ).thenAnswer((_) async => patient);
      when(() => auth.logout()).thenAnswer((_) async {});
    },
    build: build,
    seed: () => const AuthState(status: AuthStatus.unauthenticated),
    act: (bloc) => bloc.add(
      const LoginRequested(email: 'pat@example.com', password: 'secret1'),
    ),
    skip: 1,
    expect: () => [
      const AuthState(
        status: AuthStatus.unauthenticated,
        action: Status.failure,
        method: AuthMethod.email,
        message: notADoctorMessage,
      ),
    ],
    verify: (_) => verify(() => auth.logout()).called(1),
  );

  blocTest<AuthBloc, AuthState>(
    'signs out a stored patient session on start',
    setUp: () {
      when(() => auth.hasSession()).thenAnswer((_) async => true);
      when(() => users.me()).thenAnswer((_) async => patient);
      when(() => auth.logout()).thenAnswer((_) async {});
    },
    build: build,
    act: (bloc) => bloc.add(const AuthStarted()),
    skip: 1,
    expect: () => [
      const AuthState(
        status: AuthStatus.unauthenticated,
        message: notADoctorMessage,
      ),
    ],
  );

  test('persists the session and user but not transient fields', () {
    final bloc = build();
    const state = AuthState(
      status: AuthStatus.authenticated,
      user: doctor,
      action: Status.failure,
      message: 'boom',
    );
    expect(
      bloc.fromJson(bloc.toJson(state)!),
      const AuthState(status: AuthStatus.authenticated, user: doctor),
    );
    expect(bloc.toJson(const AuthState()), isNull);
  });
}
