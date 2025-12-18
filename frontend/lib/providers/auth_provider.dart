import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();
  late final Dio _dio = _apiService.client;

  bool _isAuthenticated = false;
  String? _role;
  String? _username;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get role => _role;
  bool get isLoading => _isLoading;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Login to get token
      final response = await _dio.post('/login/access-token', data: {
        'username': username,
        'password': password,
      }, options: Options(contentType: Headers.formUrlEncodedContentType));

      final token = response.data['access_token'];
      await _storage.write(key: 'access_token', value: token);

      // 2. Fetch User Details (Role)
      // We need to implement /users/me in backend
      final userResponse = await _dio.get('/users/me'); 
      _role = userResponse.data['role'];
      _username = userResponse.data['username'];
      _isAuthenticated = true;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Login Error: $e');
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    _isAuthenticated = false;
    _role = null;
    notifyListeners();
  }
}
