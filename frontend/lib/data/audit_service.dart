import 'package:dio/dio.dart';
import '../data/api_client.dart';

class AuditService {
  final Dio _dio = ApiClient().dio;

  Future<List<dynamic>> getAuditLogs() async {
    try {
      final response = await _dio.get('/audit-logs/');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load audit logs: $e');
    }
  }
}
