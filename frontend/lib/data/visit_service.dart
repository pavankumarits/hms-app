import 'package:dio/dio.dart';
import '../data/api_client.dart';

class VisitService {
  final Dio _dio = ApiClient().dio;

  Future<List<dynamic>> getVisits() async {
    try {
      final response = await _dio.get('/visits/');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load visits: $e');
    }
  }

  Future<dynamic> createVisit(Map<String, dynamic> visitData) async {
    try {
      final response = await _dio.post('/visits/', data: visitData);
      return response.data;
    } catch (e) {
      throw Exception('Failed to create visit: $e');
    }
  }
}
