import 'dart:async';

import 'package:daktari/domain/entities/user.dart';
import 'package:daktari/domain/repositories/user_repository.dart';
import 'package:daktari/presentation/bloc/auth/auth_bloc.dart';
import 'package:daktari/presentation/bloc/categories/categories_bloc.dart';
import 'package:daktari/presentation/pages/complete_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockUserRepository users;
  late MockCategoryRepository categories;
  late MockAuthRepository auth;

  setUpAll(() => registerFallbackValue(const ProfileUpdate()));

  setUp(() {
    mockHydratedStorage();
    users = MockUserRepository();
    categories = MockCategoryRepository();
    auth = MockAuthRepository();
    when(() => auth.sessionExpired).thenAnswer((_) => const Stream.empty());
    when(() => categories.categories()).thenAnswer((_) async => [dentistry]);
  });

  Future<AuthBloc> pumpPage(WidgetTester tester) async {
    final authBloc = AuthBloc(
      authRepository: auth,
      userRepository: users,
      notificationRepository: MockNotificationRepository(),
    )..add(const AuthUserChanged(doctor));
    await tester.pumpWidget(
      RepositoryProvider<UserRepository>.value(
        value: users,
        child: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: authBloc),
            BlocProvider(
              create: (_) =>
                  CategoriesBloc(repository: categories)
                    ..add(const CategoriesRequested()),
            ),
          ],
          child: const MaterialApp(home: CompleteProfilePage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return authBloc;
  }

  Future<void> fillAndSave(WidgetTester tester) async {
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Licence number'),
      'KMPDC-1',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Hospital or clinic address'),
      'Aga Khan',
    );
    await tester.tap(find.text('Specialty'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dentist').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }

  testWidgets('explains when the server drops part of the profile', (
    tester,
  ) async {
    when(() => users.updateProfile(any())).thenAnswer(
      (_) async => const User(
        id: 'doctor-2',
        userType: UserType.doctor,
        doctorProfile: DoctorProfile(
          categoryId: 'category-3',
          hospital: 'Aga Khan',
        ),
      ),
    );
    await pumpPage(tester);
    await fillAndSave(tester);

    expect(find.text("Couldn't finish your profile"), findsOneWidget);
    expect(find.text(incompleteProfileMessage), findsOneWidget);
  });

  testWidgets('sends all professional details and completes the profile', (
    tester,
  ) async {
    const complete = User(
      id: 'doctor-2',
      userType: UserType.doctor,
      doctorProfile: DoctorProfile(
        categoryId: 'category-3',
        licenseNumber: 'KMPDC-1',
        hospital: 'Aga Khan',
      ),
    );
    when(() => users.updateProfile(any())).thenAnswer((_) async => complete);
    final authBloc = await pumpPage(tester);
    await fillAndSave(tester);

    verify(
      () => users.updateProfile(
        const ProfileUpdate(
          categoryId: 'category-3',
          licenseNumber: 'KMPDC-1',
          hospital: 'Aga Khan',
        ),
      ),
    ).called(1);
    expect(find.text("Couldn't finish your profile"), findsNothing);
    expect(authBloc.state.user!.hasCompleteDoctorProfile, isTrue);
  });
}
