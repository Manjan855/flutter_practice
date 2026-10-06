import 'package:dio/dio.dart';
import 'package:flutter_practice/features/products/data/models/product_model.dart';

/// Remote source for the vehicle catalogue.
class ProductRemoteDatasource {
  ProductRemoteDatasource(this._dio);

  final Dio _dio;

  static const String _vehiclesPath = '/vehicles';

  Future<List<ProductModel>> fetchProducts() async {
    final response = await _dio.get(_vehiclesPath);

    final data = response.data;
    // Accept both `{"products": [...]}` and a bare JSON array so the client
    // survives a backend that changes its envelope shape.
    final List<dynamic> productsJson = switch (data) {
      List<dynamic>() => data,
      Map<String, dynamic>() when data['products'] is List => data['products'],
      Map<String, dynamic>() when data['data'] is List => data['data'],
      _ => const <dynamic>[],
    };

    return productsJson
        .map(ProductModel.tryFromJson)
        .whereType<ProductModel>()
        .toList();
  }
}
