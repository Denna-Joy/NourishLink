import 'package:dio/dio.dart';
import '../../core/constants/constants.dart';
import 'storage_service.dart';

class ApiClient {
  late final Dio dio;
  final StorageService _storageService;

  ApiClient(this._storageService) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.defaultBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Network Request & Error Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          final message = _handleError(error);
          final modifiedError = DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: error.type,
            error: message,
          );
          return handler.next(modifiedError);
        },
      ),
    );
  }

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout with the server. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request send timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again later.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'];
        }
        switch (statusCode) {
          case 400:
            return 'Invalid request details.';
          case 401:
            // Could trigger a logout event if required
            return 'Unauthorized access. Please login again.';
          case 403:
            return 'Access denied. You do not have permissions for this action.';
          case 404:
            return 'Requested content not found on server.';
          case 500:
            return 'Internal server error. Our team has been notified.';
          default:
            return 'Unexpected server error (Status: $statusCode).';
        }
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection detected. Please verify your connection status.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  // Common request helpers
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await dio.delete(path, data: data, queryParameters: queryParameters);
  }
}
