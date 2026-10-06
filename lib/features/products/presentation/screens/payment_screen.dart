import 'package:flutter/material.dart';
import 'package:flutter_practice/core/config/app_config.dart';
import 'package:flutter_practice/core/network/dio_client.dart';
import 'package:flutter_practice/core/network/khalti_service.dart';
import 'package:flutter_practice/core/router/app_router.dart';
import 'package:flutter_practice/features/products/domain/entities/product_entity.dart';
import 'package:flutter_practice/features/products/presentation/services/receipt_saver.dart';
import 'package:khalti_checkout_flutter/khalti_checkout_flutter.dart'
    hide KhaltiService;
import 'package:go_router/go_router.dart';

/// Shows the selected vehicle and lets the user pick a payment method.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.vehicle});

  final ProductEntity vehicle;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

enum _KhaltiPhase { idle, initializing, opening, completed, failed }

class _PaymentScreenState extends State<PaymentScreen> {
  _KhaltiPhase _phase = _KhaltiPhase.idle;
  String? _statusMessage;
  String? _transactionId;
  bool _issuingReceipt = false;

  bool get _busy =>
      _phase == _KhaltiPhase.initializing || _phase == _KhaltiPhase.opening;

  /// Whether the Khalti public key has been supplied via .env / --dart-define.
  bool get _khaltiConfigured => AppConfig.isKhaltiConfigured;

  /// Khalti issues `test_public_key_...` / `live_public_key_...`, which decides
  /// which environment the checkout SDK must run against.
  Environment get _khaltiEnvironment =>
      AppConfig.khaltiPublicKey.startsWith('live_')
      ? Environment.prod
      : Environment.test;

