import 'package:flutter/material.dart';
import 'package:flutter_practice/features/auth/presentation/providers/product_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Vehicles')),
      body: productsAsync.when(
        data: (neither) => neither.fold(
          (failures) => Center(child: Text(failures.message)),
          (products) => ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: Image.network(product.thumpnail, width: 50),
                trailing: Text('\$${product.price}'),
                title: Text(product.title),
              );
            },
          ),
        ),
        error: (err, _) => Center(child: Text('Error: $err')),
        loading: () => Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
