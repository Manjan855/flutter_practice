//import 'package:flutter_application_1/Home_Screen.dart';
//import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_models.dart';
import 'package:flutter_application_1/route/app_router.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/kyc_screen.dart';
import 'package:flutter_application_1/screens/main_screen.dart';
//port 'package:flutter_application_1/display_screen.dart';
//import 'package:flutter_application_1/error_screen.dart';
import 'package:flutter_application_1/screens/product_screen.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => MainScreen()),
      GoRoute(
        path: AppRoute.homeScreen,
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
        path: AppRoute.product,
        builder: (context, state) => ProductScreen(),
      ),
      GoRoute(
        path: AppRoute.kyc,
        builder: (context, state) {
          UserModels user = state.extra as UserModels;
          return KycScreen(userModels: user);
        },
      ),
      // GoRoute(
      //   path: AppRoutes.product,

      //   builder: (context, state) {
      //     String isLogin = state.extra.toString();
      //     print('isLogin$isLogin');
      //     if (isLogin == "false") {
      //       return ProductScreen(productId: '',);
      //     } else {
      //       return ErrorScreen();
      //     }
      //   },
      // ),
    ],
    //errorBuilder: (contex, state){
    //return MaterialPage(child: Center(child: Text("Page Not Found")));
    // }
  );
}
