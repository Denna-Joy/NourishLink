import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/delivery_repository.dart';
import '../models/models.dart';
import 'auth_provider.dart';

// DI for Delivery Repository
final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final storage = ref.watch(storageServiceProvider);
  return DeliveryRepositoryImpl(client, storage);
});

// Delivery State class
class DeliveryState {
  final bool isLoading;
  final String driverStatus; // active, inactive
  final List<PickupRequest> availablePickups;
  final Delivery? activeDelivery;
  final List<HistoryItem> history;
  final int totalDeliveries;
  final int todayPickups;
  final double rating;
  final String? errorMessage;

  DeliveryState({
    this.isLoading = false,
    this.driverStatus = 'inactive',
    this.availablePickups = const [],
    this.activeDelivery,
    this.history = const [],
    this.totalDeliveries = 0,
    this.todayPickups = 0,
    this.rating = 5.0,
    this.errorMessage,
  });

  DeliveryState copyWith({
    bool? isLoading,
    String? driverStatus,
    List<PickupRequest>? availablePickups,
    Delivery? activeDelivery,
    bool clearActiveDelivery = false,
    List<HistoryItem>? history,
    int? totalDeliveries,
    int? todayPickups,
    double? rating,
    String? errorMessage,
  }) {
    return DeliveryState(
      isLoading: isLoading ?? this.isLoading,
      driverStatus: driverStatus ?? this.driverStatus,
      availablePickups: availablePickups ?? this.availablePickups,
      activeDelivery: clearActiveDelivery ? null : (activeDelivery ?? this.activeDelivery),
      history: history ?? this.history,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      todayPickups: todayPickups ?? this.todayPickups,
      rating: rating ?? this.rating,
      errorMessage: errorMessage,
    );
  }
}

// Delivery State Notifier
class DeliveryNotifier extends StateNotifier<DeliveryState> {
  final DeliveryRepository _repository;

  DeliveryNotifier(this._repository) : super(DeliveryState()) {
    refreshDashboard();
  }

  Future<void> refreshDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final status = await _repository.getDriverStatus();
      final stats = await _repository.getDriverStats();
      final pickups = await _repository.getAvailablePickups();
      final historyList = await _repository.getDeliveryHistory();
      
      state = state.copyWith(
        isLoading: false,
        driverStatus: status,
        totalDeliveries: stats['totalDeliveries'] ?? 0,
        todayPickups: stats['todayPickups'] ?? 0,
        rating: (stats['rating'] ?? 5.0) as double,
        availablePickups: pickups,
        history: historyList,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> toggleDriverStatus() async {
    final nextStatus = state.driverStatus == 'active' ? 'inactive' : 'active';
    state = state.copyWith(driverStatus: nextStatus);
    try {
      await _repository.updateDriverStatus(nextStatus);
    } catch (_) {
      // Revert if error occurs (optional, here we proceed for simulation)
    }
  }

  Future<bool> acceptPickupRequest(String requestId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final delivery = await _repository.acceptPickup(requestId);
      state = state.copyWith(
        isLoading: false,
        activeDelivery: delivery,
        availablePickups: state.availablePickups.where((p) => p.id != requestId).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> confirmActivePickup() async {
    if (state.activeDelivery == null) return false;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final delivery = await _repository.confirmPickup(state.activeDelivery!.id);
      state = state.copyWith(
        isLoading: false,
        activeDelivery: delivery,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> completeActiveDelivery({
    required String signaturePath,
    required String photoProofPath,
  }) async {
    if (state.activeDelivery == null) return false;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final delivery = await _repository.completeDelivery(
        deliveryId: state.activeDelivery!.id,
        signaturePath: signaturePath,
        photoProofPath: photoProofPath,
      );

      // Successfully completed, refresh dashboard values & update counts locally
      final updatedHistory = [
        HistoryItem(
          id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
          restaurantName: delivery.pickupRequest.restaurantName,
          charityName: delivery.charityName,
          date: DateTime.now(),
          distance: delivery.pickupRequest.distance,
          foodQuantity: delivery.pickupRequest.foodQuantity,
          status: 'completed',
        ),
        ...state.history
      ];

      state = state.copyWith(
        isLoading: false,
        clearActiveDelivery: true,
        totalDeliveries: state.totalDeliveries + 1,
        todayPickups: state.todayPickups + 1,
        history: updatedHistory,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  void cancelActiveDeliveryLocal() {
    state = state.copyWith(clearActiveDelivery: true);
  }
}

// Expose Delivery State Provider
final deliveryProvider = StateNotifierProvider<DeliveryNotifier, DeliveryState>((ref) {
  final repo = ref.watch(deliveryRepositoryProvider);
  return DeliveryNotifier(repo);
});
