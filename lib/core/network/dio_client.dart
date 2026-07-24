import 'package:dio/dio.dart';

class DioClient {
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://192.168.18.228:8000',
        connectTimeout: (Duration(seconds: 30)),
        receiveTimeout: (Duration(seconds: 30)),
      ),
    );
    dio.interceptors.add(
      LogInterceptor(responseBody: true),
    ); // remove in production level
    return dio;
  }
}
