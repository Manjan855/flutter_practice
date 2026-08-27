import 'package:esewa_flutter/esewa_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_practice/features/products/domain/entities/product_entity.dart';


class EsewaPaymentScreen extends StatelessWidget {
  final ProductEntity vehicle;
  const EsewaPaymentScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final paymentData = PaymentData(
      amount: vehicle.price.toString(),
      taxAmount: '0',
      totalAmount:vehicle.price.toString(),
      productCode: 'EPAYTEST',
       successUrl: 'https://developer.esewa.com.np/success',
      failureUrl: 'https://developer.esewa.com.np/failure',
      secretKey: '8gBm/:&EnhH.1/q',
    );
    return Scaffold(
      appBar: AppBar(title: Text('Pay With Esewa'),),
      body: Center(child: ElevatedButton(onPressed: (){
        final paymentService = EsewaPayment.dev(paymentData:paymentData);
        paymentService.initiateService(context,
        onSuccess: (EsewaPaymentResponse response){
          print('Payment Successful:${response.transactionCode}');
          Navigator.pop(context);
        },
        onFailure:(EsewaFailure failure){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Fails:${failure.message}')));
        });
      }, child: Text('Pay With Esewa')),),
      
    );
  }
}