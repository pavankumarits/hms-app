import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../core/config.dart';

class ApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late Dio _dio;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      // Default to Config, but will be overwritten by interceptor or init
      baseUrl: AppConfig.apiBaseUrl, 
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 1. Dynamic URL Overwrite
        final savedUrl = await _storage.read(key: 'api_base_url');
        if (savedUrl != null && savedUrl.isNotEmpty) {
           options.baseUrl = savedUrl;
        }

        // Ensure /api/v1 suffix
        if (!options.baseUrl.endsWith('/api/v1')) {
           // Handle potential trailing slash in root domain
           if (options.baseUrl.endsWith('/')) {
              options.baseUrl = '${options.baseUrl}api/v1';
           } else {
              options.baseUrl = '${options.baseUrl}/api/v1';
           }
        }

        // 2. Auth Token & Hospital ID
        final token = await _storage.read(key: 'auth_token');
        final hospitalId = await _storage.read(key: 'hospital_id');
        
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token'; 
        }
        if (hospitalId != null) {
          options.headers['X-Hospital-ID'] = hospitalId;
        }
        
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (kDebugMode) {
          print("API Error: ${e.message}");
          print("Error Type: ${e.type}");
          if (e.response != null) {
            print("Error Response: ${e.response?.data}");
          }
        }
        return handler.next(e);
      }
    ));
  }
  
  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post('/login/access-token', data: {
        'username': username,
        'password': password,
      }, options: Options(contentType: Headers.formUrlEncodedContentType));
      
      final data = response.data;
      await _storage.write(key: 'access_token', value: data['access_token']);
      return data;
    } catch (e) {
      rethrow;
    }
  }
  
  // Bulk Sync
  Future<void> syncData(Map<String, dynamic> payload) async {
    try {
      await _dio.post('/sync/sync', data: payload);
    } catch (e) {
      rethrow;
    }
  }

  // Analytics
  Future<Map<String, dynamic>> fetchGraphData() async {
    try {
      final response = await _dio.get('/analytics/graph-data?period=week');
      return response.data;
    } catch (e) {
      if (kDebugMode) print("Graph Fetch Error: $e");
      return {'labels': [], 'values': []};
    }
  }

  Dio get client => _dio;
}
