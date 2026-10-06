import 'package:dio/dio.dart';
import 'package:flutter_practice/core/config/app_config.dart';

/// Builds [Dio] clients for the app's outbound HTTP traffic.
///
/// Base URLs come from [AppConfig] rather than being hardcoded in source, so
/// they are configurable per environment through `--dart-define` or `.env`.
class DioClient {
  DioClient._();

  /// Client for the products API (`GET /vehicles`).
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {'Accept': 'application/json'},
      ),
    );
    _addLoggingIfEnabled(dio);
    return dio;
  }

  /// Client for Khalti's ePayment API (`POST /payment/initialize`).
  static Dio createKhalti() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.khaltiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: <String, dynamic>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Key ${AppConfig.khaltiPublicKey}',
        },
      ),
    );
    _addLoggingIfEnabled(dio);
    return dio;
  }

  static void _addLoggingIfEnabled(Dio dio) {
    // Response bodies are logged verbatim - only enable this outside of
    // release builds (see `ENABLE_HTTP_LOGGING` in .env.example).
    if (AppConfig.enableHttpLogging) {
      dio.interceptors.add(LogInterceptor(responseBody: true));
    }
  }
}
