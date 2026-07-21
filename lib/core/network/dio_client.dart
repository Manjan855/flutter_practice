import 'package:dio/dio.dart';

class DioClient{
  static Dio create(){
    final dio = Dio(BaseOptions(
        baseUrl: 'https://dummyjson.com',
        connectTimeout:(Duration(milliseconds: 100)),
        receiveTimeout:(Duration(milliseconds: 100)),
    ));
    dio.interceptors.add(LogInterceptor(responseBody: true));// remove in production level
    return dio;
  }
}