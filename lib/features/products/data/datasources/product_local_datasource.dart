import 'package:flutter_practice/core/database/app_database.dart';
import 'package:flutter_practice/features/products/data/models/product_model.dart';

class ProductLocalDatasource {
  Future<void> cacheProducts(List<ProductModel> products) async {
    final db = await AppDatabase.instance;
    await db.delete('products'); // clear old cache before saving new one
    for (final product in products) {
      await db.insert('products', {
        ' id': product.id,
        'title': product.title,
        'price': product.price,
        'thumpnail': product.thumpnail,
      });
    }
  }

  Future<List<ProductModel>> getCachedProducts() async {
    final db = await AppDatabase.instance;
    final maps = await db.query('products');
    return maps
        .map(
          (map) => ProductModel(
            id: map['id'] as int,
            price: map['price'] as double,
            title: map['title'] as String,
            thumpnail: map['thumpnail'] as String,
          ),
        )
        .toList();
  }
}
