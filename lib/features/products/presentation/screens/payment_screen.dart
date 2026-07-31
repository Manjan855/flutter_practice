import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_practice/core/network/khalti_service.dart';
import 'package:flutter_practice/features/products/domain/entities/product_entity.dart';

class PaymentScreen extends StatefulWidget {
  final ProductEntity vehicle;
  const PaymentScreen({super.key, required this.vehicle});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final Future<Khalti> khalti;

  @override
  void initState() {
    super.initState();
    khalti = _setup();
  }

  Future<Khalti> _setup() async {
    final dio = Dio();
    final service = KhaltiService(dio);
    final result = await service.initiatePayment(
      amountInPaisa: (widget.vehicle.price * 100).toInt(),
      purchaseOrderId: 'VEH-${widget.vehicle.id}',
      purchaseOrderName: widget.vehicle.title,
    );

    final payConfig = KhaltiPayConfig(
      publicKey: 'your-test-public-key',
      pidx: result['pidx'],
      environment: Environment.test,
    );

    return Khalti.init(
      enableDebugging: true,
      payConfig: payConfig,
      onPaymentResult: (paymentResult, khaltiInstance) {
        print('Status: ${paymentResult.payload?.status}');
      },
      onMessage:
          (
            khaltiInstance, {
            description,
            statusCode,
            event,
            needsPaymentConfirmation,
          }) {
            print('Khalti message: $description');
          },
      onReturn: () => print('Returned successfully'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final khaltiInstance = await khalti;
            khaltiInstance.open(context);
          },
          child: const Text('Pay with Khalti'),
        ),
      ),
    );
  }
}