  Future<void> _payWithKhalti() async {
    if (_busy) return;

    setState(() {
      _phase = _KhaltiPhase.initializing;
      _statusMessage = null;
      _transactionId = null;
    });

    try {
      final service = KhaltiService(DioClient.createKhalti());
      final init = await service.initiatePayment(
        amountInPaisa: (widget.vehicle.price * 100).round(),
        purchaseOrderId: 'VEH-${widget.vehicle.id}',
        purchaseOrderName: widget.vehicle.title,
      );

      final khalti = await Khalti.init(
        enableDebugging: true,
        payConfig: KhaltiPayConfig(
          publicKey: AppConfig.khaltiPublicKey,
          pidx: init.pidx,
          paymentUrl: init.paymentUrl,
          environment: _khaltiEnvironment,
        ),
        onPaymentResult: (result, instance) async {
          await _handleKhaltiResult(result);
        },
        onMessage:
            (
              instance, {
              description,
              statusCode,
              event,
              needsPaymentConfirmation,
            }) async {
              // Khalti reports informational and error messages here. Only the
              // ones that change the outcome are surfaced to the user.
              if (!mounted) return;

              // The web view was dismissed without producing a result - drop
              // back to idle so the user can try again.
              if (event == KhaltiEvent.kpgDisposed) {
                if (_phase == _KhaltiPhase.opening) {
                  setState(() => _phase = _KhaltiPhase.idle);
                }
                return;
              }

              if (description == null) return;
              final text = description.toString();
              final isFailure =
                  event == KhaltiEvent.networkFailure ||
                  event == KhaltiEvent.paymentLookupfailure ||
                  statusCode != null;
              if (isFailure && _phase == _KhaltiPhase.opening) {
                setState(() {
                  _phase = _KhaltiPhase.failed;
                  _statusMessage = text;
                });
              }
            },
        onReturn: () async {
          debugPrint('Khalti returned from the payment page');
        },
      );

      // Everything below uses `context`, so the widget must still be alive.
      if (!mounted) return;
      setState(() => _phase = _KhaltiPhase.opening);
      khalti.open(context);
    } on KhaltiInitException catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _KhaltiPhase.failed;
        _statusMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _KhaltiPhase.failed;
        _statusMessage = 'Could not start Khalti: $e';
      });
    }
  }

  Future<void> _handleKhaltiResult(PaymentResult result) async {
    final payload = result.payload;
    final status = payload?.status ?? 'Unknown';

    if (!mounted) return;
    final completed = status.toLowerCase() == 'completed';
    setState(() {
      _transactionId = payload?.transactionId;
      _phase = completed ? _KhaltiPhase.completed : _KhaltiPhase.failed;
      _statusMessage = completed
          ? 'Payment completed.'
          : 'Payment finished with status "$status".';
    });

    if (completed) {
      await _issueReceipt(
        paymentMethod: 'Khalti',
        transactionId: payload?.transactionId,
      );
    }
  }

  Future<void> _issueReceipt({
    required String paymentMethod,
    String? transactionId,
  }) async {
    if (_issuingReceipt) return;
    if (mounted) setState(() => _issuingReceipt = true);

    try {
      final path = await ReceiptSaver.saveAndPreview(
        widget.vehicle,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
        paidAt: DateTime.now(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receipt saved to $path')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create the receipt: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _issuingReceipt = false);
    }
  }

  void _payWithEsewa() {
    context.push(AppRoute.eSewa, extra: widget.vehicle);
  }

  void _reset() {
    setState(() {
      _phase = _KhaltiPhase.idle;
      _statusMessage = null;
      _transactionId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _VehicleSummary(vehicle: widget.vehicle),
          const SizedBox(height: 20),
          if (_statusMessage != null) ...[
            _StatusBanner(
              phase: _phase,
              message: _statusMessage!,
              transactionId: _transactionId,
            ),
            const SizedBox(height: 20),
          ],

          if (_phase == _KhaltiPhase.completed) ...[
            FilledButton.icon(
              onPressed: _issuingReceipt
                  ? null
                  : () => _issueReceipt(
                      paymentMethod: 'Khalti',
                      transactionId: _transactionId,
                    ),
              icon: const Icon(Icons.receipt_long_outlined),
              label: Text(
                _issuingReceipt ? 'Preparing receipt…' : 'View receipt again',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoute.products),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to catalogue'),
            ),
          ] else ...[
            Text('Choose a payment method', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),

            FilledButton.icon(
              onPressed:
                  (!_khaltiConfigured || _busy) ? null : _payWithKhalti,
              icon: _busy
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.account_balance_wallet_outlined),
              label: Text(
                _phase == _KhaltiPhase.initializing
                    ? 'Preparing Khalti…'
                    : _phase == _KhaltiPhase.opening
                    ? 'Waiting for Khalti…'
                    : 'Pay with Khalti',
              ),
            ),

            if (!_khaltiConfigured) ...[
              const SizedBox(height: 8),
              Text(
                'Khalti is not configured. Set KHALTI_PUBLIC_KEY in your .env '
                'file (see .env.example) to enable it.',
                style: theme.textTheme.bodySmall,
              ),
            ],

            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : _payWithEsewa,
              icon: const Icon(Icons.payments_outlined),
              label: const Text('Pay with eSewa'),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              // Deliberately NOT gated on `_busy`: if the checkout web view is
              // dismissed without a result the phase can stay `opening`, and a
              // disabled Reset button would lock the whole screen.
              onPressed: _phase == _KhaltiPhase.initializing ? null : _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset payment state'),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _VehicleSummary extends StatelessWidget {
  const _VehicleSummary({required this.vehicle});

  final ProductEntity vehicle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: vehicle.thumbnail.isEmpty
                ? const Icon(Icons.directions_car, size: 56)
                : Image.network(
                    vehicle.thumbnail,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.directions_car, size: 56),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vehicle.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  '\$${vehicle.price.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.phase,
    required this.message,
    this.transactionId,
  });

  final _KhaltiPhase phase;
  final String message;
  final String? transactionId;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (phase) {
      _KhaltiPhase.completed => (
        Colors.green.shade100,
        Icons.check_circle_outline,
      ),
      _KhaltiPhase.failed => (Colors.red.shade100, Icons.error_outline),
      _KhaltiPhase.initializing => (
        Colors.blue.shade100,
        Icons.hourglass_top,
      ),
      _KhaltiPhase.opening => (Colors.blue.shade100, Icons.open_in_browser),
      _KhaltiPhase.idle => (Colors.grey.shade200, Icons.info_outline),
    };

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: theme.textTheme.bodyMedium),
                if (transactionId != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Transaction ID: $transactionId',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
