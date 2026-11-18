// dummy_login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_practice/features/dummy_auth/presentation/providers/dummy_auth_providers.dart';


class DummyLoginScreen extends ConsumerStatefulWidget {
  const DummyLoginScreen({super.key});
  @override
  ConsumerState<DummyLoginScreen> createState() => _DummyLoginScreenState();
}

class _DummyLoginScreenState extends ConsumerState<DummyLoginScreen> {
  final _userCtrl = TextEditingController(text: 'emilys');
  final _passCtrl = TextEditingController(text: 'emilyspass');
  bool _loading = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    final result = await ref
        .read(dummyAuthRepositoryProvider)
        .login(_userCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    result.fold(
      (f) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(f.message))),
      (_) => context.go('/dummy-profile'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DummyJSON Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _userCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _login, child: const Text('Login')),
          ],
        ),
      ),
    );
  }
}
