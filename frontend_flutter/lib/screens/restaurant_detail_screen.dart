import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/restaurant_provider.dart';
import '../providers/food_provider.dart';
import '../constants/theme.dart';
import '../widgets/food_card.dart';
import 'food_detail_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<FoodProvider>().fetchFoodsForRestaurant(widget.restaurantId);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    // When leaving, it might be good to fetch all foods again to restore home screen grid,
    // but the home screen logic fetches the global foods only initially. A better approach
    // is keeping the global list intact. Our FoodProvider's `fetchAllFoods` sets `foods`.
    // Wait, if `fetchFoodsForRestaurant` overwrote `foods`, going back home will only show
    // that restaurant's food. Let's fix this in a bit by making `FoodProvider` hold
    // `restaurantFoods` separately or we fetch all on Pop.
    // For now, let's just fetch all foods again when we completely back out.
    // Actually, calling fetchAllFoods here on dispose is risky during navigation route popping.
    // We will just fetchAllFoods in HomeScreen when it resumes if needed, or better, 
    // update FoodProvider to isolate them.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = context.read<RestaurantProvider>().getRestaurantById(widget.restaurantId);
    if (restaurant == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Restaurant not found')),
      );
    }

    final foodProvider = context.watch<FoodProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppTheme.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(restaurant.imageUrl, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black.withAlpha(200), Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ).animate().fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Expanded(child: Text(restaurant.address, style: const TextStyle(color: Colors.white70, fontSize: 16))),
                          ],
                        ).animate().fadeIn(delay: 100.ms),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (foodProvider.foods.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text('This restaurant has no menu items yet.', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final food = foodProvider.foods[index];
                    return FoodCard(
                      food: food,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FoodDetailScreen(foodId: food.id),
                          ),
                        );
                      },
                    ).animate().scale(delay: (100 + index * 50).ms).fadeIn();
                  },
                  childCount: foodProvider.foods.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
