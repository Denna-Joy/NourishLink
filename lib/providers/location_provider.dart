import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../repositories/delivery_repository.dart';
import 'delivery_provider.dart';

class LocationState {
  final double latitude;
  final double longitude;
  final double heading;
  final bool hasPermission;
  final String errorMessage;

  LocationState({
    this.latitude = 37.7749, // Default SF coordinate
    this.longitude = -122.4194,
    this.heading = 0.0,
    this.hasPermission = false,
    this.errorMessage = '',
  });

  LocationState copyWith({
    double? latitude,
    double? longitude,
    double? heading,
    bool? hasPermission,
    String? errorMessage,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
      hasPermission: hasPermission ?? this.hasPermission,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  final Ref _ref;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _simulationTimer;
  int _simulationIndex = 0;

  LocationNotifier(this._ref) : super(LocationState()) {
    initLocation();
  }

  Future<void> initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(errorMessage: 'Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(errorMessage: 'Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(errorMessage: 'Location permissions are permanently denied.');
        return;
      }

      state = state.copyWith(hasPermission: true, errorMessage: '');
      
      // Start live positioning stream
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        _updatePosition(position.latitude, position.longitude, position.heading);
      });

    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  void _updatePosition(double lat, double lng, double head) {
    state = state.copyWith(
      latitude: lat,
      longitude: lng,
      heading: head,
    );
    // Push updates to API backend asynchronously
    _ref.read(deliveryRepositoryProvider).updateLocation(lat, lng);
  }

  // Visual simulation for demonstration purposes (navigating between markers)
  void startNavigationSimulation({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required VoidCallback onComplete,
  }) {
    _positionSubscription?.cancel();
    _simulationTimer?.cancel();
    
    _simulationIndex = 0;
    const steps = 15;
    
    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_simulationIndex >= steps) {
        timer.cancel();
        onComplete();
        // Resume real GPS tracker
        initLocation();
        return;
      }

      final progress = _simulationIndex / steps;
      final currentLat = startLat + (endLat - startLat) * progress;
      final currentLng = startLng + (endLng - startLng) * progress;
      
      _updatePosition(currentLat, currentLng, 45.0);
      _simulationIndex++;
    });
  }

  void stopSimulation() {
    _simulationTimer?.cancel();
    initLocation();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _simulationTimer?.cancel();
    super.dispose();
  }
}

// Expose Location Provider
final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier(ref);
});
