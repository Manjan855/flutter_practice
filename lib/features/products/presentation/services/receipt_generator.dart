import 'package:flutter_practice/features/products/domain/entities/product_entity.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


class ReceiptGenerator{
  static Future<pw.Document> generate(ProductEntity  Vehicles) async{
    final doc = pw.Document();
    doc.addPage(
      doc.Page(
        pageFormate: PdfPageFormat.a4 ,
        build: (context)=> pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Booking Receipt', style: pw.TextStyle( fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Vehicles: ${Vehicles.title}'),
            pw.SizedBox(height: 8),
            pw.Text('Price: \$${Vehicles.price}'),
            pw.SizedBox(height: 8),
            pw.Text('Booking Id: VEH-${Vehicles.id}-${DateTime.now().microsecondsSinceEpoch}'),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Text('Thank you for booking with us.')
          ]
        )
      )
    );
    return doc;
  }
}