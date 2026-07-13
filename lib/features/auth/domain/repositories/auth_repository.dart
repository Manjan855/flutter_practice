import 'package:dartz/dartz.dart';
import 'package:flutter_application_1/core/errors/failures.dart';
import 'package:flutter_application_1/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failures, UserEntity>> signIn(String email, String password);
  Future<Either<Failures, UserEntity>> signUp(String email, String password);
  Future<Either<Failures, void>> signOut();
  Stream<UserEntity?> get authStateChanges;
}