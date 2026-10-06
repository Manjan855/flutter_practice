import 'package:flutter/material.dart';
import 'package:flutter_practice/models/user_models.dart';

/// Reviews the KYC details submitted from [HomeScreen].
class KycScreen extends StatelessWidget {
  const KycScreen({super.key, required this.userModels});

  final UserModels userModels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('KYC review')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Please confirm your details', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          _DetailTile(
            icon: Icons.person_outline,
            label: 'Full name',
            value: userModels.name,
          ),
          _DetailTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: userModels.email,
          ),
          _DetailTile(
            icon: Icons.home_outlined,
            label: 'Address',
            value: userModels.address,
          ),
          _DetailTile(
            icon: Icons.school_outlined,
            label: 'College or university',
            value: userModels.college,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.check),
            label: const Text('Confirm'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go back and edit'),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label, style: theme.textTheme.bodySmall),
        subtitle: Text(value.isEmpty ? '—' : value),
      ),
    );
  }
}
