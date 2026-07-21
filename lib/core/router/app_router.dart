import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_practice/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_practice/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_practice/screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// class AppRoute {
//   static const mainScreen = '/';
//   static const homeScreen = '/homescreen';
//   static const product = '/Product_Screen';
//   static const display = '/Display_screen';
//   static const showing = '/showingbutton';
//   static const kyc = '/kyc';
// }

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),
    redirect: (context, state) {
      // final authState = ref.watch(authStateProvider);
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final onLoginPage = state.matchedLocation == '/login';
      if (!isLoggedIn && !onLoginPage) return '/login';
      if (isLoggedIn && !onLoginPage) return '/home';
      return null;
    },

    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
