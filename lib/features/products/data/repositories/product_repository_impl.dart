import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_practice/core/errors/failures.dart';
import 'package:flutter_practice/features/products/data/datasources/product_local_datasource.dart';
import 'package:flutter_practice/features/products/data/datasources/product_remote_datasource.dart';
import 'package:flutter_practice/features/products/domain/entities/product_entity.dart';
import 'package:flutter_practice/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource _remoteDataSource;
  final ProductLocalDatasource _localDatasource;
  ProductRepositoryImpl(this._remoteDataSource, this._localDatasource);
  @override
  Future<Either<Failures, List<ProductEntity>>> getProducts() async {
    try {
      final products = await _remoteDataSource.fetchProducts();
      await _localDatasource.cacheProducts(products); // save local data freshly
      return Right(products);
    } on DioException catch (e) {
      // network failed -fall back to cache instead of showing an error
      final cached = await _localDatasource.getCachedProducts();
      if (cached.isNotEmpty) {
        return Right(cached);
      }
      return left(ServerFailure('No internet and no cached data available'));
      // return Left(ServerFailure(_mapDioError(e)));
    } catch (e) {
      return left(ServerFailure('Unexpencted error occured'));
    }
  }

  String _mapDioError(DioException e) => switch (e.type) {
    DioExceptionType.connectionTimeout => 'Connection timed out',
    DioExceptionType.receiveTimeout => 'Server took too long to response',
    DioExceptionType.badResponse => 'server error: ${e.response?.statusCode}',
    _ => 'Network Error. Check Your connection',
  };
}
