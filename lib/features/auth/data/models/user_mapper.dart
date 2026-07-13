import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_application_1/features/auth/domain/entities/user_entity.dart';

extension UserMapper on fb.User{
  UserEntity toEntity()=>UserEntity(
    uid: uid,
    email: email,
    displayName: displayName,
  );
}