import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF1D3524) : const Color(0xFFE2EBE5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PickupCard extends StatelessWidget {
  final PickupRequest pickup;
  final VoidCallback onAccept;
  final VoidCallback onTap;

  const PickupCard({
    super.key,
    required this.pickup,
    required this.onAccept,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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

    final deadlineText = DateFormat('hh:mm a').format(pickup.pickupDeadline);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark ? const Color(0xFF1E3324) : const Color(0xFFE2EBE5),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Restaurant & Priority Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pickup.restaurantName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                pickup.pickupAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Priority Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: priorityColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      pickup.priority.name.toUpperCase(),
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              
              const Divider(height: 24, thickness: 1),
              
              // Middle Info Row: Qty, Timer, Distance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconText(
                    context,
                    Icons.shopping_basket_outlined,
                    pickup.foodQuantity,
                    'Quantity',
                  ),
                  _buildIconText(
                    context,
                    Icons.timer_outlined,
                    deadlineText,
                    'Deadline',
                  ),
                  _buildIconText(
                    context,
                    Icons.directions_run_outlined,
                    '${pickup.distance} km',
                    '${pickup.estimatedTravelTime} mins',
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Action Button
              ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Accept Pickup', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconText(BuildContext context, IconData icon, String value, String label) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.primary.withOpacity(0.7)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 22.0),
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const MainBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF1D3524)
                : const Color(0xFFE2EBE5),
            width: 1,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          if (index == currentIndex) return;
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.go('/map');
              break;
            case 2:
              context.go('/history');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
        backgroundColor: theme.colorScheme.surface,
        indicatorColor: theme.colorScheme.primary.withOpacity(0.12),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: theme.colorScheme.primary),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: theme.colorScheme.primary),
            label: 'Route Map',
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_rounded),
            selectedIcon: Icon(Icons.history_toggle_off_rounded, color: theme.colorScheme.primary),
            label: 'History',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: theme.colorScheme.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
