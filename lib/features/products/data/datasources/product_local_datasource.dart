import 'package:flutter_practice/core/database/app_database.dart';
import 'package:flutter_practice/features/products/data/models/product_model.dart';
import 'package:sqflite/sqflite.dart';

class ProductLocalDatasource {
  Future<void> cacheProducts(List<ProductModel> products) async {
    final db = await AppDatabase.instance;
    await db.delete('products');
    for (final product in products) {
      await db.insert('products', {
        'id': product.id,
        'title': product.title,
        'price': product.price,
        'thumbnail': product.thumbnail,
      });
    }
  }

  Future<List<ProductModel>> getCachedProducts() async {
    final db = await AppDatabase.instance;
    final maps = await db.query('products');
    return maps.map((map) => ProductModel.fromJson(map)).toList();
  }
  //practice by repearting above one later remove for the real one
  Future<List<ProductModel>> ungetCachedProducts() async {
    final db = await AppDatabase.instance;
    final maps = await db.query('products');
    return maps.map((map)=> ProductModel.fromJson(map)).toList();
  }
   Future<List<ProductModel>> getDeleteProduct() async{
    final db = await AppDatabase.instance;
    final maps = await db.query('products');
    return db = await db.delete('products');
   }
}
