// repositories/dummy_auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_practice/core/errors/failures.dart';
import '../entities/dummy_user_entity.dart';

abstract class DummyAuthRepository {
  Future<Either<Failures, DummyUserEntity>> login(
    String username,
    String password,
  );
  Future<Either<Failures, DummyUserEntity>> getCurrentUser();
  Future<void> logout();
}
