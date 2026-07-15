import 'package:intl/intl.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String volunteerId;
  final double rating;
  final int totalDeliveries;
  final String? profilePhoto;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.volunteerId,
    required this.rating,
    required this.totalDeliveries,
    this.profilePhoto,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      volunteerId: json['volunteerId'] ?? '',
      rating: (json['rating'] ?? 0.0) as double,
      totalDeliveries: json['totalDeliveries'] ?? 0,
      profilePhoto: json['profilePhoto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'volunteerId': volunteerId,
      'rating': rating,
      'totalDeliveries': totalDeliveries,
      'profilePhoto': profilePhoto,
    };
  }
}

enum PriorityLevel { low, medium, high }

class PickupRequest {
  final String id;
  final String restaurantName;
  final String restaurantPhone;
  final String pickupAddress;
  final double latitude;
  final double longitude;
  final String foodQuantity;
  final DateTime pickupDeadline;
  final double distance; // in km
  final int estimatedTravelTime; // in minutes
  final PriorityLevel priority;

  PickupRequest({
    required this.id,
    required this.restaurantName,
    required this.restaurantPhone,
    required this.pickupAddress,
    required this.latitude,
    required this.longitude,
    required this.foodQuantity,
    required this.pickupDeadline,
    required this.distance,
    required this.estimatedTravelTime,
    required this.priority,
  });

  factory PickupRequest.fromJson(Map<String, dynamic> json) {
    return PickupRequest(
      id: json['id'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
      restaurantPhone: json['restaurantPhone'] ?? '',
      pickupAddress: json['pickupAddress'] ?? '',
      latitude: (json['latitude'] ?? 0.0) as double,
      longitude: (json['longitude'] ?? 0.0) as double,
      foodQuantity: json['foodQuantity'] ?? '',
      pickupDeadline: DateTime.parse(json['pickupDeadline'] ?? DateTime.now().toIso8601String()),
      distance: (json['distance'] ?? 0.0) as double,
      estimatedTravelTime: json['estimatedTravelTime'] ?? 0,
      priority: _parsePriority(json['priority'] ?? 'medium'),
    );
  }

  static PriorityLevel _parsePriority(String value) {
    switch (value.toLowerCase()) {
      case 'high':
        return PriorityLevel.high;
      case 'low':
        return PriorityLevel.low;
      default:
        return PriorityLevel.medium;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantName': restaurantName,
      'restaurantPhone': restaurantPhone,
      'pickupAddress': pickupAddress,
      'latitude': latitude,
      'longitude': longitude,
      'foodQuantity': foodQuantity,
      'pickupDeadline': pickupDeadline.toIso8601String(),
      'distance': distance,
      'estimatedTravelTime': estimatedTravelTime,
      'priority': priority.name,
    };
  }
}

enum DeliveryStatus { accepted, pickedUp, completed, cancelled }

class Delivery {
  final String id;
  final PickupRequest pickupRequest;
  final String charityName;
  final String charityPhone;
  final String charityAddress;
  final double charityLat;
  final double charityLng;
  final DeliveryStatus status;
  final int estimatedArrivalMinutes;
  final int pickupTimerMinutes; // active countdown
  final String foodHandlingInstructions;
  final String emergencyContact;
  final String? signaturePath;
  final String? photoProofPath;

  Delivery({
    required this.id,
    required this.pickupRequest,
    required this.charityName,
    required this.charityPhone,
    required this.charityAddress,
    required this.charityLat,
    required this.charityLng,
    required this.status,
    required this.estimatedArrivalMinutes,
    required this.pickupTimerMinutes,
    required this.foodHandlingInstructions,
    required this.emergencyContact,
    this.signaturePath,
    this.photoProofPath,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] ?? '',
      pickupRequest: PickupRequest.fromJson(json['pickupRequest']),
      charityName: json['charityName'] ?? '',
      charityPhone: json['charityPhone'] ?? '',
      charityAddress: json['charityAddress'] ?? '',
      charityLat: (json['charityLat'] ?? 0.0) as double,
      charityLng: (json['charityLng'] ?? 0.0) as double,
      status: _parseStatus(json['status'] ?? 'accepted'),
      estimatedArrivalMinutes: json['estimatedArrivalMinutes'] ?? 0,
      pickupTimerMinutes: json['pickupTimerMinutes'] ?? 0,
      foodHandlingInstructions: json['foodHandlingInstructions'] ?? '',
      emergencyContact: json['emergencyContact'] ?? '',
      signaturePath: json['signaturePath'],
      photoProofPath: json['photoProofPath'],
    );
  }

  static DeliveryStatus _parseStatus(String value) {
    switch (value.toLowerCase()) {
      case 'pickedup':
        return DeliveryStatus.pickedUp;
      case 'completed':
        return DeliveryStatus.completed;
      case 'cancelled':
        return DeliveryStatus.cancelled;
      default:
        return DeliveryStatus.accepted;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pickupRequest': pickupRequest.toJson(),
      'charityName': charityName,
      'charityPhone': charityPhone,
      'charityAddress': charityAddress,
      'charityLat': charityLat,
      'charityLng': charityLng,
      'status': status.name,
      'estimatedArrivalMinutes': estimatedArrivalMinutes,
      'pickupTimerMinutes': pickupTimerMinutes,
      'foodHandlingInstructions': foodHandlingInstructions,
      'emergencyContact': emergencyContact,
      'signaturePath': signaturePath,
      'photoProofPath': photoProofPath,
    };
  }

  Delivery copyWith({
    DeliveryStatus? status,
    int? estimatedArrivalMinutes,
    int? pickupTimerMinutes,
    String? signaturePath,
    String? photoProofPath,
  }) {
    return Delivery(
      id: id,
      pickupRequest: pickupRequest,
      charityName: charityName,
      charityPhone: charityPhone,
      charityAddress: charityAddress,
      charityLat: charityLat,
      charityLng: charityLng,
      status: status ?? this.status,
      estimatedArrivalMinutes: estimatedArrivalMinutes ?? this.estimatedArrivalMinutes,
      pickupTimerMinutes: pickupTimerMinutes ?? this.pickupTimerMinutes,
      foodHandlingInstructions: foodHandlingInstructions,
      emergencyContact: emergencyContact,
      signaturePath: signaturePath ?? this.signaturePath,
      photoProofPath: photoProofPath ?? this.photoProofPath,
    );
  }
}

class HistoryItem {
  final String id;
  final String restaurantName;
  final String charityName;
  final DateTime date;
  final double distance;
  final String foodQuantity;
  final String status;

  HistoryItem({
    required this.id,
    required this.restaurantName,
    required this.charityName,
    required this.date,
    required this.distance,
    required this.foodQuantity,
    required this.status,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
      charityName: json['charityName'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      distance: (json['distance'] ?? 0.0) as double,
      foodQuantity: json['foodQuantity'] ?? '',
      status: json['status'] ?? 'completed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantName': restaurantName,
      'charityName': charityName,
      'date': date.toIso8601String(),
      'distance': distance,
      'foodQuantity': foodQuantity,
      'status': status,
    };
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }
}
