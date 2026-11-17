// repositories/dummy_auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_practice/core/errors/failures.dart';
import 'package:flutter_practice/core/storage/token_storage.dart';
import 'package:flutter_practice/features/dummy_auth/data/datasources/dummy_auth_datasources.dart';
import '../../domain/entities/dummy_user_entity.dart';
import '../../domain/repositories/dummy_auth_repository.dart';

import '../models/dummy_user_model.dart';

class DummyAuthRepositoryImpl implements DummyAuthRepository {
  final DummyAuthRemoteDataSource _remote;
  final TokenStorage _tokens;
  DummyAuthRepositoryImpl(this._remote, this._tokens);

  @override
  Future<Either<Failures, DummyUserEntity>> login(
    String username,
    String password,
  ) async {
    try {
      final json = await _remote.login(username, password);
      final access = json['accessToken'] as String?;
      final refresh = json['refreshToken'] as String?;
      if (access == null || refresh == null) {
        return Left(AuthFailure('Login response had no tokens'));
      }
      await _tokens.save(accessToken: access, refreshToken: refresh);
      return Right(DummyUserModel.fromJson(json));
    } on DioException catch (e) {
      return Left(AuthFailure(_serverMessage(e, 'Login failed')));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failures, DummyUserEntity>> getCurrentUser() async {
    try {
      return Right(DummyUserModel.fromJson(await _remote.getMe()));
    } on DioException catch (e) {
      return Left(AuthFailure(_serverMessage(e, 'Could not load profile')));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<void> logout() => _tokens.clear();

  // Use the server's own error message when it sends one
  String _serverMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String)
      return data['message'] as String;
    return fallback;
  }
}
