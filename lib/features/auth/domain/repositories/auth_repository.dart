import 'package:dartz/dartz.dart';
import 'package:flutter_practice/core/errors/failures.dart';
import 'package:flutter_practice/features/auth/domain/entities/user_entity.dart';

/// Contract the auth feature is programmed against.
///
/// Presentation code depends on this abstraction; `AuthRepositoryImpl` is the
/// only concrete implementation and is bound to it by a Riverpod provider.
abstract class AuthRepository {
  Future<Either<Failures, UserEntity>> signIn(String email, String password);

  /// Creates an account. [displayName] is optional profile data captured on
  /// the sign-up form.
  Future<Either<Failures, UserEntity>> signUp(
    String email,
    String password, {
    String? displayName,
  });

  Future<Either<Failures, UserEntity>> signInWithGoogle();

  Future<Either<Failures, UserEntity>> signInWithFacebook();

  Future<Either<Failures, void>> signOut();

  Stream<UserEntity?> get authStateChanges;
}
