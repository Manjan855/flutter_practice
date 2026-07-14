import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_practice/core/errors/failures.dart';
import 'package:flutter_practice/features/auth/data/models/user_mapper.dart';
import 'package:flutter_practice/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_practice/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl  extends AuthRepository{
  final FirebaseAuth _firebaseAuth;
  AuthRepositoryImpl(this._firebaseAuth) : super(_firebaseAuth) ;
  @override
 Future<Either<Failures, UserEntity>> signIn(String email, String password)async{
  try{
    final cred = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return Right(cred.user!.toEntity());
  } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.code)));
  
 } 
 }
@override 
Future<Either<Failures, UserEntity>> signUp(String email, String password) async{
  try{
    final cred = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return Right(cred.user!.toEntity());
  }on FirebaseAuthException catch (e){
    return Left(AuthFailure(_mapAuthError(e.code)));
  }
}
@override
Future<Either<Failures,void>> signOut()async{
 try {
   await _firebaseAuth.signOut();
  return const Right(null);
 } catch (e) {
   return Left(AuthFailure('failed to signOut'));
 } 
  
}

  String _mapAuthError(String code) => switch (code){
    'user-not-found'=> 'No account found for this email',
    'wrong password'=> 'Incorrect password',
    'Email-already-in-use' => 'Email already registered',
    'weak-password'=> 'password is too weak at least 6 char',
    _ => 'Authenticaton failed. Try again.',
  };
  @override
  Stream<UserEntity?> get authStateChanges => _firebaseAuth.authStateChanges().map((u)=> u?.toEntity());
}
