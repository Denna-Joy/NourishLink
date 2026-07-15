import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/delivery_provider.dart';
import '../../widgets/widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final deliveryState = ref.watch(deliveryProvider);
    final user = authState.user;

    final driverName = user?.name ?? 'Volunteer Driver';
    final initials = driverName.split(' ').map((e) => e[0]).take(2).join().toUpperCase();
    final volunteerId = user?.volunteerId ?? 'NL-VOL-0000';
    final rating = user?.rating ?? 5.0;
    final totalDeliveries = deliveryState.totalDeliveries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar + Core Info Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isDark ? const Color(0xFF1D3524) : const Color(0xFFE2EBE5),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      // Avatar with glow ring
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colorScheme.primary, width: 2.5),
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                          child: Text(
                            initials,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 32,
                            ),
                          ),
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 16),
                      
                      // Name
                      Text(
                        driverName,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ).animate().fade(delay: 100.ms),
                      
                      const SizedBox(height: 4),
                      
                      // ID tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF16251B) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? const Color(0xFF1D3524) : Colors.grey.shade300),
                        ),
                        child: Text(
                          'VOLUNTEER ID: $volunteerId',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ).animate().fade(delay: 200.ms),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Double Stats Card
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Rescue Rating',
                      value: '$rating / 5.0',
                      icon: Icons.star_rounded,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Total Rescue Operations',
                      value: '$totalDeliveries runs',
                      icon: Icons.volunteer_activism_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ).animate().fade(delay: 250.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 24),
              
              // Settings list options
              Text(
                'SETTINGS & GENERAL',
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
              ).animate().fade(delay: 300.ms),
              const SizedBox(height: 8),
              
              _buildSettingsList(theme, isDark).animate().fade(delay: 350.ms),
              
              const SizedBox(height: 32),
              
              // Logout Button
              ElevatedButton(
                onPressed: () => _showLogoutDialog(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.08),
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, size: 20),
                    SizedBox(width: 10),
                    Text('Logout Session', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ).animate().fade(delay: 450.ms),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MainBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildSettingsList(ThemeData theme, bool isDark) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF1D3524) : const Color(0xFFE2EBE5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            Icons.notifications_active_outlined,
            'Push Notifications',
            'Alerts for local food requests',
            trailingWidget: const Icon(Icons.chevron_right_rounded),
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingsTile(
            Icons.offline_pin_outlined,
            'Offline Map Caches',
            'Download route maps for offline rescue',
            trailingWidget: const Icon(Icons.chevron_right_rounded),
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingsTile(
            Icons.shield_outlined,
            'Security & Consent',
            'Manage verification permissions',
            trailingWidget: const Icon(Icons.chevron_right_rounded),
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingsTile(
            Icons.help_outline_rounded,
            'Help & Community Hub',
            'Contact NourishLink support team',
            trailingWidget: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle, {
    required Widget trailingWidget,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      trailing: trailingWidget,
      onTap: () {},
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Confirm Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to end your active driver session? You will stop receiving pickup requests.'),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                context.pop(); // Close dialog
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
