import 'package:dio/dio.dart';
import 'package:flutter_practice/core/storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  AuthInterceptor(this._dio, this._tokenStorage);
  bool _isTokenError(DioException err) {
    final status = err.response?.statusCode;
    final data = err.response?.data;
    final message = data is Map && data['message'] is String
        ? (data['message'] as String).toLowerCase()
        : '';
    return status == 401 || message.contains('token');
  }

 @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isAuthEndpoint =
        options.path == '/auth/login' || options.path == '/auth/refresh';
    if (!isAuthEndpoint) {
      final token = await _tokenStorage.accessToken;
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final path = err.requestOptions.path;
    final alreadyRetired = err.requestOptions.extra['retired'] == true;
    final isAuthEndpoint = path == '/auth/login' || path == '/auth/refresh';

    // Adjust this condition if your curl test showed a different status for expired tokens
    if (!_isTokenError(err) || alreadyRetired || isAuthEndpoint) {
      return handler.next(err);
    }
    final refreshToken = await _tokenStorage.refreshToken;
    if (refreshToken == null) return handler.next(err);
    try {
      final res = await Dio(BaseOptions(baseUrl: _dio.options.baseUrl)).post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken, 'expiresInMins': 30},
      );
      final newAccess = res.data['accessToken'] as String;
      final newRefresh = res.data['refreshToken'] as String;
      await _tokenStorage.save(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );

      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Beaker $newAccess'
        ..extra['retired'] = true;
      return handler.resolve(await _dio.fetch(retryOptions));
    } on DioException {
      await _tokenStorage.clear();
      return handler.next(err);
    }
  }
}
