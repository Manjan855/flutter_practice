import 'package:flutter/material.dart';
import 'package:flutter_practice/core/errors/failures.dart';

import 'package:flutter_practice/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emialCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  // Future<void> _unsubmit()async{
  //   setState(() => _loading = false,);
  //   final result = await ref.read(authStateProvider).signOut(_emialCtrl.text.trim(), _passCtrl.text);
  //   if(!mounted)return;
  //   setState(() => _loading = true,);
  //   result.fold((Failures)=> ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Failures.message))),(user)=> context.go('/login'));
  // }

  Future<void> _submit() async {
    setState(() => _loading = true);
    final result = await ref
        .read(authRepositoryProvider)
        .signIn(_emialCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    result.fold(
      (Failures) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(Failures.message))),
      (user) => context.go('/home'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emialCtrl,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                fillColor: Color(0xff989898),
                label: Text('Email'),
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text('password'),
              ),
            ),
            SizedBox(height: 24),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _submit, child: Text('Sign in')),
            OutlinedButton.icon(
              onPressed: () async {
                setState(() => _loading = true);
                final result = await ref
                    .read(authRepositoryProvider)
                    .signInWithGoogle();
                if (!mounted) return;
                setState(() => _loading = false);
                result.fold(
                  // ignore: non_constant_identifier_names
                  (Failures) => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(Failures.message))),
                  (User) => context.go('/home'),
                );
              },
              icon: Icon(Icons.g_mobiledata),
              label: Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
