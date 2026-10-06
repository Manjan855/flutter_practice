import 'package:flutter/material.dart';
import 'package:flutter_practice/core/router/app_router.dart';
import 'package:flutter_practice/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_practice/models/user_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Landing page after authentication.
///
/// Holds the KYC details form and quick links into the rest of the app.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _collegeController = TextEditingController();

  bool _signingOut = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _collegeController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);

    final result = await ref.read(authRepositoryProvider).signOut();

    if (!mounted) return;
    setState(() => _signingOut = false);

    // On success GoRouter's redirect sends the user to /login, so we only
    // need to report failures.
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => context.go(AppRoute.login),
    );
  }

  void _reviewDetails() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // The email belongs to the authenticated account, not to the KYC form.
    final accountEmail =
        ref.read(authStateProvider).value?.email ?? 'unknown@example.com';

    final user = UserModels(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      email: accountEmail,
      college: _collegeController.text.trim(),
    );

    context.push(AppRoute.kyc, extra: user);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Vehicle Booking'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: _signingOut ? null : _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            authState.when(
              loading: () => const _WelcomeCard(
                title: 'Welcome back',
                subtitle: 'Loading your account…',
              ),
              error: (error, _) => _WelcomeCard(
                title: 'Welcome back',
                subtitle: 'Could not load account details ($error)',
              ),
              data: (user) => _WelcomeCard(
                title: 'Welcome back',
                subtitle: user?.displayName?.isNotEmpty == true
                    ? '${user!.displayName} · ${user.email ?? ''}'
                    : (user?.email ?? 'Signed in'),
              ),
            ),
            const SizedBox(height: 16),
            _QuickAction(
              icon: Icons.directions_car_outlined,
              title: 'Browse vehicles',
              subtitle: 'View the catalogue and start a booking',
              onTap: () => context.go(AppRoute.products),
            ),
            const SizedBox(height: 20),
            Text(
              'KYC details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  KTextFormField(
                    controller: _nameController,
                    label: 'Full name',
                    hintText: 'Enter your full name',
                    prefixIcon: const Icon(Icons.person),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  KTextFormField(
                    controller: _addressController,
                    label: 'Address',
                    hintText: 'Enter your address',
                    prefixIcon: const Icon(Icons.home_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  KTextFormField(
                    controller: _collegeController,
                    label: 'College or university',
                    hintText: 'Enter your institution',
                    prefixIcon: const Icon(Icons.school_outlined),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _reviewDetails(),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Required'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _reviewDetails,
              icon: const Icon(Icons.badge_outlined),
              label: const Text('Review KYC details'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _signingOut ? null : _signOut,
              icon: _signingOut
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              label: Text(_signingOut ? 'Signing out…' : 'Sign out'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Labeled text field used by the KYC form.
class KTextFormField extends StatelessWidget {
  const KTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final Icon prefixIcon;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator:
          validator ??
          (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
    );
  }
}
