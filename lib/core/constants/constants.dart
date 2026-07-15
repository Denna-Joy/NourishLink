class AppConstants {
  // API Configurations
  static const String defaultBaseUrl = 'https://nourishlink-api.demo.com/api/v1';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Storage Keys
  static const String keyToken = 'auth_token';
  static const String keyUser = 'user_data';
  static const String keyDriverStatus = 'driver_status'; // active, inactive
  static const String keyThemeMode = 'theme_mode';

  // Map configuration default center
  static const double defaultLat = 37.7749; // Default San Francisco coordinates
  static const double defaultLng = -122.4194;

  // Visual Styling Constants
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 24.0;
  
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
}

class ApiEndpoints {
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String profile = '/driver/profile';
  static const String status = '/driver/status';
  static const String stats = '/driver/stats';
  static const String pickupRequests = '/pickups/available';
  static const String acceptPickup = '/pickups/{id}/accept';
  static const String activeDelivery = '/deliveries/active';
  static const String updateLocation = '/deliveries/location';
  static const String confirmPickup = '/deliveries/confirm-pickup';
  static const String completeDelivery = '/deliveries/complete';
  static const String deliveryHistory = '/deliveries/history';
}
