import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/constants.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Token Operations
  Future<bool> setToken(String token) async {
    return await _prefs.setString(AppConstants.keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(AppConstants.keyToken);
  }

  Future<bool> deleteToken() async {
    return await _prefs.remove(AppConstants.keyToken);
  }

  // User details Operations
  Future<bool> setUser(Map<String, dynamic> userMap) async {
    return await _prefs.setString(AppConstants.keyUser, jsonEncode(userMap));
  }

  Map<String, dynamic>? getUser() {
    final userStr = _prefs.getString(AppConstants.keyUser);
    if (userStr == null) return null;
    try {
      return jsonDecode(userStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteUser() async {
    return await _prefs.remove(AppConstants.keyUser);
  }

  // Driver Status Operations (active / inactive)
  Future<bool> setDriverStatus(String status) async {
    return await _prefs.setString(AppConstants.keyDriverStatus, status);
  }

  String getDriverStatus() {
    return _prefs.getString(AppConstants.keyDriverStatus) ?? 'inactive';
  }

  // Theme settings Mode (light, dark, system)
  Future<bool> setThemeMode(String mode) async {
    return await _prefs.setString(AppConstants.keyThemeMode, mode);
  }

  String getThemeMode() {
    return _prefs.getString(AppConstants.keyThemeMode) ?? 'light';
  }

  // Clear Session details
  Future<void> clearSession() async {
    await deleteToken();
    await deleteUser();
    await _prefs.remove(AppConstants.keyDriverStatus);
  }
}
