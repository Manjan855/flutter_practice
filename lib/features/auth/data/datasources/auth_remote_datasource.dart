import 'package:dio/dio.dart';
import 'package:flutter_practice/models/user_models.dart';

class AuthRemoteDataSource{
  final Dio _dio;
  AuthRemoteDataSource(this._dio);
  Future<AuthResponseModel> login(String username, String password)async{
    final res = await _dio.post('auth/login', data: 
   { 'username': username,
    'password': password,
    'ExpiresInMin':1}
    );
  }
    return AuthResponseModel.fromJson(res.data);
Future<UserModels> getMe()async{
  final res = await _dio.get('auth/me');
  return UserModels.fromJson(res.data);
}
 
}