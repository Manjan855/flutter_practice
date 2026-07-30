import 'package:dio/dio.dart';

class KhaltiService{
  final Dio _dio;
  KhaltiService(this._dio);
  Future<Map<String, dynamic>> initiatePayement({
   required int amountInPaisa,
   required String purchaseOrderId,
   required String purchaseOrderName, 
    
  })async{
    final response = await _dio.post('/purchase -initialize', data:{
      'amount': amountInPaisa,
      'purchase-order-id': purchaseOrderId,
      'purchase-order-name':purchaseOrderName,
    });
    return response.data;
  }
}