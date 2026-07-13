import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/core/errors/failures.dart';
import 'package:flutter_application_1/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl  extends AuthRepository{
  final FirebaseAuth _firebaseAuth;
  AuthRepositoryImpl(this._firebaseAuth);
  @override
 Future<Either<Failures, UserEntity>> signIn(String email, String password)async{
  try{
    final cred = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return Right(cred.user!.toEntity());
  } on firebaseAuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.code)));
  
 } 
 }
  
}