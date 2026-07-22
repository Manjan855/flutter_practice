import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_practice/core/errors/failures.dart';
import 'package:flutter_practice/features/products/data/datasources/product_remote_datasource.dart';
import 'package:flutter_practice/features/products/domain/entities/product_entity.dart';
import 'package:flutter_practice/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl extends ProductRepository {
  final ProductRemoteDatasource _remoteDataSource;
  ProductRepositoryImpl(this._remoteDataSource);
  @override
  // @override
  // Future<Either<Failures, List<ProductEntity>>> getProducts() async {
  //   try {
  //     final products = await _remoteDataSource.fetchProducts();
  //     return Right(products);
  //   } on DioException catch (e) {
  //     return Left(ServerFailure(_mapDioError(e)));
  //   } catch (e, stackTrace) {
  //     print('PARSING ERROR: $e'); // temporary debug line
  //     print('STACK: $stackTrace'); // temporary debug line
  //     return Left(ServerFailure('Unexpected error occurred'));
  //   }
  // }
  Future<Either<Failures, List<ProductEntity>>> getProducts() async {
    try {
      final products = await _remoteDataSource.fetchProducts();
      return Right(products);
    } on DioException catch (e) {
      return Left(ServerFailure(_mapDioError(e)));
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
