// //import 'package:flutter_practice/Home_Screen.dart';
// //import 'package:flutter/material.dart';
// import 'package:flutter_practice/models/user_models.dart';
// import 'package:flutter_practice/core/router/app_router.dart';
// import 'package:flutter_practice/screens/home_screen.dart';
// import 'package:flutter_practice/screens/kyc_screen.dart';
// import 'package:flutter_practice/screens/main_screen.dart';
// //port 'package:flutter_practice/display_screen.dart';
// //import 'package:flutter_practice/error_screen.dart';
// import 'package:flutter_practice/screens/product_screen.dart';
// import 'package:go_router/go_router.dart';

// class AppRoutes {
//   static final router = GoRouter(
//     routes: [
//       GoRoute(path: '/', builder: (context, state) => MainScreen()),
//       GoRoute(
//         path: AppRoute.homeScreen,
//         builder: (context, state) => HomeScreen(),
//       ),
//       GoRoute(
//         path: AppRoute.product,
//         builder: (context, state) => ProductScreen(),
//       ),
//       GoRoute(
//         path: AppRoute.kyc,
//         builder: (context, state) {
//           UserModels user = state.extra as UserModels;
//           return KycScreen(userModels: user);
//         },
//       ),
//       // GoRoute(
//       //   path: AppRoutes.product,

//       //   builder: (context, state) {
//       //     String isLogin = state.extra.toString();
//       //     print('isLogin$isLogin');
//       //     if (isLogin == "false") {
//       //       return ProductScreen(productId: '',);
//       //     } else {
//       //       return ErrorScreen();
//       //     }
//       //   },
//       // ),
//     ],
//     //errorBuilder: (contex, state){
//     //return MaterialPage(child: Center(child: Text("Page Not Found")));
//     // }
//   );
// }
