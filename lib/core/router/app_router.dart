import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_practice/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_practice/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_practice/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:flutter_practice/features/products/domain/entities/product_entity.dart';
import 'package:flutter_practice/features/products/presentation/screens/esewa_payment_screen.dart';
import 'package:flutter_practice/features/products/presentation/screens/payment_screen.dart';
import 'package:flutter_practice/features/products/presentation/screens/product_list_screen.dart';
import 'package:flutter_practice/models/user_models.dart';
import 'package:flutter_practice/screens/home_screen.dart';
import 'package:flutter_practice/screens/kyc_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Every route in the app, in one place.
///
/// Always navigate with these constants (`context.go(AppRoute.products)`)
/// instead of raw strings - string literals are what caused the app to 404 on
/// `/products` and `/esewa-payment` while still compiling cleanly.
class AppRoute {
  AppRoute._();

  static const String login = '/login';
  static const String signUp = '/signup';
  static const String home = '/home';
  static const String kyc = '/kyc';
  static const String products = '/product';
  static const String payment = '/payment';
  static const String eSewa = '/esewascreen';

  /// Locations a signed-in user should never sit on.
  static const Set<String> _authPages = {login, signUp};
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: AppRoute.login,
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),
    redirect: (context, state) {
      // `refreshListenable` fires on every auth state change, so this runs
      // both on navigation and whenever the user signs in/out.
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final location = state.matchedLocation;

      if (!isLoggedIn && !AppRoute._authPages.contains(location)) {
        return AppRoute.login;
      }
      if (isLoggedIn && AppRoute._authPages.contains(location)) {
        return AppRoute.home;
      }
      return null;
    },
    errorBuilder: (context, state) => _NotFoundScreen(location: state.uri.toString()),
    routes: [
      GoRoute(
        path: AppRoute.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoute.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoute.kyc,
        builder: (context, state) {
          final user = state.extra;
          if (user is! UserModels) {
            return const _PayloadMissingScreen(
              message: 'Please submit your details first, then review them '
                  'here.',
            );
          }
          return KycScreen(userModels: user);
        },
      ),
      GoRoute(
        path: AppRoute.products,
        builder: (context, state) => const ProductListScreen(),
      ),
      GoRoute(
        path: AppRoute.payment,
        builder: (context, state) {
          final vehicle = state.extra;
          if (vehicle is! ProductEntity) {
            return const _PayloadMissingScreen(
              message: 'No vehicle selected. Please choose a vehicle from the '
                  'list first.',
            );
          }
          return PaymentScreen(vehicle: vehicle);
        },
      ),
      GoRoute(
        path: AppRoute.eSewa,
        builder: (context, state) {
          final vehicle = state.extra;
          if (vehicle is! ProductEntity) {
            return const _PayloadMissingScreen(
              message: 'No vehicle selected. Please choose a vehicle from the '
                  'list first.',
            );
          }
          return EsewaPaymentScreen(vehicle: vehicle);
        },
      ),
    ],
  );
});

/// Shown instead of throwing when a route was opened without the object it
/// requires (for example by a stale link or an accidental `context.go`).
class _PayloadMissingScreen extends StatelessWidget {
  const _PayloadMissingScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details missing')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, size: 48),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoute.products),
                child: const Text('Browse vehicles'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.link_off, size: 48),
              const SizedBox(height: 16),
              Text('No page exists for "$location".'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoute.home),
                child: const Text('Go home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Re-runs GoRouter redirects whenever the wrapped auth stream emits.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
