import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_practice/core/errors/failures.dart';
import 'package:flutter_practice/features/auth/domain/entities/user_entity.dart';
import 'package:google_sign_in/testing.dart';

abstract class AuthRepository {
  AuthRepository(FirebaseAuth instance);

  Future<Either<Failures, UserEntity>> signIn(String email, String password);
  Future<Either<Failures, UserEntity>> signUp(String email, String password);
  Future<Either<Failures, UserEntity>> signInWithGoogle();
  Future<Either<Failures, void>> signOut();
  Stream<UserEntity?> get authStateChanges;
}
