// datasources/dummy_auth_remote_datasource.dart
import 'package:dio/dio.dart';

class DummyAuthRemoteDataSource {
  final Dio _dio;
  DummyAuthRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await _dio.post(
      '/auth/login',
      data: {'username': username, 'password': password, 'expiresInMins': 1},
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/auth/me');
    return res.data as Map<String, dynamic>;
  }
}
