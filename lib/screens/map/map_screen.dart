import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/delivery_provider.dart';
import '../../providers/location_provider.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  bool _isNavigatingSimulation = false;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // Update camera when location updates
  void _updateCamera(double lat, double lng) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lng), zoom: 15, tilt: 30),
        ),
      );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _triggerRouteSimulation(Delivery activeDelivery, LocationState locState) {
    setState(() => _isNavigatingSimulation = true);
    
    // Simulate route to Restaurant first, then to Charity
    final targetLat = activeDelivery.status == DeliveryStatus.accepted 
        ? activeDelivery.pickupRequest.latitude 
        : activeDelivery.charityLat;
    final targetLng = activeDelivery.status == DeliveryStatus.accepted 
        ? activeDelivery.pickupRequest.longitude 
        : activeDelivery.charityLng;

    ref.read(locationProvider.notifier).startNavigationSimulation(
      startLat: locState.latitude,
      startLng: locState.longitude,
      endLat: targetLat,
      endLng: targetLng,
      onComplete: () async {
        setState(() => _isNavigatingSimulation = false);
        if (activeDelivery.status == DeliveryStatus.accepted) {
          // Arrived at Restaurant - automatically transition status to confirm pickup
          await ref.read(deliveryProvider.notifier).confirmActivePickup();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Arrived at Restaurant! Food pickup confirmed. Route updated to Charity."),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // Arrived at Charity
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Arrived at Charity! Please collect signature and confirm completion."),
                backgroundColor: Colors.green,
              ),
            );
            context.push('/confirm-delivery');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deliveryState = ref.watch(deliveryProvider);
    final locationState = ref.watch(locationProvider);
    final activeDelivery = deliveryState.activeDelivery;

    // Trigger map centering on location update
    ref.listen<LocationState>(locationProvider, (previous, next) {
      if (previous?.latitude != next.latitude || previous?.longitude != next.longitude) {
        _updateCamera(next.latitude, next.longitude);
      }
    });

    if (activeDelivery == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Route Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_rounded, size: 80, color: theme.colorScheme.primary.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  'No Active Delivery Route',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Accept a pickup request from the dashboard to initialize live route mapping and turn-by-turn tracking.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/dashboard'),
                  child: const Text('View Available Pickups'),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const MainBottomNavBar(currentIndex: 1),
      );
    }

    // Set markers
    final driverLatLng = LatLng(locationState.latitude, locationState.longitude);
    final restaurantLatLng = LatLng(activeDelivery.pickupRequest.latitude, activeDelivery.pickupRequest.longitude);
    final charityLatLng = LatLng(activeDelivery.charityLat, activeDelivery.charityLng);

    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('driver'),
        position: driverLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Your Location (Driver)'),
      ),
      Marker(
        markerId: const MarkerId('restaurant'),
        position: restaurantLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(title: activeDelivery.pickupRequest.restaurantName),
      ),
      Marker(
        markerId: const MarkerId('charity'),
        position: charityLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: activeDelivery.charityName),
      ),
    };

    // Construct route polyline
    final Set<Polyline> polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: activeDelivery.status == DeliveryStatus.accepted
            ? [driverLatLng, restaurantLatLng]
            : [driverLatLng, charityLatLng],
        color: theme.colorScheme.primary,
        width: 5,
      ),
    };

    final isPickedUp = activeDelivery.status == DeliveryStatus.pickedUp;

    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: driverLatLng,
              zoom: 14,
            ),
            markers: markers,
            polylines: polylines,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              _updateCamera(locationState.latitude, locationState.longitude);
            },
          ),

          // Floating Top Indicator Panel (ETA, Speed/Heading details)
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Card(
              color: theme.colorScheme.surface.withOpacity(0.95),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.navigation_rounded, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPickedUp ? 'En Route to Charity' : 'En Route to Pickup',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              isPickedUp 
                                  ? activeDelivery.charityName 
                                  : activeDelivery.pickupRequest.restaurantName,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${activeDelivery.estimatedArrivalMinutes} Mins',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          isPickedUp ? 'To Destination' : 'To Restaurant',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fade().slideY(begin: -0.2),
          ),

          // Bottom Control Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Restaurant Name & Contact Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPickedUp ? activeDelivery.charityName : activeDelivery.pickupRequest.restaurantName,
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isPickedUp ? activeDelivery.charityAddress : activeDelivery.pickupRequest.pickupAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Call button
                      InkWell(
                        onTap: () {
                          _makePhoneCall(isPickedUp 
                              ? activeDelivery.charityPhone 
                              : activeDelivery.pickupRequest.restaurantPhone);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.call_rounded, color: theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),

                  // Detail Expand Button / Info summary
                  Row(
                    children: [
                      Icon(Icons.restaurant_menu_rounded, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        activeDelivery.pickupRequest.foodQuantity,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => context.push('/delivery-detail'),
                        icon: const Icon(Icons.info_outline_rounded, size: 16),
                        label: const Text('View Handling Info'),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Navigation Simulation & Completion Button row
                  Row(
                    children: [
                      // Simulated Drive trigger
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isNavigatingSimulation 
                              ? () {
                                  ref.read(locationProvider.notifier).stopSimulation();
                                  setState(() => _isNavigatingSimulation = false);
                                }
                              : () => _triggerRouteSimulation(activeDelivery, locationState),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _isNavigatingSimulation ? Colors.redAccent : theme.colorScheme.primary, width: 2),
                          ),
                          child: Text(
                            _isNavigatingSimulation ? 'Stop Simulation' : 'Drive Route (Sim)',
                            style: TextStyle(
                              color: _isNavigatingSimulation ? Colors.redAccent : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Status Action trigger
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (!isPickedUp) {
                              ref.read(deliveryProvider.notifier).confirmActivePickup();
                            } else {
                              context.push('/confirm-delivery');
                            }
                          },
                          child: Text(!isPickedUp ? 'Confirm Pickup' : 'Confirm Delivery'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fade(delay: 150.ms).slideY(begin: 0.2),
        ],
      ),
      bottomNavigationBar: const MainBottomNavBar(currentIndex: 1),
    );
  }
}
