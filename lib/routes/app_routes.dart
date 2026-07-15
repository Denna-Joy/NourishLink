import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/pickups/pickup_detail_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/delivery/delivery_detail_screen.dart';
import '../screens/delivery/confirmation_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/profile/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/dashboard' : '/login',
    
    // Redirect guard logic
    redirect: (BuildContext context, GoRouterState state) {
      final loggedIn = authState.isAuthenticated;
      final isAuthScreen = state.matchedLocation == '/login' || state.matchedLocation == '/forgot-password';

      if (!loggedIn) {
        // Force authentication screens for non-authenticated sessions
        return isAuthScreen ? null : '/login';
      }

      if (loggedIn && isAuthScreen) {
        // Already logged in - bypass auth screens
        return '/dashboard';
      }

      return null; // Keep current path
    },

    routes: [
      // Auth Screen
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main Screens
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/pickup/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PickupDetailScreen(pickupId: id);
        },
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: '/delivery-detail',
        builder: (context, state) => const DeliveryDetailScreen(),
      ),
      GoRoute(
        path: '/confirm-delivery',
        builder: (context, state) => const ConfirmationScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    
    // Fallback Error Screen
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text('Oops! Page not found.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
