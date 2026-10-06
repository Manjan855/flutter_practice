import 'package:dartz/dartz.dart';
import 'package:flutter_practice/core/errors/failures.dart';
import 'package:flutter_practice/features/products/domain/entities/product_entity.dart';

/// Contract for reading the vehicle catalogue.
///
/// Implementations may use the network, a local cache, or both - callers in
/// the presentation layer only ever depend on this abstraction.
abstract class ProductRepository {
  /// Returns the catalogue, or a [Failures] describing why it could not be
  /// loaded.
  Future<Either<Failures, List<ProductEntity>>> getProducts();
}
