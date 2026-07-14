import 'package:dartz/dartz.dart';

abstract class Failures {
  final String message;
  Failures(this.message);
}
  class ServerFailure extends Failures{
    ServerFailure(super.message);
  }
class AuthFailure extends Failures{
  AuthFailure(super.message);
}
class CacheFailure extends Failures{
  CacheFailure(super.message);
}
