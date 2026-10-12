import 'package:daktari/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

class ProfileUpdate extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? photoPath;
  final String? categoryId;
  final String? licenseNumber;
  final String? hospital;
  final String? description;

  const ProfileUpdate({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.photoPath,
    this.categoryId,
    this.licenseNumber,
    this.hospital,
    this.description,
  });

  Map<String, String> get accountFields => _present({
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
  });

  Map<String, String> get professionalFields => _present({
    'category_id': categoryId,
    'license_number': licenseNumber,
    'hospital': hospital,
    'description': description,
  });

  static Map<String, String> _present(Map<String, String?> fields) => {
    for (final MapEntry(:key, :value) in fields.entries)
      if (value != null) key: value.trim(),
  };

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    phoneNumber,
    photoPath,
    categoryId,
    licenseNumber,
    hospital,
    description,
  ];
}

abstract class UserRepository {
  Future<User> me();

  Future<User> updateProfile(ProfileUpdate update);
}
