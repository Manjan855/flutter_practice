import 'package:flutter/material.dart';
import 'package:flutter_practice/features/products/domain/entities/product_entity.dart';
import 'package:flutter_practice/features/products/presentation/screens/esewa_payment_screen.dart';

import 'package:flutter_practice/models/user_models.dart';
import 'package:flutter_practice/core/router/app_router.dart';
import 'package:flutter_practice/screens/error_screen.dart';
import 'package:flutter_practice/screens/home_screen.dart';
import 'package:flutter_practice/screens/kyc_screen.dart';
import 'package:flutter_practice/screens/main_screen.dart';

import 'package:flutter_practice/screens/product_screen.dart';
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
        builder: (context, state) => ProductScreen(productId: ''),
      ),
      GoRoute(
        path: AppRoute.kyc,
        builder: (context, state) {
          UserModels user = state.extra as UserModels;
          return KycScreen(userModels: user);
        },
      ),
      GoRoute(path: '/esewa-payment',
      builder: (context, state) {
        final vehicle = state.extra as ProductEntity;
        return EsewaPaymentScreen(vehicle: vehicle);
      },)
      GoRoute(
        path: AppRoute.product,

        builder: (context, state) {
          String isLogin = state.extra.toString();
          print('isLogin$isLogin');
          if (isLogin == "false") {
            return ProductScreen(productId: '1');
          } else {
            return ErrorScreen();
          }
        },
      ),
    ],
    errorBuilder: (contex, state) {
      return Column(
        children: [
          Icon(Icons.broken_image),
          Center(child: Text("Page Not Found")),
        ],
      );
    },
  );
}
