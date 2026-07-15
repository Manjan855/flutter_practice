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
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = ref.watch(authStateProvider);
      final isLoggedIn = authState.value != null;
      if (!isLoggedIn && state.matchedLocation != '/login') return 'login';
      return null;
    },

    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
});
