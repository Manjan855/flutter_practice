import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_practice/core/config/app_config.dart';
import 'package:flutter_practice/core/errors/failures.dart';
import 'package:flutter_practice/features/auth/data/models/user_mapper.dart';
import 'package:flutter_practice/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_practice/features/auth/domain/repositories/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  Future<Either<Failures, UserEntity>> signIn(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(credential.user!.toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(mapAuthError(e.code)));
    } on FirebaseException catch (e) {
      return Left(AuthFailure(e.message ?? 'Authentication failed. Try again.'));
    }
  }

  @override
  Future<Either<Failures, UserEntity>> signUp(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        final name = displayName?.trim();
        if (name != null && name.isNotEmpty) {
          await user.updateDisplayName(name);
          await user.reload();
        }
        return Right(user.toEntity());
      }
      return const Left(AuthFailure('Sign up failed. Try again.'));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(mapAuthError(e.code)));
    } on FirebaseException catch (e) {
      return Left(AuthFailure(e.message ?? 'Sign up failed. Try again.'));
    }
  }

  @override
  Future<Either<Failures, void>> signOut() async {
    // Firebase is authoritative: sign out of it first so a failure in one of
    // the social SDKs can never leave the user stuck in a signed-in state.
    try {
      await _firebaseAuth.signOut();
    } catch (_) {
      return const Left(AuthFailure('Could not sign out. Try again.'));
    }

    // Best effort - these sessions survive a plain Firebase sign-out and would
    // silently re-authenticate the next time the button is pressed.
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Google session cleanup is optional; ignore failures.
    }
    try {
      await FacebookAuth.instance.logOut();
    } catch (_) {
      // Facebook session cleanup is optional; ignore failures.
    }

    return const Right(null);
  }

  @override
  Future<Either<Failures, UserEntity>> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      return Right(userCredential.user!.toEntity());
    } on GoogleSignInException catch (e) {
      return Left(AuthFailure('Google sign-in cancelled: ${e.code}'));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(mapAuthError(e.code)));
    }
  }

  @override
  Future<Either<Failures, UserEntity>> signInWithFacebook() async {
    // Fail fast with an actionable message rather than letting the native SDK
    // reject an empty/placeholder App ID.
    if (!AppConfig.isFacebookConfigured) {
      return const Left(
        AuthFailure(
          'Facebook login is not configured yet. Set FACEBOOK_APP_ID and '
          'FACEBOOK_CLIENT_TOKEN in your .env file (see .env.example), and '
          'the matching values in android/app/src/main/res/values/strings.xml.',
        ),
      );
    }

    try {
      final result = await FacebookAuth.instance.login(
        permissions: const ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success || result.accessToken == null) {
        return Left(
          AuthFailure(
            result.message ?? 'Facebook sign-in was cancelled or failed.',
          ),
        );
      }

      final credential = FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      return Right(userCredential.user!.toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(mapAuthError(e.code)));
    } catch (_) {
      // The native SDK can throw on misconfiguration; never let it escape into
      // an unhandled async error.
      return const Left(
        AuthFailure('Facebook sign-in failed unexpectedly. Try again.'),
      );
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map((u) => u?.toEntity());

  /// Maps Firebase error codes onto user-facing copy.
  static String mapAuthError(String code) => switch (code) {
    'invalid-email' => 'That email address is not valid.',
    'user-disabled' => 'This account has been disabled.',
    'user-not-found' => 'No account found for this email.',
    'wrong-password' => 'Incorrect password.',
    'invalid-credential' => 'Incorrect email or password.',
    'email-already-in-use' => 'That email is already registered.',
    'weak-password' => 'Password must be at least 6 characters.',
    'operation-not-allowed' => 'This sign-in method is disabled in Firebase.',
    'network-request-failed' => 'No internet connection.',
    _ => 'Authentication failed. Try again.',
  };
}
