import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key, required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          height: 40,
          width: MediaQuery.sizeOf(context).width * 0.4,
          child: Center(child: Text(title)),
        ),
      ),
    );
  }
}
