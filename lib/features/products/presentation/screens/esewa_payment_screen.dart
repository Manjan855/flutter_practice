import 'package:esewa_flutter/esewa_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_practice/features/products/domain/entities/product_entity.dart';

class EsewaPaymentScreen extends StatelessWidget {
  final ProductEntity vehicle;
  const EsewaPaymentScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pay With eSewa')),
      body: Center(
        child: EsewaPayButton(
          paymentConfig: ESewaConfig.dev(
            amount: vehicle.price,
            successUrl: 'https://developer.esewa.com.np/success',
            failureUrl: 'https://developer.esewa.com.np/failure',
            secretKey: '8gBm/:&EnhH.1/q',
            // productCode defaults to 'EPAYTEST' in dev mode, can omit
          ),
          onSuccess: (resp) {
            print('Payment successful: ${resp.data}');
            Navigator.pop(context);
          },
          onFailure: (message) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Payment failed: $message')));
          },
          ),
      ),
    );
  }
}
