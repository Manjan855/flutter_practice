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
  late Future<Khalti> khalti;
@override
 void initState(){
  super.initState();

 }
Future<void> _setup()async{
  final dio = Dio();
  final service = KhaltiService(dio);
  final result = await service.initializePayement(amountInPaisa: (widget.vehicle.price * 100).toInt(), purchaseOrderId: 'VEH-${vehicle.purchase.id}', purchaseOrderName: widget.vehicle.title);
  final payConfig = khaltiPayConfig(
    publicKey:'your-test-public-key',
    pidx: result['pidx'],
    environment: Environment.test,
  );
  khalti = Khalti.init(
    enableDebugging: true,
    payConfig:payConfig,
    onPaymentResult :( result, khaltiIntance){
print('Status: ${result.payLoad?.status}');

    }
    onMessage:(khaltiIntance , {description , statusCode, event, needPaymentConfirmation})
   { print('khalti message: $description');},
   onReturn : ()=> print('Return sucessfully'),
  );
  setState(() {
    
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('payment'),),
      body: Center(
        child: ElevatedButton(onPressed: ()async{
          final khaltiIntance = await khalti;
          khaltiIntance.open(context);
        }, child: Text('Pay with khalti')),
      ),
    );
  }
}