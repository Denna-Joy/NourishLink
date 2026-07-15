import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/api_client.dart';
import '../core/services/storage_service.dart';
import '../repositories/auth_repository.dart';
import '../models/models.dart';

// Dependency Injection Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiClient(storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final storage = ref.watch(storageServiceProvider);
  return AuthRepositoryImpl(client, storage);
});

// Authentication State
class AuthState {
  final bool isLoading;
  final User? user;
  final String? errorMessage;

  AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage, // We reset the error if we don't pass it
    );
  }
}

// State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    state = state.copyWith(isLoading: true);
    final user = await _repository.getCurrentUser();
    state = AuthState(isLoading: false, user: user);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.login(email, password);
      state = AuthState(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = AuthState(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _repository.logout();
    state = AuthState(isLoading: false, user: null);
  }

  Future<bool> sendForgotPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.forgotPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }
}

// Expose Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
