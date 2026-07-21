import 'package:dartz/dartz.dart';
import 'package:flutter_practice/core/errors/failures.dart';
import 'package:flutter_practice/features/auth/domain/entities/product_entity.dart';

abstract class ProductRepository {
Future<Either<Failures, List<ProductEntity>>> getProducts();
}