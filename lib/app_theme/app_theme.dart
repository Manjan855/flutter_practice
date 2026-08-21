import 'package:flutter/material.dart';

class AppTheme {
  static final themeData = ThemeData(
    appBarTheme: AppBarTheme(backgroundColor: Colors.green),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
      displayMedium: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
      displaySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.pink),
      ),
    ),
  );
}
