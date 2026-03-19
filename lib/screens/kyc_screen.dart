import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_models.dart';

class KycScreen extends StatelessWidget {
  const KycScreen({super.key, required this.userModels});
  final UserModels userModels;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [Text('')]),
    );
  }
}
