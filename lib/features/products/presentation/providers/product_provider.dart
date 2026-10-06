import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_practice/core/errors/failures.dart';
import 'package:flutter_practice/core/network/dio_client.dart';
import 'package:flutter_practice/features/products/data/datasources/product_local_datasource.dart';
import 'package:flutter_practice/features/products/data/datasources/product_remote_datasource.dart';
import 'package:flutter_practice/features/products/data/repositories/product_repository_impl.dart';
import 'package:flutter_practice/features/products/domain/entities/product_entity.dart';
import 'package:flutter_practice/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// HTTP client for the products API (base URL comes from AppConfig).
final dioProvider = Provider<Dio>((ref) => DioClient.create());

/// Binds the remote data source and the SQLite cache together.
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ProductRepositoryImpl(
    ProductRemoteDatasource(dio),
    ProductLocalDatasource(),
  );
});

/// The vehicle catalogue.
///
/// Refresh with `ref.invalidate(productListProvider)` - that re-runs the body
/// below, which performs a fresh network call and rewrites the local cache.
final productListProvider =
    FutureProvider<Either<Failures, List<ProductEntity>>>((ref) {
      return ref.watch(productRepositoryProvider).getProducts();
    });
