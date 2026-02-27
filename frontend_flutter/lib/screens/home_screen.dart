import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/theme.dart';
import '../providers/food_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/food_card.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/loyalty_card.dart';
import 'food_detail_screen.dart';
import 'cart_screen.dart';
import 'restaurant_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _selectedTag = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodProvider>().fetchAllFoods();
      context.read<FoodProvider>().fetchAllTags();
    });
  }

  void _onSearch(String term) {
    setState(() => _selectedTag = 'All');
    context.read<FoodProvider>().searchFoods(term);
  }

  void _onTagSelected(String tag) {
    setState(() {
      _selectedTag = tag;
      _searchController.clear();
    });
    context.read<FoodProvider>().filterByTag(tag);
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();
    final cartProvider = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final restProvider = context.watch<RestaurantProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${auth.currentUser?.name.split(' ').first ?? 'Guest'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ).animate().fadeIn(),
            Text(
              'What do you want to eat?',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20),
            ).animate().fadeIn(delay: 100.ms),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              label: Text(cartProvider.cart.totalCount.toString()),
              isLabelVisible: cartProvider.cart.totalCount > 0,
              child: const Icon(Icons.shopping_cart_outlined, color: AppTheme.textPrimary),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ).animate().scale(delay: 200.ms),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.error),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
            slivers: [
              // Loyalty Card
              SliverToBoxAdapter(
                child: auth.currentUser != null
                  ? LoyaltyCard(points: auth.currentUser!.loyaltyPoints)
                  : const SizedBox(),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: _onSearch,
                    decoration: InputDecoration(
                      hintText: 'Search food...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: () {},
                      ),
                    ),
                  ).animate().slideY(begin: 0.2).fadeIn(delay: 300.ms),
                ),
              ),

              // Tags
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: foodProvider.tags.length,
                    itemBuilder: (context, index) {
                      final tag = foodProvider.tags[index];
                      final isSelected = _selectedTag == tag.name;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _HoverableTag(
                          tag: tag.name,
                          isSelected: isSelected,
                          onSelected: () => _onTagSelected(tag.name),
                        ),
                      ).animate().slideX(begin: 0.2, delay: (400 + index * 50).ms).fadeIn();
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Restaurants List
              if (restProvider.restaurants.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Partner Restaurants', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: restProvider.restaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = restProvider.restaurants[index];
                        return RestaurantCard(
                          restaurant: restaurant,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => RestaurantDetailScreen(restaurantId: restaurant.id)));
                          },
                        ).animate().fadeIn(delay: (300 + index * 50).ms).slideX(begin: 0.1);
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Explore Menu Items', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],

              // Grid
              if (foodProvider.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                )
              else if (foodProvider.foods.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No foods found',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ).animate().fadeIn(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                        ).animate().scale(delay: (200 + index % 10 * 50).ms).fadeIn();
                      },
                      childCount: foodProvider.foods.length,
                    ),
                  ),
                ),
            ],
          ),
      ),
    );
  }
}

class _HoverableTag extends StatefulWidget {
  final String tag;
  final bool isSelected;
  final VoidCallback onSelected;

  const _HoverableTag({
    required this.tag,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  State<_HoverableTag> createState() => _HoverableTagState();
}

class _HoverableTagState extends State<_HoverableTag> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isHovered ? 1.05 : 1.0,
      duration: 200.ms,
      curve: Curves.easeOut,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: FilterChip(
          label: Text(widget.tag),
          selected: widget.isSelected,
          onSelected: (_) => widget.onSelected(),
          backgroundColor: AppTheme.surface,
          selectedColor: AppTheme.primary,
          labelStyle: GoogleFonts.inter(
            color: widget.isSelected ? Colors.white : AppTheme.textPrimary,
            fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: widget.isSelected 
                ? AppTheme.primary 
                : (_isHovered ? AppTheme.primary.withAlpha(150) : AppTheme.surface),
            ),
          ),
        ),
      ),
    );
  }
}
