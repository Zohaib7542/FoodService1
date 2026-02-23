import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../constants/theme.dart';
import '../constants/urls.dart';
import '../models/order.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import 'order_track_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Order order;

  const PaymentScreen({super.key, required this.order});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  bool _isProcessingRazorpay = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final auth = context.read<AuthProvider>();
    
    // Verify signature on backend
    try {
      final verifyRes = await http.post(
        Uri.parse(AppUrls.orderVerifyRazorpayUrl),
        headers: {
          'Content-Type': 'application/json',
          'access_token': auth.token,
        },
        body: json.encode({
          'orderId': response.orderId,
          'paymentId': response.paymentId,
          'signature': response.signature,
        }),
      );

      if (verifyRes.statusCode == 200) {
        if (mounted) {
          context.read<CartProvider>().clearCart();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => OrderTrackScreen(orderId: widget.order.paymentId),
            ),
            (route) => route.isFirst,
          );
        }
      } else {
        setState(() => _isProcessingRazorpay = false);
        _showError('Payment verification failed.');
      }
    } catch (e) {
      setState(() => _isProcessingRazorpay = false);
      _showError('Error verifying payment.');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessingRazorpay = false);
    _showError('Payment Failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessingRazorpay = false);
    _showError('External wallets not supported in this demo.');
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _startRazorpayCheckout() async {
    setState(() => _isProcessingRazorpay = true);
    
    final orderProvider = context.read<OrderProvider>();
    final auth = context.read<AuthProvider>();

    // 1. First create the base order in the database
    widget.order.paymentId = 'TEMP_RAZORPAY_${DateTime.now().millisecondsSinceEpoch}';
    final success = await orderProvider.createOrder(widget.order, auth);
    
    if (!success) {
      setState(() => _isProcessingRazorpay = false);
      _showError(orderProvider.error ?? 'Failed to create base order');
      return;
    }

    // 2. Create Razorpay order to get the Order ID
    try {
      final res = await http.post(
        Uri.parse(AppUrls.orderCreateRazorpayUrl),
        headers: {
          'Content-Type': 'application/json',
          'access_token': auth.token,
        },
        body: json.encode({'amount': widget.order.totalPrice}),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        
        var options = {
          'key': data['key_id'],
          'amount': data['amount'],
          'currency': data['currency'],
          'name': 'SevaSync Food Service',
          'description': 'Food App Checkout',
          'order_id': data['id'],
          'prefill': {
            'contact': '9876543210',
            'email': auth.currentUser?.email ?? 'test@example.com',
          },
          'theme': {'color': '#9C27B0'},
        };

        _razorpay.open(options);
      } else {
        setState(() => _isProcessingRazorpay = false);
        _showError('Failed to initialize Razorpay');
      }
    } catch (e) {
      setState(() => _isProcessingRazorpay = false);
      _showError('Network error starting checkout');
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payment, size: 80, color: AppTheme.primary)
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                'Total: \$${widget.order.totalPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 16),
              Text(
                'This is a dummy payment integration for the demo.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 48),

              if (orderProvider.error != null)
                Text(
                  orderProvider.error!,
                  style: const TextStyle(color: AppTheme.error),
                ).animate().fadeIn(),

              _HoverableButton(
                text: 'Pay with Razorpay',
                onPressed: _startRazorpayCheckout,
                isLoading: orderProvider.isLoading || _isProcessingRazorpay,
              ).animate().scale(delay: 400.ms).fadeIn(),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _HoverableButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const _HoverableButton({
    required this.text, 
    required this.onPressed, 
    this.isLoading = false,
  });

  @override
  State<_HoverableButton> createState() => _HoverableButtonState();
}

class _HoverableButtonState extends State<_HoverableButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered && !widget.isLoading ? 1.05 : 1.0,
        duration: 200.ms,
        curve: Curves.easeOut,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(200, 50),
            backgroundColor: _isHovered && !widget.isLoading ? AppTheme.primary.withAlpha(200) : AppTheme.primary,
          ),
          onPressed: widget.isLoading ? null : widget.onPressed,
          child: widget.isLoading 
              ? const SizedBox(
                  height: 20, 
                  width: 20, 
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                )
              : Text(widget.text, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
