// models/dummy_user_model.dart
import '../../domain/entities/dummy_user_entity.dart';

class DummyUserModel extends DummyUserEntity {
  const DummyUserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.image,
  });

  factory DummyUserModel.fromJson(Map<String, dynamic> json) => DummyUserModel(
    id: json['id'] as int? ?? 0,
    username: json['username'] as String? ?? '',
    email: json['email'] as String? ?? '',
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    image: json['image'] as String? ?? '',
  );
}
