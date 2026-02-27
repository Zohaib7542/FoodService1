import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/restaurant_provider.dart';
import '../providers/food_provider.dart';
import '../constants/theme.dart';
import 'login_screen.dart';
import 'add_food_screen.dart';
import '../models/food.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final restProvider = context.watch<RestaurantProvider>();
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppTheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: restProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : restProvider.myRestaurant == null
              ? _buildCreateRestaurantForm(context, restProvider)
              : _buildDashboardWrapper(context, restProvider),
    );
  }

  Widget _buildDashboardWrapper(BuildContext context, RestaurantProvider restProvider) {
    return FutureBuilder(
      future: context.read<FoodProvider>().fetchFoodsForRestaurant(restProvider.myRestaurant!.id),
      builder: (context, snapshot) {
        return _buildDashboard(context, restProvider, context.watch<FoodProvider>());
      },
    );
  }

  Widget _buildCreateRestaurantForm(BuildContext context, RestaurantProvider provider) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final imageController = TextEditingController(text: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&q=80&w=1000');

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Your Restaurant',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'You need a restaurant profile to add food items.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              if (provider.error != null)
                Text(provider.error!, style: const TextStyle(color: AppTheme.error), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Restaurant Name', prefixIcon: Icon(Icons.store)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Restaurant Address', prefixIcon: Icon(Icons.location_on)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: 'Banner Image URL', prefixIcon: Icon(Icons.image)),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  await provider.createRestaurant(
                    name: nameController.text,
                    address: addressController.text,
                    imageUrl: imageController.text,
                  );
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('Create Profile', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, RestaurantProvider provider, FoodProvider foodProvider) {
    final restaurant = provider.myRestaurant!;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250,
              backgroundColor: Colors.transparent,
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
                          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      left: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.name,
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            restaurant.address,
                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24.0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Menu Items', style: Theme.of(context).textTheme.headlineSmall),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddFoodScreen()),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Food'),
                    )
                  ],
                ),
              ),
            ),
            if (foodProvider.isLoading && foodProvider.foods.isEmpty)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (foodProvider.foods.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text('No food items yet. Add some to get started!', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final food = foodProvider.foods[index];
                      return _buildFoodItemCard(food);
                    },
                    childCount: foodProvider.foods.length,
                  ),
                ),
              ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24.0)),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItemCard(Food food) {
    return Card(
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(food.imageUrl, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('\$${food.price.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
