import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../providers/restaurant_provider.dart';
import '../constants/theme.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController(text: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&q=80&w=1000');
  final _cookTimeController = TextEditingController();
  final _tagsController = TextEditingController();
  final _originsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food Item'),
        backgroundColor: AppTheme.surface,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (foodProvider.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: AppTheme.error.withAlpha(50),
                      child: Text(foodProvider.error!, style: const TextStyle(color: AppTheme.error)),
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Food Name', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _imageController,
                    decoration: const InputDecoration(labelText: 'Image URL', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cookTimeController,
                    decoration: const InputDecoration(labelText: 'Cook Time (e.g. 15-20)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tagsController,
                    decoration: const InputDecoration(labelText: 'Tags (comma separated)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _originsController,
                    decoration: const InputDecoration(labelText: 'Origins (comma separated)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: foodProvider.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              final tags = _tagsController.text.split(',').map((e) => e.trim()).toList();
                              final origins = _originsController.text.split(',').map((e) => e.trim()).toList();

                              final success = await foodProvider.createFood(
                                name: _nameController.text,
                                price: double.tryParse(_priceController.text) ?? 0,
                                imageUrl: _imageController.text,
                                cookTime: _cookTimeController.text,
                                tags: tags,
                                origins: origins,
                              );
                              if (success && mounted) {
                                // Trigger a fetch just to be safe
                                final restId = context.read<RestaurantProvider>().myRestaurant?.id;
                                if (restId != null) {
                                  context.read<FoodProvider>().fetchFoodsForRestaurant(restId);
                                }
                                Navigator.pop(context);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: foodProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Food', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
