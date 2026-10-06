import 'package:dio/dio.dart';

/// Result of Khalti's `POST /payment/initialize/` call.
class KhaltiInitResult {
  const KhaltiInitResult({
    required this.pidx,
    required this.paymentUrl,
    required this.amountInPaisa,
  });

  /// Payment identifier handed back to `KhaltiPayConfig`.
  final String pidx;

  /// URL that must be loaded in the checkout web view.
  final String paymentUrl;

  /// Amount the payment was initialised for, in paisa.
  final int amountInPaisa;

  factory KhaltiInitResult.fromJson(Map<String, dynamic> json) {
    final pidx = json['pidx'];
    final paymentUrl = json['payment_url'];
    if (pidx is! String || pidx.isEmpty) {
      throw const FormatException('Khalti did not return a pidx');
    }
    if (paymentUrl is! String || paymentUrl.isEmpty) {
      throw const FormatException('Khalti did not return a payment_url');
    }
    return KhaltiInitResult(
      pidx: pidx,
      paymentUrl: paymentUrl,
      amountInPaisa: (json['amount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Thin client around Khalti's ePayment initialise endpoint.
///
/// Khalti's public key is used as the `Authorization: Key ...` credential,
/// which is what their Flutter SDK documentation prescribes. In a production
/// app you would normally proxy this call through your own backend so the
/// key never ships in the binary - point `KHALTI_BASE_URL` at your server if
/// you choose to do that (see .env.example).
class KhaltiService {
  KhaltiService(this._dio);

  final Dio _dio;

  /// Endpoint relative to [Dio]'s `baseUrl`.
  static const String paymentInitializePath = '/payment/initialize/';

  Future<KhaltiInitResult> initiatePayment({
    required int amountInPaisa,
    required String purchaseOrderId,
    required String purchaseOrderName,
    String returnUrl = 'https://developer.khalti.com/return-url/',
    String websiteUrl = 'https://khalti.com/',
  }) async {
    try {
      final response = await _dio.post(
        paymentInitializePath,
        data: <String, dynamic>{
          'amount': amountInPaisa,
          'purchase_order_id': purchaseOrderId,
          'purchase_order_name': purchaseOrderName,
          'return_url': returnUrl,
          'website_url': websiteUrl,
          'amount_breakdown': <Map<String, dynamic>>[
            {'label': 'Amount', 'value': amountInPaisa},
          ],
          'product_details': <Map<String, dynamic>>[
            {
              'identity': purchaseOrderId,
              'name': purchaseOrderName,
              'total_price': amountInPaisa,
              'quantity': 1,
            },
          ],
        },
      );
      return KhaltiInitResult.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw KhaltiInitException(_messageFrom(e));
    }
  }

  static String _messageFrom(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final detail = data['detail'] ?? data['error_key'];
      if (detail is String && detail.isNotEmpty) return detail;
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.receiveTimeout:
        return 'Could not reach Khalti. Check your connection.';
      case DioExceptionType.badResponse:
        return 'Khalti rejected the request (HTTP ${e.response?.statusCode}).';
      default:
        return 'Khalti payment could not be started.';
    }
  }
}

/// Thrown when payment initialisation fails, carrying a user-facing message.
class KhaltiInitException implements Exception {
  const KhaltiInitException(this.message);

  final String message;

  @override
  String toString() => message;
}
