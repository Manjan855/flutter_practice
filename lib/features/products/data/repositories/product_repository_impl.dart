import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_practice/core/errors/failures.dart';
import 'package:flutter_practice/features/products/data/datasources/product_local_datasource.dart';
import 'package:flutter_practice/features/products/data/datasources/product_remote_datasource.dart';
import 'package:flutter_practice/features/products/domain/entities/product_entity.dart';
import 'package:flutter_practice/features/products/domain/repositories/product_repository.dart';

/// Cache-first repository: fetch remotely, persist locally, and fall back to
/// the local cache whenever the network is unavailable.
class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remoteDatasource, this._localDatasource);

  final ProductRemoteDatasource _remoteDatasource;
  final ProductLocalDatasource _localDatasource;

  @override
  Future<Either<Failures, List<ProductEntity>>> getProducts() async {
    try {
      final products = await _remoteDatasource.fetchProducts();
      await _localDatasource.cacheProducts(products);
      return Right(products);
    } on DioException catch (e) {
      // Network problem: serve the cache instead of an error when we have one.
      try {
        final cached = await _localDatasource.getCachedProducts();
        if (cached.isNotEmpty) {
          return Right(cached);
        }
      } catch (_) {
        // Fall through to the network failure below.
      }
      return Left(ServerFailure(_networkMessage(e)));
    } catch (_) {
      // Unexpected parsing/programming error - never leak stack traces to UI.
      return const Left(ServerFailure('Something went wrong loading vehicles.'));
    }
  }

  static String _networkMessage(DioException e) => switch (e.type) {
    DioExceptionType.connectionTimeout =>
      'Connection timed out. Check your network.',
    DioExceptionType.connectionError => 'No internet connection.',
    DioExceptionType.receiveTimeout => 'The server took too long to respond.',
    DioExceptionType.badResponse =>
      'Server error (HTTP ${e.response?.statusCode}).',
    DioExceptionType.cancel => 'Request cancelled.',
    _ => 'Network error. Check your connection.',
  };
}
