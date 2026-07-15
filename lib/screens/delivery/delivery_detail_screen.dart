import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/delivery_provider.dart';
import '../../models/models.dart';

class DeliveryDetailScreen extends ConsumerStatefulWidget {
  const DeliveryDetailScreen({super.key});

  @override
  ConsumerState<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends ConsumerState<DeliveryDetailScreen> {
  Timer? _countdownTimer;
  int _remainingSeconds = 1800; // 30 mins default

  @override
  void initState() {
    super.initState();
    final active = ref.read(deliveryProvider).activeDelivery;
    if (active != null) {
      _remainingSeconds = active.pickupTimerMinutes * 60;
    }
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _makeCall(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deliveryState = ref.watch(deliveryProvider);
    final activeDelivery = deliveryState.activeDelivery;

    if (activeDelivery == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Active Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No active delivery found.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    final isPickedUp = activeDelivery.status == DeliveryStatus.pickedUp;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Instructions', style: TextStyle(fontWeight: FontWeight.bold)),
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
              // Progress Timeline Stepper
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStep(context, 'Accepted', true, true),
                      _buildLine(context, isPickedUp),
                      _buildStep(context, 'Picked Up', isPickedUp, isPickedUp),
                      _buildLine(context, activeDelivery.status == DeliveryStatus.completed),
                      _buildStep(context, 'Delivered', activeDelivery.status == DeliveryStatus.completed, false),
                    ],
                  ),
                ),
              ).animate().fade(),
              
              const SizedBox(height: 16),

              // Countdown Timer panel (if in accepted phase)
              if (!isPickedUp)
                Card(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        Text(
                          'TIME REMAINING FOR PICKUP',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.hourglass_bottom_rounded, color: theme.colorScheme.primary, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              _formattedTime,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 32,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(delay: 100.ms),

              const SizedBox(height: 16),

              // Handling Instructions
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.healing_rounded, color: theme.colorScheme.primary),
                          const SizedBox(width: 10),
                          Text(
                            'FOOD HANDLING PROTOCOL',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        activeDelivery.foodHandlingInstructions,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      // Sustainability Badge
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withOpacity(0.2)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shield_outlined, color: Colors.green, size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Food Safety Guard: Ensure all packages remain properly sealed and secured in containers.',
                                style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

              const SizedBox(height: 16),

              // Emergency Contact details
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.contact_support_rounded, color: Colors.redAccent),
                          SizedBox(width: 10),
                          Text(
                            'EMERGENCY & SUPPORT',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'In case of road delays, traffic accidents, vehicle breakdowns, or issues at the location, trigger the hotlink below.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent, width: 2),
                        ),
                        onPressed: () => _makeCall(activeDelivery.emergencyContact),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.call_rounded, color: Colors.redAccent),
                            const SizedBox(width: 10),
                            Text(
                              'Call Dispatcher (${activeDelivery.emergencyContact})',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String label, bool isActive, bool isPast) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? theme.colorScheme.primary : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPast ? Icons.check_rounded : Icons.radio_button_checked_rounded,
            size: 16,
            color: isActive ? Colors.white : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? theme.colorScheme.primary : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(BuildContext context, bool isActive) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        height: 3,
        color: isActive ? theme.colorScheme.primary : Colors.grey.shade300,
      ),
    );
  }
}
