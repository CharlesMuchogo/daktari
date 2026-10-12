import 'dart:io';

import 'package:daktari/app.dart';
import 'package:daktari/dependencies.dart';
import 'package:daktari/presentation/bloc/auth/auth_bloc.dart';
import 'package:daktari/presentation/navigation/chat_router.dart';
import 'package:daktari/presentation/pages/chat_page.dart';
import 'package:daktari/presentation/pages/home_shell.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:integration_test/integration_test.dart';

Future<void> waitFor(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 100; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> tapAndWait(
  WidgetTester tester,
  Finder tap,
  Finder expected,
) async {
  await tester.tap(tap.first);
  await waitFor(tester, expected);
  await settle(tester);
}

Future<void> fill(WidgetTester tester, String label, String text) async {
  final field = find.widgetWithText(TextFormField, label);
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
}

Future<String> bookAsPatient(String doctorId, String stamp) async {
  final api = Dio(BaseOptions(baseUrl: '${Dependencies.apiBaseUrl}/api/v1'));
  final session = await api.post<Map<String, dynamic>>(
    '/auth/register',
    data: {
      'email': 'patient$stamp@example.com',
      'first_name': 'Amina',
      'last_name': 'Wanjiru',
      'password': 'secret1',
      'user_type': 'patient',
    },
  );
  api.options.headers['Authorization'] = 'Bearer ${session.data!['token']}';
  var day = DateTime.now().add(const Duration(days: 1));
  while (day.weekday > DateTime.friday) {
    day = day.add(const Duration(days: 1));
  }
  final date =
      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  await api.post<dynamic>(
    '/appointments',
    data: {'doctor_id': doctorId, 'date': date, 'time': '10:00'},
  );
  return 'Amina Wanjiru';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'a doctor signs up, completes onboarding and handles an appointment',
    (tester) async {
      final stamp = '${DateTime.now().microsecondsSinceEpoch}';
      await Firebase.initializeApp();
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: HydratedStorageDirectory(
          (await Directory.systemTemp.createTemp()).path,
        ),
      );
      final dependencies = Dependencies.create();
      await dependencies.auth.logout();

      await tester.pumpWidget(App(dependencies: dependencies));
      await waitFor(tester, find.text('Health Is Wealth'));
      expect(find.text('Continue with Google'), findsOneWidget);

      await tapAndWait(
        tester,
        find.text('Sign up'),
        find.text('Create your doctor account'),
      );
      expect(find.text('Continue with Google'), findsNothing);
      expect(find.text('Licence number'), findsNothing);

      await fill(tester, 'First name', 'Wanjiku');
      await fill(tester, 'Last name', 'Kamau');
      await fill(tester, 'Email', 'doctor$stamp@example.com');
      await fill(tester, 'Phone number', '0711000000');
      await fill(tester, 'Create password', 'secret1');
      await fill(tester, 'Confirm password', 'secret1');
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Sign up'));
      await tapAndWait(
        tester,
        find.widgetWithText(FilledButton, 'Sign up'),
        find.text('Complete your profile'),
      );

      await fill(tester, 'Licence number', 'KMPDC-$stamp');
      await fill(tester, 'Hospital or clinic address', 'Aga Khan, Nairobi');
      await tester.tap(find.text('Specialty'));
      await settle(tester);
      await tester.tap(find.text('Dentist').last);
      await settle(tester);
      await tapAndWait(tester, find.text('Continue'), find.text('Dr. Wanjiku'));

      final doctorId = tester
          .element(find.byType(HomeShell))
          .read<AuthBloc>()
          .state
          .user!
          .id;
      final patientName = await bookAsPatient(doctorId, stamp);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, 400));
      await waitFor(tester, find.text(patientName));
      await settle(tester);

      await tapAndWait(
        tester,
        find.text(patientName),
        find.text('Confirm appointment'),
      );
      await tapAndWait(
        tester,
        find.text('Confirm appointment'),
        find.text('Do you want to confirm the appointment?'),
      );
      await tapAndWait(
        tester,
        find.widgetWithText(FilledButton, 'Confirm appointment').last,
        find.text('Confirmed'),
      );
      expect(find.text('Confirm appointment'), findsNothing);
      expect(find.text('Cancel appointment'), findsOneWidget);

      await tapAndWait(
        tester,
        find.text('Message patient'),
        find.widgetWithText(TextField, 'Message'),
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Message'),
        'See you tomorrow',
      );
      ChatRouter.messengerKey.currentState!.clearSnackBars();
      await settle(tester);
      await tester.tap(find.byIcon(Icons.send_rounded));
      final bubble = find.widgetWithText(MessageBubble, 'See you tomorrow');
      await waitFor(tester, bubble);
      await waitFor(
        tester,
        find.descendant(of: bubble, matching: find.textContaining(':')),
      );

      ChatRouter.navigatorKey.currentState!.popUntil((route) => route.isFirst);
      await settle(tester);
      await tapAndWait(
        tester,
        find.text('Messages'),
        find.text('You: See you tomorrow'),
      );
      await tapAndWait(
        tester,
        find.text('History'),
        find.text('Treatment history'),
      );
      await tapAndWait(tester, find.text('Profile'), find.text('KMPDC-$stamp'));
      expect(find.text('Dentist'), findsWidgets);
      await tester.dragUntilVisible(
        find.text('Log out'),
        find.byType(ListView).last,
        const Offset(0, -300),
      );
      await tester.ensureVisible(find.text('Log out'));
      await settle(tester);
      await tapAndWait(
        tester,
        find.text('Log out'),
        find.text('Do you want to log out?'),
      );
      await tapAndWait(
        tester,
        find.widgetWithText(FilledButton, 'Log out'),
        find.text('Health Is Wealth'),
      );
    },
  );
}
