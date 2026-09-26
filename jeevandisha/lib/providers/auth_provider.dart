import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return const StorageService();
});

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.loading = false,
  });

  final AuthStatus status;
  final UserModel? user;
  final String? error;
  final bool loading;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
    bool? loading,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
      loading: loading ?? this.loading,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> bootstrap() async {
    state = state.copyWith(loading: true, clearError: true);
    final user = await AuthService.restoreSession();
    if (user != null) {
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final userMap = await AuthService.login(email, password);
      final user = UserModel.fromJson(userMap);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } catch (e) {
      final err = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(
        loading: false,
        status: AuthStatus.unauthenticated,
        error: err,
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String prn,
    String phone = '',
    String className = '',
    String division = '',
    String department = '',
    String specialization = '',
    String institutionName = '',
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final userMap = await AuthService.register(
        name,
        email,
        password,
        phone: phone,
        prn: prn,
        className: className,
        division: division,
        department: department,
        specialization: specialization,
        institutionName: institutionName,
      );
      final user = UserModel.fromJson(userMap);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } catch (e) {
      final err = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(
        loading: false,
        status: AuthStatus.unauthenticated,
        error: err,
      );
      return false;
    }
  }

  Future<void> refreshUser() async {
    final user = await AuthService.fetchUserProfile();
    if (user != null) {
      state = state.copyWith(user: user, status: AuthStatus.authenticated);
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
