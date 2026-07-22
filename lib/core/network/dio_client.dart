import 'package:dio/dio.dart';

class DioClient{
  static Dio create(){
    final dio = Dio(BaseOptions(
        baseUrl: 'https://dummyjson.com',
        connectTimeout:(Duration(seconds: 30)),
        receiveTimeout:(Duration(seconds: 30)),
    ));
    dio.interceptors.add(LogInterceptor(responseBody: true));// remove in production level
    return dio;
  }
}