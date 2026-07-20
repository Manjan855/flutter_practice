import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_practice/core/errors/failures.dart';
import 'package:flutter_practice/features/auth/data/models/user_mapper.dart';
import 'package:flutter_practice/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_practice/features/auth/domain/repositories/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  AuthRepositoryImpl(this._firebaseAuth);

  @override
  Future<Either<Failures, UserEntity>> signIn(String email, String password) async {
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return Right(cred.user!.toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.code)));
    }
  }

  @override
  Future<Either<Failures, UserEntity>> signUp(String email, String password) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return Right(cred.user!.toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.code)));
    }
  }

  @override
  Future<Either<Failures, void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('failed to signOut'));
    }
  }

  @override
  Future<Either<Failures, UserEntity>> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return Right(userCredential.user!.toEntity());
    } on GoogleSignInException catch (e) {
      return Left(AuthFailure('Google sign-in cancelled: ${e.code}'));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.code)));
    }
  }

  @override
  Future<Either<Failures, UserEntity>> signInWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );
      if (result.status != LoginStatus.success) {
        return Left(AuthFailure('Facebook sign-in cancelled or failed'));
      }
      final accessToken = result.accessToken!;
      final credential = FacebookAuthProvider.credential(accessToken.tokenString);
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return Right(userCredential.user!.toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.code)));
    }
  }

  String _mapAuthError(String code) => switch (code) {
    'user-not-found' => 'No account found for this email',
    'wrong-password' => 'Incorrect password',
    'email-already-in-use' => 'Email already registered',
    'weak-password' => 'Password is too weak, at least 6 characters',
    _ => 'Authentication failed. Try again.',
  };

  @override
  Stream<UserEntity?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map((u) => u?.toEntity());
}