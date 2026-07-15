import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/delivery_provider.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final deliveryState = ref.watch(deliveryProvider);
    final theme = Theme.of(context);

    // Watch for error states
    ref.listen<DeliveryState>(deliveryProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final driverName = authState.user?.name ?? 'Driver';
    final isOnline = deliveryState.driverStatus == 'active';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.eco_rounded, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 10),
            Text(
              'NourishLink',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        actions: [
          // Online Status Badge + Toggle Switch
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isOnline ? Colors.greenAccent : Colors.grey,
                  shape: BoxShape.circle,
                  boxShadow: isOnline
                      ? [
                          BoxShadow(
                            color: Colors.greenAccent.withOpacity(0.8),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isOnline ? 'ONLINE' : 'OFFLINE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isOnline ? theme.colorScheme.primary : Colors.grey,
                ),
              ),
              Switch(
                value: isOnline,
                onChanged: (val) {
                  ref.read(deliveryProvider.notifier).toggleDriverStatus();
                },
                activeColor: theme.colorScheme.primary,
              ),
            ],
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(deliveryProvider.notifier).refreshDashboard(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Header
              Text(
                'Welcome back,',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
              ).animate().fade(),
              Text(
                driverName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ).animate().fade(delay: 100.ms).slideX(begin: -0.05),
              
              const SizedBox(height: 20),
              
              // Active Delivery Banner Alert if exists
              if (deliveryState.activeDelivery != null)
                _buildActiveDeliveryBanner(context, deliveryState.activeDelivery!, theme)
                    .animate()
                    .shake(delay: 500.ms, hz: 4)
                    .fade(),

              const SizedBox(height: 10),

              // Statistics grid (today's count, total count, rating)
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: "Today's Pickups",
                      value: '${deliveryState.todayPickups}',
                      icon: Icons.local_shipping_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: "Completed",
                      value: '${deliveryState.totalDeliveries}',
                      icon: Icons.check_circle_rounded,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: "Rating",
                      value: '${deliveryState.rating}',
                      icon: Icons.star_rounded,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

              const SizedBox(height: 28),

              // Pickup Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Pickups',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (deliveryState.isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ).animate().fade(delay: 300.ms),

              const SizedBox(height: 12),

              // Pickups list loading state or list
              if (!isOnline)
                _buildOfflineState(theme).animate().fade(duration: 400.ms)
              else if (deliveryState.availablePickups.isEmpty)
                _buildEmptyState(theme).animate().fade(duration: 400.ms)
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: deliveryState.availablePickups.length,
                  itemBuilder: (context, index) {
                    final pickup = deliveryState.availablePickups[index];
                    return PickupCard(
                      pickup: pickup,
                      onAccept: () async {
                        final success = await ref
                            .read(deliveryProvider.notifier)
                            .acceptPickupRequest(pickup.id);
                        if (success && context.mounted) {
                          context.go('/map');
                        }
                      },
                      onTap: () {
                        context.push('/pickup/${pickup.id}');
                      },
                    ).animate().fade(delay: (100 * index).ms).slideY(begin: 0.1);
                  },
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MainBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildActiveDeliveryBanner(BuildContext context, Delivery delivery, ThemeData theme) {
    return Card(
      color: theme.colorScheme.primaryContainer,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3), width: 1.5),
      ),
      child: InkWell(
        onTap: () => context.go('/map'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.navigation_rounded, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE DELIVERY RUNNING',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Route to: ${delivery.pickupRequest.restaurantName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineState(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
        child: Column(
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'You are Offline',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Toggle the switch to ONLINE at the top to display and accept food pickup requests.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
        child: Column(
          children: [
            Icon(Icons.volunteer_activism_rounded, size: 64, color: theme.colorScheme.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No Available Pickups',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Everything is picked up! Good job. Check back soon for new volunteer opportunities.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
