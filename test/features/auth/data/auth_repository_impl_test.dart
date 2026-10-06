import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_practice/core/errors/failures.dart';
import 'package:flutter_practice/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

/// Lets `any()` be used for `AuthCredential` parameters, which have no
/// default constructor mocktail could build on its own.
class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  setUpAll(() => registerFallbackValue(FakeAuthCredential()));

  late MockFirebaseAuth mockFirebaseAuth;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    repository = AuthRepositoryImpl(mockFirebaseAuth);
  });

  MockUser stubSignedInUser({
    String uid = 'test-uid-123',
    String? email = 'test@example.com',
    String? displayName,
  }) {
    final user = MockUser();
    when(() => user.uid).thenReturn(uid);
    when(() => user.email).thenReturn(email);
    when(() => user.displayName).thenReturn(displayName);
    return user;
  }

  group('signIn', () {
    test('returns Right(UserEntity) when Firebase sign-in succeeds', () async {
      final mockUser = stubSignedInUser();
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(mockUser);
      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => mockCredential);

      final result = await repository.signIn('test@example.com', 'password123');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected Right, got Left: ${failure.message}'),
        (user) {
          expect(user.uid, 'test-uid-123');
          expect(user.email, 'test@example.com');
        },
      );
    });

    test(
      'returns Left(AuthFailure) with a friendly message on wrong-password',
      () async {
        when(
          () => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

        final result = await repository.signIn(
          'test@example.com',
          'wrongpass',
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, 'Incorrect password.');
          },
          (_) => fail('Expected Left, got Right'),
        );
      },
    );
  });

  group('signUp', () {
    test('creates the account and stores the display name', () async {
      final mockUser = stubSignedInUser();
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(mockUser);
      when(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => mockCredential);
      when(() => mockUser.updateDisplayName('Ada Lovelace'))
          .thenAnswer((_) async {});
      when(() => mockUser.reload()).thenAnswer((_) async {});

      final result = await repository.signUp(
        'ada@example.com',
        's3cret!',
        displayName: 'Ada Lovelace',
      );

      expect(result.isRight(), isTrue);
      verify(() => mockUser.updateDisplayName('Ada Lovelace')).called(1);
      verify(() => mockUser.reload()).called(1);
    });

    test('skips the profile update when no display name is given', () async {
      final mockUser = stubSignedInUser();
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(mockUser);
      when(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => mockCredential);

      final result = await repository.signUp('ada@example.com', 's3cret!');

      expect(result.isRight(), isTrue);
      verifyNever(() => mockUser.updateDisplayName(any()));
      verifyNever(() => mockUser.reload());
    });

    test('maps email-already-in-use to a helpful message', () async {
      when(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      final result = await repository.signUp('ada@example.com', 's3cret!');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) =>
            expect(failure.message, 'That email is already registered.'),
        (_) => fail('Expected Left, got Right'),
      );
    });
  });

  group('signInWithFacebook', () {
    test(
      'fails fast with a configuration hint when credentials are missing',
      () async {
        // No Facebook credentials are configured in the test environment, and
        // no platform channel is set up - the guard must return before any
        // native SDK call happens.
        final result = await repository.signInWithFacebook();

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, contains('not configured'));
            expect(failure.message, contains('FACEBOOK_APP_ID'));
          },
          (_) => fail('Expected Left, got Right'),
        );

        verifyNever(() => mockFirebaseAuth.signInWithCredential(any()));
      },
    );
  });

  group('mapAuthError', () {
    const expected = {
      'invalid-email': 'That email address is not valid.',
      'user-disabled': 'This account has been disabled.',
      'user-not-found': 'No account found for this email.',
      'wrong-password': 'Incorrect password.',
      'invalid-credential': 'Incorrect email or password.',
      'email-already-in-use': 'That email is already registered.',
      'weak-password': 'Password must be at least 6 characters.',
      'operation-not-allowed': 'This sign-in method is disabled in Firebase.',
      'network-request-failed': 'No internet connection.',
    };

    expected.forEach((code, message) {
      test('maps "$code"', () {
        expect(AuthRepositoryImpl.mapAuthError(code), message);
      });
    });

    test('falls back to a generic message for unknown codes', () {
      expect(
        AuthRepositoryImpl.mapAuthError('some-future-code'),
        'Authentication failed. Try again.',
      );
    });
  });
}
