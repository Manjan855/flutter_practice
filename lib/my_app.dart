import 'package:flutter/material.dart';
import 'package:flutter_practice/app_theme/app_theme.dart';
import 'package:flutter_practice/core/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_practice/home_screen.dart';
// import 'package:flutter_practice/route/app_route.dart';
// import 'package:flutter_practice/display_screen.dart';
// import 'package:flutter_practice/product_screen.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_practice/Home_Screen.dart';

// import 'package:flutter_practice/showing_button.dart';
// import 'package:flutter_practice/display_screen.dart';

// import 'package:flutter_practice/Home_Screen.dart';
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.themeData,
      
    );
  
  }
}
