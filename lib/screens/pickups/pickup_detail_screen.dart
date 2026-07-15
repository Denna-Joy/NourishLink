import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/delivery_provider.dart';
import '../../models/models.dart';

class PickupDetailScreen extends ConsumerWidget {
  final String pickupId;

  const PickupDetailScreen({super.key, required this.pickupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final deliveryState = ref.watch(deliveryProvider);
    
    // Find the pickup request by ID in state
    final pickup = deliveryState.availablePickups.firstWhere(
      (p) => p.id == pickupId,
      orElse: () => PickupRequest(
        id: '',
        restaurantName: 'Not Found',
        restaurantPhone: '',
        pickupAddress: 'Unknown Location',
        latitude: 0,
        longitude: 0,
        foodQuantity: '',
        pickupDeadline: DateTime.now(),
        distance: 0,
        estimatedTravelTime: 0,
        priority: PriorityLevel.low,
      ),
    );

    if (pickup.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Request Details')),
        body: const Center(child: Text('Pickup request not found or already accepted.')),
      );
    }

    Color priorityColor;
    switch (pickup.priority) {
      case PriorityLevel.high:
        priorityColor = Colors.redAccent;
        break;
      case PriorityLevel.medium:
        priorityColor = Colors.orangeAccent;
        break;
      case PriorityLevel.low:
        priorityColor = Colors.blueAccent;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card Details
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Priority and ID row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'RESCUE RUN ID: #${pickup.id}',
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: priorityColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              pickup.priority.name.toUpperCase(),
                              style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Restaurant Title
                      Text(
                        pickup.restaurantName,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Phone contact
                      Row(
                        children: [
                          Icon(Icons.phone_rounded, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(pickup.restaurantPhone, style: theme.textTheme.bodyLarge),
                        ],
                      ),
                      
                      const Divider(height: 36, thickness: 1),
                      
                      // Location Details
                      Text(
                        'PICKUP LOCATION',
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pickup.pickupAddress,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.directions_car_rounded, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            '${pickup.distance} km away  •  Est. travel: ${pickup.estimatedTravelTime} mins',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      
                      const Divider(height: 36, thickness: 1),
                      
                      // Food Details
                      Text(
                        'FOOD DETAILS',
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.shopping_basket_rounded, size: 24, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              pickup.foodQuantity,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      
                      const Divider(height: 36, thickness: 1),
                      
                      // Deadline Details
                      Text(
                        'PICKUP DEADLINE',
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.alarm_rounded, size: 24, color: Colors.redAccent),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('hh:mm a (EEEE)').format(pickup.pickupDeadline),
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Must pick up within ${pickup.pickupDeadline.difference(DateTime.now()).inMinutes} minutes',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.redAccent, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fade().scale(duration: 400.ms, curve: Curves.easeOutQuad),
              
              const SizedBox(height: 24),
              
              // Accept Action Button
              ElevatedButton(
                onPressed: () async {
                  final success = await ref
                      .read(deliveryProvider.notifier)
                      .acceptPickupRequest(pickup.id);
                  if (success && context.mounted) {
                    context.go('/map');
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 22),
                    SizedBox(width: 12),
                    Text('Accept & Start Route', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
