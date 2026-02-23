import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/theme.dart';
import 'home_screen.dart';

class OrderTrackScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Order Track'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false, // Force them to use the home button
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Success Animation (fallback to icon if no lottie file provided)
              // Since we don't have a lottie file, we use a nice animated icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, size: 100, color: AppTheme.primary),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              
              const SizedBox(height: 32),
              
              Text(
                'Order Placed Successfully!',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 16),
              
              Text(
                'Order ID: $orderId\nYour food is being prepared.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 48),
              
              _HoverableButton(
                text: 'Back to Home',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ).animate().fadeIn(delay: 600.ms).scale(),
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

  const _HoverableButton({required this.text, required this.onPressed});

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
        scale: _isHovered ? 1.05 : 1.0,
        duration: 200.ms,
        curve: Curves.easeOut,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: _isHovered ? AppTheme.primary.withAlpha(50) : Colors.transparent,
            side: const BorderSide(color: AppTheme.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: widget.onPressed,
          child: Text(
            widget.text,
            style: const TextStyle(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

