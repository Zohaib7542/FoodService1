import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/restaurant_provider.dart';
import 'providers/food_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final authProvider = AuthProvider();
  await authProvider.checkLoginStatus();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProxyProvider<AuthProvider, RestaurantProvider>(
          create: (ctx) => RestaurantProvider(authProvider: ctx.read<AuthProvider>()),
          update: (ctx, auth, previous) => RestaurantProvider(authProvider: auth)..fetchMyRestaurant(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, FoodProvider>(
          create: (ctx) => FoodProvider(authProvider: ctx.read<AuthProvider>()),
          update: (ctx, auth, previous) => FoodProvider(authProvider: auth),
        ),
      ],
      child: const OwnerApp(),
    ),
  );
}

class OwnerApp extends StatelessWidget {
  const OwnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Owner Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: AppTheme.primary,
          surface: AppTheme.surface,
          background: AppTheme.background,
        ),
        scaffoldBackgroundColor: AppTheme.background,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
