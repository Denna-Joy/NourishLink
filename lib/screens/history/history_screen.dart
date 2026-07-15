import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/delivery_provider.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final deliveryState = ref.watch(deliveryProvider);
    final history = deliveryState.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery History', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: history.isEmpty
            ? _buildEmptyState(theme).animate().fade()
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF1D3524) : const Color(0xFFE2EBE5),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date + Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.formattedDate,
                                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded, size: 10, color: Colors.green),
                                    SizedBox(width: 4),
                                    Text(
                                      'COMPLETED',
                                      style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const Divider(height: 20),
                          
                          // Locations
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Icon(Icons.circle_outlined, size: 14, color: theme.colorScheme.primary),
                                  Container(width: 2, height: 20, color: Colors.grey.shade300),
                                  Icon(Icons.location_on_rounded, size: 14, color: Colors.green.shade600),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.restaurantName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      item.charityName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const Divider(height: 24),
                          
                          // Food and Distance summary
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 6),
                                  Text(
                                    item.foodQuantity,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.social_distance_rounded, size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${item.distance} km',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fade(delay: (100 * index).ms).slideY(begin: 0.1),
                  );
                },
              ),
      ),
      bottomNavigationBar: const MainBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off_rounded, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Deliveries Yet',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your first rescue operation to store logs here. Toggle online status to start.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
