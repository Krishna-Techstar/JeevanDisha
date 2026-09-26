import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import 'api_service.dart';

class AuthResult {
  const AuthResult({required this.token, required this.user});

  final String token;
  final UserModel user;
}

class AuthService {
  static const String tokenKey = 'jwt_token';
  static const String userKey = 'user_json';

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await ApiService.post('/auth/login', {
      'email': email.trim().toLowerCase(),
      'password': password,
    });

    final data = response is Map<String, dynamic>
        ? response
        : Map<String, dynamic>.from(response as Map);

    final token = (data['token'] ?? '').toString();
    if (token.isEmpty) {
      throw Exception('Authentication token missing in server response.');
    }

    final user = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : Map<String, dynamic>.from(data['user'] as Map);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setString(userKey, jsonEncode(user));
    ApiService.setToken(token);

    return user;
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password, {
    String phone = '',
    String prn = '',
    String className = '',
    String division = '',
    String department = '',
    String specialization = '',
    String institutionName = '',
  }) async {
    final payload = {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      if (phone.isNotEmpty) 'phone': phone.trim(),
      if (prn.isNotEmpty) 'prn': prn.trim().toUpperCase(),
      if (className.isNotEmpty) 'className': className.trim(),
      if (division.isNotEmpty) 'division': division.trim(),
      if (department.isNotEmpty) 'department': department.trim(),
      if (specialization.isNotEmpty) 'specialization': specialization.trim(),
      if (institutionName.isNotEmpty) 'institutionName': institutionName.trim(),
    };

    final response = await ApiService.post('/auth/register', payload);

    final data = response is Map<String, dynamic>
        ? response
        : Map<String, dynamic>.from(response as Map);

    final token = (data['token'] ?? '').toString();
    if (token.isEmpty) {
      throw Exception('Registration succeeded but token was not returned.');
    }

    final user = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : Map<String, dynamic>.from(data['user'] as Map);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setString(userKey, jsonEncode(user));
    ApiService.setToken(token);

    return user;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
    ApiService.clearToken();
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      ApiService.setToken(token);
      return true;
    }
    return false;
  }

  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(userKey);
    if (userJson == null || userJson.isEmpty) return null;

    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<UserModel?> fetchUserProfile() async {
    try {
      final res = await ApiService.get('/auth/me');
      if (res is Map && res['user'] != null) {
        final userMap = res['user'] is Map<String, dynamic>
            ? res['user'] as Map<String, dynamic>
            : Map<String, dynamic>.from(res['user'] as Map);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(userKey, jsonEncode(userMap));
        return UserModel.fromJson(userMap);
      }
    } catch (_) {
      // Fallback to cached user
    }
    return getCurrentUser();
  }

  static Future<UserModel?> restoreSession() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return null;

    ApiService.setToken(token);
    return getCurrentUser();
  }
}
