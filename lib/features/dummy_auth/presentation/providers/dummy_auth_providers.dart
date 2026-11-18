import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_practice/features/dummy_auth/data/datasources/dummy_auth_datasources.dart';
import 'package:flutter_practice/features/dummy_auth/data/repositories/dummy_auth_repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_practice/core/errors/failures.dart';
import 'package:flutter_practice/core/network/auth_interceptor.dart';
import 'package:flutter_practice/core/storage/token_storage.dart';

import '../../domain/entities/dummy_user_entity.dart';
import '../../domain/repositories/dummy_auth_repository.dart';

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(const FlutterSecureStorage()),
);

final dummyDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://dummyjson.com',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  dio.interceptors.add(AuthInterceptor(dio, ref.read(tokenStorageProvider)));
  dio.interceptors.add(LogInterceptor(responseBody: true));
  return dio;
});

final dummyAuthRepositoryProvider = Provider<DummyAuthRepository>((ref) {
  return DummyAuthRepositoryImpl(
    DummyAuthRemoteDataSource(ref.watch(dummyDioProvider)),
    ref.watch(tokenStorageProvider),
  );
});

final currentDummyUserProvider =
    FutureProvider.autoDispose<Either<Failures, DummyUserEntity>>((ref) {
      return ref.watch(dummyAuthRepositoryProvider).getCurrentUser();
    });
