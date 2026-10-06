import 'dart:io';

import 'package:flutter_practice/features/products/domain/entities/product_entity.dart';
import 'package:flutter_practice/features/products/presentation/services/receipt_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

/// Persists and displays booking receipts.
class ReceiptSaver {
  ReceiptSaver._();

  /// Writes the receipt PDF to the app cache and returns the file.
  static Future<File> saveReceipt(
    ProductEntity vehicle, {
    String paymentMethod = 'Pending',
    String? transactionId,
    DateTime? paidAt,
  }) async {
    final doc = await ReceiptGenerator.generate(
      vehicle,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      paidAt: paidAt,
    );

    final dir = await getApplicationCacheDirectory();
    final file = File(
      '${dir.path}/receipt_${vehicle.id}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await doc.save());
    return file;
  }

  /// Opens the platform print/share sheet so the receipt can be saved or sent.
  static Future<bool> openReceipt(
    ProductEntity vehicle, {
    String paymentMethod = 'Pending',
    String? transactionId,
    DateTime? paidAt,
  }) async {
    final doc = await ReceiptGenerator.generate(
      vehicle,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      paidAt: paidAt,
    );
    final bytes = await doc.save();

    if (!await Printing.layoutPdf(onLayout: (_) async => bytes)) {
      return false;
    }
    return true;
  }

  /// Saves the file first, then opens the print/share sheet. Returns the saved
  /// path so the caller can surface it.
  static Future<String> saveAndPreview(
    ProductEntity vehicle, {
    required String paymentMethod,
    String? transactionId,
    DateTime? paidAt,
  }) async {
    final file = await saveReceipt(
      vehicle,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      paidAt: paidAt,
    );
    await openReceipt(
      vehicle,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      paidAt: paidAt,
    );
    return file.path;
  }
}
