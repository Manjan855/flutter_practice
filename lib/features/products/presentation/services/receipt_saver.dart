import 'dart:io';

import 'package:flutter_practice/features/products/domain/entities/product_entity.dart';
import 'package:flutter_practice/features/products/presentation/services/receipt_generator.dart';
import 'package:path_provider/path_provider.dart';

class ReceiptSaver {
  static Future<File> saveReceipt(ProductEntity vehicles)async{
    final doc = await ReceiptGenerator.generate(vehicles);
    final dir = await getApplicationCacheDirectory();
    final file = File('${dir.path}/receipt_${vehicles.id}.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }
}