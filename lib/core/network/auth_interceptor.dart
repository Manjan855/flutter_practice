import 'package:dio/dio.dart';
import 'package:flutter_practice/core/storage/token_storage.dart';

class AuthInterceptor extends Interceptor{
  final Dio _dio;
  final TokenStorage _tokenStorage;
  AuthInterceptor(this._dio, this._tokenStorage);

  @override
  Future<void> onRequest( RequestOptions options, RequestInterceptorHandler handler) async{
    final token = await _tokenStorage.accessToken;
    if(token !=null) options.headers['Authorization'] = 'Beare $token';
    handler.next(options);
  }
}