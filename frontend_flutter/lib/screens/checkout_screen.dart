import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/theme.dart';
import '../models/order.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  final _formKey = GlobalKey<FormState>();

  int _pointsToRedeem = 0;
  bool _isRedeeming = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController = TextEditingController(text: auth.currentUser?.name ?? '');
    _addressController = TextEditingController(text: auth.currentUser?.address ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final auth = context.read<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Delivery Details',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24),
              ).animate().fadeIn().slideX(begin: -0.1),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v!.isEmpty ? 'Please enter name' : null,
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Please enter address' : null,
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal'),
                        Text('\$${cartProvider.cart.totalPrice.toStringAsFixed(2)}'),
                      ],
                    ),
                    if (auth.currentUser != null && auth.currentUser!.loyaltyPoints > 0) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, color: AppTheme.primary, size: 16),
                              const SizedBox(width: 8),
                              Text('Use Points (${auth.currentUser!.loyaltyPoints} available)'),
                            ],
                          ),
                          Switch(
                            value: _isRedeeming,
                            activeColor: AppTheme.primary,
                            onChanged: (val) {
                              setState(() {
                                _isRedeeming = val;
                                if (val) {
                                  // Max points to use cannot exceed total price in cents
                                  int maxPointsForOrder = (cartProvider.cart.totalPrice * 100).toInt();
                                  _pointsToRedeem = auth.currentUser!.loyaltyPoints > maxPointsForOrder 
                                      ? maxPointsForOrder 
                                      : auth.currentUser!.loyaltyPoints;
                                } else {
                                  _pointsToRedeem = 0;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      if (_isRedeeming)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Points Discount ($_pointsToRedeem pts)',
                              style: const TextStyle(color: AppTheme.primary),
                            ),
                            Text(
                              '-\$${(_pointsToRedeem / 100).toStringAsFixed(2)}',
                              style: const TextStyle(color: AppTheme.primary),
                            ),
                          ],
                        ),
                    ],
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${(cartProvider.cart.totalPrice - (_pointsToRedeem / 100)).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().scale(delay: 300.ms).fadeIn(),

              const SizedBox(height: 48),

              _HoverableButton(
                text: 'Proceed to Payment',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Calculate final total
                    double finalTotal = cartProvider.cart.totalPrice - (_pointsToRedeem / 100);
                    
                    if (_isRedeeming && _pointsToRedeem > 0) {
                      // Call the new endpoints we made to deduct
                      try {
                        await auth.redeemPoints(_pointsToRedeem);
                      } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Failed to redeem points: $e'))
                         );
                         return;
                      }
                    }

                    final newOrder = Order(
                      id: 0,
                      items: cartProvider.cart.items,
                      totalPrice: finalTotal, // Use the discounted total
                      name: _nameController.text,
                      address: _addressController.text,
                      paymentId: '', // To be filled in payment screen
                      createdAt: DateTime.now().toIso8601String(),
                      status: 'NEW',
                    );

                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(order: newOrder),
                        ),
                      );
                    }
                  }
                },
                isLoading: orderProvider.isLoading,
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
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
            minimumSize: const Size(double.infinity, 56),
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

