import 'package:dio/dio.dart';
import 'package:flutter_practice/features/products/data/models/product_model.dart';

class ProductRemoteDatasource {
  final Dio _dio;
  ProductRemoteDatasource(this._dio);
  Future<List<ProductModel>> fetchProducts() async {
    final response = await _dio.get('/vehicles');
    final List<dynamic> productsJson = response.data['products'];
    return productsJson.map((json) => ProductModel.fromJson(json)).toList();
  }
}
