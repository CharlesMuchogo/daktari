import 'package:daktari/data/network/api_client.dart';
import 'package:daktari/domain/entities/user.dart';
import 'package:daktari/domain/repositories/user_repository.dart';
import 'package:dio/dio.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiClient _api;

  UserRepositoryImpl(this._api);

  @override
  Future<User> me() async =>
      User.fromJson(await _api.get('/users/me') as Map<String, dynamic>);

  @override
  Future<User> updateProfile(ProfileUpdate update) async {
    final photo = update.photoPath;
    final account = update.accountFields;
    final professional = update.professionalFields;

    dynamic latest;
    if (account.isNotEmpty || photo != null) {
      latest = await _api.put(
        '/users/me',
        data: photo == null
            ? account
            : FormData.fromMap({
                ...account,
                'photo': await MultipartFile.fromFile(photo),
              }),
      );
    }
    if (professional.isNotEmpty) {
      latest = await _api.put('/doctors/me', data: professional);
    }

    return latest == null
        ? me()
        : User.fromJson(latest as Map<String, dynamic>);
  }
}
