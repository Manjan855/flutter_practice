import 'package:flutter_practice/core/database/app_database.dart';
import 'package:flutter_practice/features/products/data/models/product_model.dart';

/// SQLite-backed cache for the vehicle catalogue.
///
/// Lets the catalogue render without a network connection after the first
/// successful load.
class ProductLocalDatasource {
  static const String table = 'products';

  Future<void> cacheProducts(List<ProductModel> products) async {
    final db = await AppDatabase.instance;

    await db.transaction((txn) async {
      await txn.delete(table);
      for (final product in products) {
        await txn.insert(table, {
          'id': product.id,
          'title': product.title,
          'price': product.price,
          'thumbnail': product.thumbnail,
        });
      }
    });
  }

  Future<List<ProductModel>> getCachedProducts() async {
    final db = await AppDatabase.instance;
    final maps = await db.query(table, orderBy: 'id ASC');
    return maps.map(ProductModel.fromMap).toList();
  }

  Future<bool> hasCache() async {
    final db = await AppDatabase.instance;
    final result = await db.rawQuery('SELECT COUNT(*) AS c FROM $table');
    return ((result.first['c'] as int?) ?? 0) > 0;
  }

  Future<void> clear() async {
    final db = await AppDatabase.instance;
    await db.delete(table);
  }
}
