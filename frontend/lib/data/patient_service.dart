import 'package:dio/dio.dart';
import '../data/api_client.dart';

class PatientService {
  final Dio _dio = ApiClient().dio;

  Future<List<dynamic>> getPatients() async {
    try {
      final response = await _dio.get('/patients/');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load patients: $e');
    }
  }

  Future<dynamic> createPatient(Map<String, dynamic> patientData) async {
    try {
      final response = await _dio.post('/patients/', data: patientData);
      return response.data;
    } catch (e) {
      throw Exception('Failed to create patient: $e');
    }
  }
}
