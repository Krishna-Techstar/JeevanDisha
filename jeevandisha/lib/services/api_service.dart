import 'package:dio/dio.dart';

import '../core/constants.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBase,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearToken() {
    dio.options.headers.remove('Authorization');
  }

  static String _extractErrorMessage(DioException e) {
    // Print debug log for developers
    // ignore: avoid_print
    print('[ApiService Error] Type: ${e.type}, Status: ${e.response?.statusCode}, Error: ${e.error}, Data: ${e.response?.data}');

    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      } else if (data is String && data.trim().isNotEmpty) {
        return data.trim();
      }

      if (statusCode == 400) {
        return 'Invalid email or password.';
      } else if (statusCode == 401) {
        return 'Session expired. Please login again.';
      } else if (statusCode == 403) {
        return 'Access denied.';
      } else if (statusCode == 404) {
        return 'Requested service not found.';
      } else if (statusCode == 500) {
        return 'Server error. Please try again.';
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond.';
      case DioExceptionType.connectionError:
        return 'Unable to connect to the server.';
      case DioExceptionType.badCertificate:
        return 'Security certificate error.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'Unable to connect to the server.';
    }
  }

  static Future<dynamic> get(String path) async {
    try {
      final response = await dio.get(path);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> post(
    String path, [
    Map<dynamic, dynamic>? data,
  ]) async {
    try {
      final response = await dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> patch(
    String path, [
    Map<dynamic, dynamic>? data,
  ]) async {
    try {
      final response = await dio.patch(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> put(
    String path, [
    Map<dynamic, dynamic>? data,
  ]) async {
    try {
      final response = await dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> delete(String path) async {
    try {
      final response = await dio.delete(path);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
