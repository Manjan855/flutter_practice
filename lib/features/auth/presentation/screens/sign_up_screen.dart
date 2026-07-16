import 'package:flutter/material.dart';
import 'package:flutter_practice/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_practice/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _emialCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  // Future<void> signUp ()async{
  //   try{
  //     final data = await
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('sign up page')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextFormField(
            controller: _firstName,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              label: Text('First Name'),
            ),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _lastName,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              label: Text('First Name'),
            ),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _emialCtrl,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              label: Text('First Name'),
            ),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _passCtrl,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              label: Text('First Name'),
            ),
          ),
          SizedBox(height: 24),
          _isLoading
              ? CircularProgressIndicator(strokeWidth: 2.5, color: Colors.amber)
              : ElevatedButton(
                  onPressed: () => LoginScreen(),
                  child: Text('Sign Up'),
                ),
          OutlinedButton.icon(
            icon: const Icon(Icons.g_mobiledata),
            label: const Text('Sign in with Google'),
            onPressed: () async {
              setState(() => _isLoading = true);
              final result = await ref
                  .read(authRepositoryProvider)
                  .signInWithGoogle();
              if (!mounted) return;
              setState(() => _isLoading = false);
              result.fold(
                (failure) => ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(failure.message))),
                (user) => context.go('/home'),
              );
            },
          ),
        ],
      ),
    );
  }
}
