import 'package:flutter_practice/features/products/domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.price,
    required super.title,
    required super.thumpnail,
  });
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      price: (json['price'] as num?)?.toDouble()?? 0.0 ,
      title: json['title'] as String? ?? 'Untitled',
      thumpnail: json['thumpnail'] as String? ?? '',
    );
  }
}
