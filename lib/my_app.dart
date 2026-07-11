import 'package:flutter/material.dart';
import 'package:flutter_application_1/app_theme/app_theme.dart';
import 'package:flutter_application_1/route/AppRoutes.dart';
// import 'package:flutter_application_1/home_screen.dart';
// import 'package:flutter_application_1/route/app_route.dart';
// import 'package:flutter_application_1/display_screen.dart';
// import 'package:flutter_application_1/product_screen.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_application_1/Home_Screen.dart';

// import 'package:flutter_application_1/showing_button.dart';
// import 'package:flutter_application_1/display_screen.dart';

// import 'package:flutter_application_1/Home_Screen.dart';
// final _router = GoRouter(
//   routes: [
//     GoRoute(
//       path: '/',
//       builder: (context, state) => ProductScreen(productId: ''),
//     ),
//     GoRoute(
//       path: AppRoute.display,
//       builder: (context, state) => DisplayScreen(),
//     ),
//   ],
// );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,
      theme: AppTheme.themeData,
    );
  }
}
