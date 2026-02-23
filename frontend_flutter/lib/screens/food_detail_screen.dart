import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/theme.dart';
import '../constants/urls.dart';
import '../models/food.dart';
import '../providers/food_provider.dart';
import '../providers/cart_provider.dart';

class FoodDetailScreen extends StatefulWidget {
  final String foodId;

  const FoodDetailScreen({super.key, required this.foodId});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  Food? food;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFood();
  }

  Future<void> _loadFood() async {
    food = await context.read<FoodProvider>().getFoodById(widget.foodId);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (food == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('Food not found')),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.background.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: const BackButton(color: AppTheme.textPrimary),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.background.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                food!.favorite ? Icons.favorite : Icons.favorite_border,
                color: AppTheme.error,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Parallax Hero Image
            Hero(
              tag: 'food_image_${food!.id}',
              child: Image.network(
                food!.imageUrl.startsWith('http')
                    ? food!.imageUrl
                    : '${AppUrls.baseUrl}/${food!.imageUrl}',
                height: 350,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // Content Container
            Container(
              transform: Matrix4.translationValues(0, -30, 0),
              decoration: const BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            food!.name,
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                        ),
                        Text(
                          '\$${food!.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: AppTheme.primary,
                                fontSize: 24,
                              ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Meta Row
                    Row(
                      children: [
                        _buildMetaBadge(context, Icons.star, Colors.amber[600]!, food!.stars.toString()),
                        const SizedBox(width: 16),
                        _buildMetaBadge(context, Icons.timer_outlined, AppTheme.secondary, food!.cookTime),
                      ],
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
                    const SizedBox(height: 24),

                    // Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: food!.tags.map((t) => Chip(
                        label: Text(t),
                        backgroundColor: AppTheme.background,
                        side: BorderSide(color: AppTheme.surface),
                      )).toList(),
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
                    const SizedBox(height: 24),

                    // Origins
                    Text(
                      'Origins',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 18),
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: food!.origins.map((o) => Text(
                        o,
                        style: Theme.of(context).textTheme.bodyMedium,
                      )).toList(),
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 100), // padding for bottom bar
                  ],
                ),
              ),
            ),
          ],
        ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Align(
          heightFactor: 1.0,
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(0, -4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Row(
              children: [
                // Mini Food Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    food!.imageUrl.startsWith('http')
                        ? food!.imageUrl
                        : '${AppUrls.baseUrl}/${food!.imageUrl}',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 50,
                      height: 50,
                      color: AppTheme.background,
                      child: const Icon(Icons.fastfood, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Food Info
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food!.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '\$${food!.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Add to Cart Button
                _HoverableButton(
                  text: 'Add to Cart',
                  onPressed: () {
                    context.read<CartProvider>().addToCart(food!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Added to Cart!'),
                        backgroundColor: AppTheme.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ).animate().scale(delay: 700.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildMetaBadge(BuildContext context, IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
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
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(120, 50),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            backgroundColor: _isHovered ? AppTheme.primary.withAlpha(200) : AppTheme.primary,
          ),
          onPressed: widget.onPressed,
          child: Text(widget.text, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}

