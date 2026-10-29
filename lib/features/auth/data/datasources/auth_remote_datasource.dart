import 'package:dio/dio.dart';

class AuthRemoteDataSource{
  final Dio _dio;
  AuthRemoteDataSource(this._dio);
  Future<AuthResponseModel> login(String username, String password)async{
    final res = await _dio.post('auth/login', data: 
    'username': username,
    'password': password,
    )
  }
}