import 'dart:convert';

import 'package:esewa_flutter/esewa_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_practice/core/config/app_config.dart';
import 'package:flutter_practice/core/router/app_router.dart';
import 'package:flutter_practice/features/products/domain/entities/product_entity.dart';
import 'package:flutter_practice/features/products/presentation/services/receipt_saver.dart';
import 'package:go_router/go_router.dart';

/// eSewa v2 checkout for a single vehicle.
class EsewaPaymentScreen extends StatefulWidget {
  const EsewaPaymentScreen({super.key, required this.vehicle});

  final ProductEntity vehicle;

  @override
  State<EsewaPaymentScreen> createState() => _EsewaPaymentScreenState();
}

class _EsewaPaymentScreenState extends State<EsewaPaymentScreen> {
  bool _succeeded = false;
  bool _issuingReceipt = false;
  String? _statusMessage;
  String? _transactionId;
  String? _receiptSaved;

  void _handleSuccess(EsewaPaymentResponse response) {
    final decoded = _decodeEsewaResponse(response.data);
    if (!mounted) return;

    setState(() {
      _succeeded = true;
      _statusMessage = 'Payment successful.';
      _transactionId =
          decoded['transaction_uuid']?.toString() ??
          decoded['ref_id']?.toString();
    });

    _issueReceipt();
  }

  void _handleFailure(String message) {
    if (!mounted) return;
    setState(() {
      _succeeded = false;
      _statusMessage = 'Payment failed: $message';
      _transactionId = null;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Payment failed: $message')));
  }

  Future<void> _issueReceipt() async {
    if (_issuingReceipt) return;
    _issuingReceipt = true;

    try {
      final path = await ReceiptSaver.saveAndPreview(
        widget.vehicle,
        paymentMethod: 'eSewa',
        transactionId: _transactionId,
        paidAt: DateTime.now(),
      );
      if (mounted) setState(() => _receiptSaved = path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not create the receipt: $e')));
      }
    } finally {
      _issuingReceipt = false;
    }
  }

  /// eSewa returns the payload base64-encoded; decode it so the transaction ID
  /// can be printed on the receipt. Malformed data must never break checkout.
  Map<String, dynamic> _decodeEsewaResponse(String? raw) {
    if (raw == null || raw.isEmpty) return const {};
    try {
      final normalized = base64.normalize(
        raw.length % 4 == 0 ? raw : raw.padRight(((raw.length + 3) ~/ 4) * 4, '='),
      );
      final decoded = jsonDecode(utf8.decode(base64.decode(normalized)));
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return decoded.map((k, v) => MapEntry('$k', v));
    } catch (_) {
      // Best effort only - the receipt still prints without it.
    }
    return const {};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Pay with eSewa')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.vehicle.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  '\$${widget.vehicle.price.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (_statusMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _succeeded
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _succeeded
                            ? Icons.check_circle_outline
                            : Icons.error_outline,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_statusMessage!)),
                    ],
                  ),
                  if (_transactionId != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Transaction ID: $_transactionId',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  if (_receiptSaved != null) ...[
                    const SizedBox(height: 4),
                    Text('Receipt: $_receiptSaved', style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (!_succeeded) ...[
            if (_issuingReceipt)
              const Center(child: CircularProgressIndicator())
            else ...[
              EsewaPayButton(
                paymentConfig: AppConfig.esewaUseDevMode
                    ? ESewaConfig.dev(
                        amount: widget.vehicle.price,
                        productCode: AppConfig.esewaProductCode,
                        successUrl:
                            'https://developer.esewa.com.np/success',
                        failureUrl: 'https://developer.esewa.com.np/failure',
                        secretKey: AppConfig.esewaSecretKey,
                      )
                    : ESewaConfig.live(
                        amount: widget.vehicle.price,
                        productCode: AppConfig.esewaProductCode,
                        successUrl: 'https://esewa.com.np/success',
                        failureUrl: 'https://esewa.com.np/failure',
                        secretKey: AppConfig.esewaSecretKey,
                      ),
                onSuccess: _handleSuccess,
                onFailure: _handleFailure,
                title: 'Pay \$${widget.vehicle.price.toStringAsFixed(2)} with eSewa',
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _issuingReceipt
                  ? null
                  : () => context.go(AppRoute.payment, extra: widget.vehicle),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to payment options'),
            ),
          ] else ...[
            FilledButton.icon(
              onPressed: _issuingReceipt ? null : _issueReceipt,
              icon: const Icon(Icons.receipt_long_outlined),
              label: Text(
                _issuingReceipt ? 'Preparing receipt…' : 'View receipt again',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoute.products),
              icon: const Icon(Icons.directions_car_outlined),
              label: const Text('Back to catalogue'),
            ),
          ],

          const SizedBox(height: 24),
          Text(
            AppConfig.esewaUseDevMode
                ? 'Running against the eSewa RC/test gateway.'
                : 'Running against the eSewa production gateway.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
