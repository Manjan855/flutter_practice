import 'package:flutter/material.dart';
import 'package:flutter_practice/app_theme/app_text_style.dart';
import 'package:flutter_practice/models/user_models.dart';

class KycScreen extends StatelessWidget {
  const KycScreen({super.key, required this.userModels});
  final UserModels userModels;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Text('Name is ${userModels.name}', style: AppTextStyle.mediumText),
            Text('Gmail is ${userModels.email}'),
            Text('Address is ${userModels.address}'),
            Text('College is ${userModels.college}')
          ],
        ),
      ),
    );
  }
}
