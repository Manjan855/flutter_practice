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

final dioProvider = Provider<Dio>((ref)=>DioClient.create());
final productRepositoryProvider = Provider<ProductRepository>((ref){
  final dio = ref.watch(dioProvider);
  return ProductRepositoryImpl(ProductRemoteDatasource(dio),
 ProductLocalDatasource(),);

});
final productListProvider = FutureProvider<Either<Failures, List<ProductEntity>>>((ref) async{
return ref.watch(productRepositoryProvider).getProducts();
});