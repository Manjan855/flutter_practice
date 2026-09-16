import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_practice/features/auth/data/repositories/auth_repository_impl.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    repository = AuthRepositoryImpl(mockFirebaseAuth);
  });

  group('signIn', () {
    test('returns Right(UserEntity) when Firebase sign-in succeeds', () async {
      final mockUser = MockUser();
      final mockCredential = MockUserCredential();

      when(() => mockUser.uid).thenReturn('test-uid-123');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockUser.displayName).thenReturn(null);
      when(() => mockCredential.user).thenReturn(mockUser);
      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => mockCredential);

      final result = await repository.signIn('test@example.com', 'password123');

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right, got Left: ${failure.message}'),
        (user) => expect(user.uid, 'test-uid-123'),
      );
    });

    test(
      'returns Left(AuthFailure) with correct message on wrong-password',
      () async {
        when(
          () => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

        final result = await repository.signIn('test@example.com', 'wrongpass');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, 'Incorrect password'),
          (user) => fail('Expected Left, got Right'),
        );
      },
    );
  });
}
