import 'package:flutter/material.dart';
import 'package:flutter_practice/core/router/app_router.dart';
import 'package:flutter_practice/features/products/domain/entities/product_entity.dart';
import 'package:flutter_practice/features/products/presentation/providers/product_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Catalogue of vehicles. Tapping a row hands the [ProductEntity] to the
/// payment screen through `GoRouter.extra`.
class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    // Re-runs the FutureProvider, which also rewrites the local cache.
    ref.invalidate(productListProvider);
    await ref.read(productListProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Vehicles'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => _refresh(ref),
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: 'Something went wrong: $error',
          onRetry: () => _refresh(ref),
        ),
        data: (result) => result.fold(
          (failure) => _ErrorView(
            message: failure.message,
            onRetry: () => _refresh(ref),
          ),
          (products) => products.isEmpty
              ? _ErrorView(
                  message: 'No vehicles available yet.',
                  onRetry: () => _refresh(ref),
                  icon: Icons.directions_car_outlined,
                )
              : RefreshIndicator(
                  onRefresh: () => _refresh(ref),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        leading: _ProductThumbnail(url: product.thumbnail),
                        title: Text(product.title),
                        subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(
                          AppRoute.payment,
                          extra: product,
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const Icon(Icons.image_not_supported_outlined, size: 40);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        url,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported_outlined, size: 40),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            width: 56,
            height: 56,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    this.icon = Icons.cloud_off,
  });

  final String message;
  final VoidCallback onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
