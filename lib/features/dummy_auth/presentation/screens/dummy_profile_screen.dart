// dummy_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


class DummyProfileScreen extends ConsumerWidget {
  const DummyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentDummyUserProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile (/auth/me)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(dummyAuthRepositoryProvider).logout();
              if (context.mounted) context.go('/dummy-login');
            },
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (either) => either.fold(
          (f) => Center(child: Text(f.message)),
          (u) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (u.image.isNotEmpty)
                  Image.network(
                    u.image,
                    width: 100,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person, size: 100),
                  ),
                Text(
                  '${u.firstName} ${u.lastName}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(u.email),
                Text('@${u.username}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
