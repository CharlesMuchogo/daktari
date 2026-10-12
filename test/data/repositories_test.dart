import 'package:daktari/data/network/api_client.dart';
import 'package:daktari/data/repositories/appointment_repository_impl.dart';
import 'package:daktari/data/repositories/auth_repository_impl.dart';
import 'package:daktari/data/repositories/category_repository_impl.dart';
import 'package:daktari/data/repositories/user_repository_impl.dart';
import 'package:daktari/data/social/social_auth.dart';
import 'package:daktari/domain/entities/appointment.dart';
import 'package:daktari/domain/repositories/auth_repository.dart';
import 'package:daktari/domain/repositories/user_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fake_adapter.dart';
import '../helpers/fixtures.dart';
import 'api_client_test.dart' show MemoryTokenStore;

class MockSocialAuth extends Mock implements SocialAuth {}

void main() {
  late FakeAdapter adapter;
  late ApiClient api;

  void respond(FakeResponse Function(RequestOptions options) handler) {
    adapter = FakeAdapter(handler);
    api = ApiClient(
      baseUrl: 'http://api.test/api/v1',
      tokens: MemoryTokenStore(),
      dio: fakeDio(adapter),
      refreshDio: fakeDio(adapter),
    );
  }

  Map<String, dynamic> session() => {
    'token': 'access',
    'refresh_token': 'refresh',
    'user': doctor.toJson(),
  };

  group('AuthRepositoryImpl', () {
    late MockSocialAuth social;

    setUp(() => social = MockSocialAuth());

    test('registers a doctor with personal details only', () async {
      respond((_) => FakeResponse(200, session()));
      await AuthRepositoryImpl(api: api, social: social).register(
        const Registration(
          firstName: ' Jane ',
          lastName: 'Doe',
          email: 'Doc@Example.com',
          phoneNumber: '0700',
          password: 'secret1',
        ),
      );

      expect(adapter.requests.single.path, '/auth/register');
      expect(adapter.requests.single.data, {
        'first_name': 'Jane',
        'last_name': 'Doe',
        'email': 'doc@example.com',
        'phone_number': '0700',
        'password': 'secret1',
        'user_type': 'doctor',
      });
    });

    test('social sign in creates doctor accounts', () async {
      respond((_) => FakeResponse(200, session()));
      when(() => social.signIn(SocialProvider.google)).thenAnswer(
        (_) async => const SocialCredential(token: 'firebase-id-token'),
      );

      await AuthRepositoryImpl(
        api: api,
        social: social,
      ).socialLogin(SocialProvider.google);

      expect(adapter.requests.single.path, '/auth/firebase-login');
      expect(adapter.requests.single.data, containsPair('user_type', 'doctor'));
    });
  });

  group('UserRepositoryImpl', () {
    final doctorJson = doctor.toJson();

    test('saves account and professional details in one update', () async {
      respond((_) => FakeResponse(200, doctorJson));
      final user = await UserRepositoryImpl(api).updateProfile(
        const ProfileUpdate(
          firstName: ' Jane ',
          hospital: ' Aga Khan ',
          licenseNumber: 'KMPDC-1',
        ),
      );

      expect(user, doctor);
      expect(adapter.requests.map((r) => '${r.method} ${r.path}'), [
        'PUT /users/me',
        'PUT /doctors/me',
      ]);
      expect(adapter.requests.first.data, {'first_name': 'Jane'});
      expect(adapter.requests.last.data, {
        'license_number': 'KMPDC-1',
        'hospital': 'Aga Khan',
      });
    });

    test('only calls the endpoint that has changes', () async {
      respond((_) => FakeResponse(200, doctorJson));
      await UserRepositoryImpl(
        api,
      ).updateProfile(const ProfileUpdate(categoryId: 'category-3'));
      expect(adapter.requests.single.path, '/doctors/me');
    });

    test('uploads a photo as multipart form data', () async {
      respond((_) => FakeResponse(200, doctorJson));
      await UserRepositoryImpl(
        api,
      ).updateProfile(const ProfileUpdate(photoPath: 'pubspec.yaml'));

      final data = adapter.requests.single.data as FormData;
      expect(adapter.requests.single.path, '/users/me');
      expect(data.files.single.key, 'photo');
    });

    test('an empty update just reloads the profile', () async {
      respond((_) => FakeResponse(200, doctorJson));
      await UserRepositoryImpl(api).updateProfile(const ProfileUpdate());
      expect(adapter.requests.single.method, 'GET');
      expect(adapter.requests.single.path, '/users/me');
    });
  });

  test('loads specialties', () async {
    respond((_) => FakeResponse(200, [dentistry.toJson()]));
    expect(await CategoryRepositoryImpl(api).categories(), [dentistry]);
  });

  test('changes appointment status through the status endpoint', () async {
    final confirmed = appointment(status: AppointmentStatus.confirmed);
    respond((_) => FakeResponse(200, confirmed.toJson()));

    final result = await AppointmentRepositoryImpl(
      api,
    ).updateStatus('appointment-10', AppointmentStatus.confirmed);

    expect(result, confirmed);
    expect(adapter.requests.single.path, '/appointments/appointment-10/status');
    expect(adapter.requests.single.data, {'status': 'confirmed'});
  });
}
