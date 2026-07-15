import 'dart:io';
import 'package:dio/dio.dart';
import '../core/services/api_client.dart';
import '../core/services/storage_service.dart';
import '../core/constants/constants.dart';
import '../models/models.dart';

abstract class DeliveryRepository {
  Future<String> getDriverStatus();
  Future<void> updateDriverStatus(String status);
  Future<Map<String, dynamic>> getDriverStats();
  Future<List<PickupRequest>> getAvailablePickups();
  Future<Delivery> acceptPickup(String requestId);
  Future<void> updateLocation(double lat, double lng);
  Future<Delivery> confirmPickup(String deliveryId);
  Future<Delivery> completeDelivery({
    required String deliveryId,
    required String signaturePath,
    required String photoProofPath,
  });
  Future<List<HistoryItem>> getDeliveryHistory();
}

class DeliveryRepositoryImpl implements DeliveryRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  DeliveryRepositoryImpl(this._apiClient, this._storageService);

  @override
  Future<String> getDriverStatus() async {
    return _storageService.getDriverStatus();
  }

  @override
  Future<void> updateDriverStatus(String status) async {
    await _storageService.setDriverStatus(status);
    try {
      await _apiClient.put(ApiEndpoints.status, data: {'status': status});
    } catch (_) {
      // Fail silently for mock/offline compatibility
    }
  }

  @override
  Future<Map<String, dynamic>> getDriverStats() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.stats);
      return response.data;
    } catch (_) {
      // Mock stats
      return {
        'totalDeliveries': 42,
        'todayPickups': 3,
        'rating': 4.9,
      };
    }
  }

  @override
  Future<List<PickupRequest>> getAvailablePickups() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.pickupRequests);
      final List data = response.data;
      return data.map((json) => PickupRequest.fromJson(json)).toList();
    } catch (_) {
      // Return realistic mock pickup requests with premium green sustainability parameters
      await Future.delayed(const Duration(milliseconds: 600));
      return [
        PickupRequest(
          id: 'req_101',
          restaurantName: 'Green Bite Bistro',
          restaurantPhone: '+1 (555) 019-2834',
          pickupAddress: '842 Leafy Green Blvd, Sector 4',
          latitude: 37.7793,
          longitude: -122.4192,
          foodQuantity: '15 Meals (Salads & Wraps)',
          pickupDeadline: DateTime.now().add(const Duration(minutes: 45)),
          distance: 1.2,
          estimatedTravelTime: 6,
          priority: PriorityLevel.high,
        ),
        PickupRequest(
          id: 'req_102',
          restaurantName: 'The Organic Kitchen',
          restaurantPhone: '+1 (555) 012-7634',
          pickupAddress: '312 Harvest Ave, Downtown',
          latitude: 37.7845,
          longitude: -122.4021,
          foodQuantity: '8 Large Containers (Soup & Rice)',
          pickupDeadline: DateTime.now().add(const Duration(hours: 2)),
          distance: 3.4,
          estimatedTravelTime: 12,
          priority: PriorityLevel.medium,
        ),
        PickupRequest(
          id: 'req_103',
          restaurantName: 'Eco-Bakery & Coffee',
          restaurantPhone: '+1 (555) 015-9982',
          pickupAddress: '55 Sprout St, Arts District',
          latitude: 37.7699,
          longitude: -122.4468,
          foodQuantity: '2 Bags of Pastries & Sandwiches',
          pickupDeadline: DateTime.now().add(const Duration(hours: 3)),
          distance: 4.8,
          estimatedTravelTime: 15,
          priority: PriorityLevel.low,
        ),
      ];
    }
  }

  @override
  Future<Delivery> acceptPickup(String requestId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.acceptPickup.replaceAll('{id}', requestId),
      );
      return Delivery.fromJson(response.data);
    } catch (_) {
      // Mock delivery configuration depending on accepted item
      await Future.delayed(const Duration(milliseconds: 800));
      
      final mockRequests = [
        PickupRequest(
          id: 'req_101',
          restaurantName: 'Green Bite Bistro',
          restaurantPhone: '+1 (555) 019-2834',
          pickupAddress: '842 Leafy Green Blvd, Sector 4',
          latitude: 37.7793,
          longitude: -122.4192,
          foodQuantity: '15 Meals (Salads & Wraps)',
          pickupDeadline: DateTime.now().add(const Duration(minutes: 45)),
          distance: 1.2,
          estimatedTravelTime: 6,
          priority: PriorityLevel.high,
        ),
        PickupRequest(
          id: 'req_102',
          restaurantName: 'The Organic Kitchen',
          restaurantPhone: '+1 (555) 012-7634',
          pickupAddress: '312 Harvest Ave, Downtown',
          latitude: 37.7845,
          longitude: -122.4021,
          foodQuantity: '8 Large Containers (Soup & Rice)',
          pickupDeadline: DateTime.now().add(const Duration(hours: 2)),
          distance: 3.4,
          estimatedTravelTime: 12,
          priority: PriorityLevel.medium,
        ),
        PickupRequest(
          id: 'req_103',
          restaurantName: 'Eco-Bakery & Coffee',
          restaurantPhone: '+1 (555) 015-9982',
          pickupAddress: '55 Sprout St, Arts District',
          latitude: 37.7699,
          longitude: -122.4468,
          foodQuantity: '2 Bags of Pastries & Sandwiches',
          pickupDeadline: DateTime.now().add(const Duration(hours: 3)),
          distance: 4.8,
          estimatedTravelTime: 15,
          priority: PriorityLevel.low,
        ),
      ];

      final selectedReq = mockRequests.firstWhere(
        (r) => r.id == requestId,
        orElse: () => mockRequests[0],
      );

      return Delivery(
        id: 'del_90210',
        pickupRequest: selectedReq,
        charityName: 'Hope Shelter & Food Bank',
        charityPhone: '+1 (555) 014-8844',
        charityAddress: '120 Grace St, Sector 2',
        charityLat: 37.7648,
        charityLng: -122.4215,
        status: DeliveryStatus.accepted,
        estimatedArrivalMinutes: selectedReq.estimatedTravelTime + 8,
        pickupTimerMinutes: 30, // 30 minutes countdown to pick up
        foodHandlingInstructions: 'Keep chilled. Transport in standard insulated catering bags. Avoid stacking bread.',
        emergencyContact: '+1 (555) 911-FREE',
      );
    }
  }

  @override
  Future<void> updateLocation(double lat, double lng) async {
    try {
      await _apiClient.post(
        ApiEndpoints.updateLocation,
        data: {'latitude': lat, 'longitude': lng},
      );
    } catch (_) {
      // Quietly log or ignore for mock flow
    }
  }

  @override
  Future<Delivery> confirmPickup(String deliveryId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.confirmPickup,
        data: {'deliveryId': deliveryId},
      );
      return Delivery.fromJson(response.data);
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 600));
      // Return updated state
      return Delivery(
        id: deliveryId,
        pickupRequest: PickupRequest(
          id: 'req_101',
          restaurantName: 'Green Bite Bistro',
          restaurantPhone: '+1 (555) 019-2834',
          pickupAddress: '842 Leafy Green Blvd, Sector 4',
          latitude: 37.7793,
          longitude: -122.4192,
          foodQuantity: '15 Meals (Salads & Wraps)',
          pickupDeadline: DateTime.now().add(const Duration(minutes: 45)),
          distance: 1.2,
          estimatedTravelTime: 6,
          priority: PriorityLevel.high,
        ),
        charityName: 'Hope Shelter & Food Bank',
        charityPhone: '+1 (555) 014-8844',
        charityAddress: '120 Grace St, Sector 2',
        charityLat: 37.7648,
        charityLng: -122.4215,
        status: DeliveryStatus.pickedUp,
        estimatedArrivalMinutes: 10,
        pickupTimerMinutes: 0,
        foodHandlingInstructions: 'Keep chilled. Transport in standard insulated catering bags. Avoid stacking bread.',
        emergencyContact: '+1 (555) 911-FREE',
      );
    }
  }

  @override
  Future<Delivery> completeDelivery({
    required String deliveryId,
    required String signaturePath,
    required String photoProofPath,
  }) async {
    try {
      // Send fields as multipart form data
      final formData = FormData.fromMap({
        'deliveryId': deliveryId,
        'signature': await MultipartFile.fromFile(signaturePath, filename: 'signature.png'),
        'photoProof': await MultipartFile.fromFile(photoProofPath, filename: 'proof.jpg'),
      });
      final response = await _apiClient.post(
        ApiEndpoints.completeDelivery,
        data: formData,
      );
      return Delivery.fromJson(response.data);
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 1000));
      return Delivery(
        id: deliveryId,
        pickupRequest: PickupRequest(
          id: 'req_101',
          restaurantName: 'Green Bite Bistro',
          restaurantPhone: '+1 (555) 019-2834',
          pickupAddress: '842 Leafy Green Blvd, Sector 4',
          latitude: 37.7793,
          longitude: -122.4192,
          foodQuantity: '15 Meals (Salads & Wraps)',
          pickupDeadline: DateTime.now(),
          distance: 1.2,
          estimatedTravelTime: 6,
          priority: PriorityLevel.high,
        ),
        charityName: 'Hope Shelter & Food Bank',
        charityPhone: '+1 (555) 014-8844',
        charityAddress: '120 Grace St, Sector 2',
        charityLat: 37.7648,
        charityLng: -122.4215,
        status: DeliveryStatus.completed,
        estimatedArrivalMinutes: 0,
        pickupTimerMinutes: 0,
        foodHandlingInstructions: 'Keep chilled.',
        emergencyContact: '+1 (555) 911-FREE',
        signaturePath: signaturePath,
        photoProofPath: photoProofPath,
      );
    }
  }

  @override
  Future<List<HistoryItem>> getDeliveryHistory() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.deliveryHistory);
      final List data = response.data;
      return data.map((json) => HistoryItem.fromJson(json)).toList();
    } catch (_) {
      // Mock history log data
      await Future.delayed(const Duration(milliseconds: 500));
      return [
        HistoryItem(
          id: 'hist_01',
          restaurantName: 'Sprout Garden Cafe',
          charityName: 'Grace Community Center',
          date: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          distance: 4.2,
          foodQuantity: '12 Packages (Hot Meals)',
          status: 'completed',
         ),
        HistoryItem(
          id: 'hist_02',
          restaurantName: 'Taco Sustainable Grill',
          charityName: 'Safe Haven Shelters',
          date: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
          distance: 2.8,
          foodQuantity: '20 Burritos & Sides',
          status: 'completed',
        ),
        HistoryItem(
          id: 'hist_03',
          restaurantName: 'Green Bite Bistro',
          charityName: 'Hope Shelter & Food Bank',
          date: DateTime.now().subtract(const Duration(days: 5)),
          distance: 1.2,
          foodQuantity: '10 Veggie Bowls',
          status: 'completed',
        ),
      ];
    }
  }
}
