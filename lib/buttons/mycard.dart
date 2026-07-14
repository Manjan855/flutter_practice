import 'package:flutter/material.dart';
import 'package:flutter_practice/app_theme/asset.dart';
import 'package:flutter_practice/buttons/my_widget.dart';

class Mycards extends StatelessWidget {
  const Mycards({
    super.key,
    required this.cardTitle,
    required this.imgreurl,
    required this.localimage,
  });
  final String cardTitle;
  final String imgreurl;
  final String localimage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      height: 500,
      width: MediaQuery.sizeOf(context).width * 0.60,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        spacing: 20,
        children: [
          Text(
            cardTitle,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight(600)),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(imgreurl, height: 150, width: 200),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(Assets.greenery, height: 50, width: 50),
          ),
          MyWidget(title: "Press Me", onTap: () {}),
        ],
      ),
    );
  }
}
