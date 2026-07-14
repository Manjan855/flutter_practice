import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_practice/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_practice/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_practice/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref){
  return AuthRepositoryImpl(FirebaseAuth.instance);
});

final authStateProvider = StreamProvider<UserEntity?>((ref){
  return ref.watch(authRepositoryProvider).authStateChanges;
});
