import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_practice/features/auth/data/repositories/auth_repository_impl.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth{}
class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main(){
  late MockFirebaseAuth mockFirebaseAuth;
  late AuthRepositoryImpl repository;
}
 setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    repository = AuthRepositoryImpl(mockFirebaseAuth);
  })