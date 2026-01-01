import 'package:dio/dio.dart';
import '../services/api_service.dart';

class SmartDoctorService {
  final ApiService _apiService = ApiService();

  Future<List<Map<String, dynamic>>> predictDrugs({
    required String diagnosis,
    required int age,
    String? gender,
  }) async {
    try {
      final response = await _apiService.client.post(
        '/smart-doctor/predict-drugs',
        data: {
          "diagnosis": diagnosis,
          "age": age,
          "gender": gender,
        },
      );
      
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      print("Smart Doctor Prediction Error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> predictDiagnosis(String symptoms) async {
    try {
      final response = await _apiService.client.post(
        '/ml/predict-diagnosis-nlp',
        data: {"symptoms": symptoms},
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      print("Diagnosis Prediction Error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> checkSafety({
    required String proposedDrug,
    required List<String> currentMeds,
  }) async {
    try {
      final response = await _apiService.client.post(
        '/smart-doctor/check-safety',
        data: {
          "proposed_drug": proposedDrug,
          "current_meds": currentMeds,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return {"is_safe": true, "warnings": []};
    } catch (e) {
      print("Smart Doctor Safety Check Error: $e");
      return {"is_safe": true, "warnings": []};
    }
  }

  Future<List<Map<String, dynamic>>> getLabRecommendations(String diagnosis) async {
    try {
      final response = await _apiService.client.post(
        '/labs/recommend',
        data: {"diagnosis": diagnosis},
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      print("Lab Recommendation Error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> calculateDosage({
    required String drugName,
    required double weight,
    required double age,
  }) async {
    try {
      final response = await _apiService.client.post(
        '/dosage/calculate',
        data: {
          "drug_name": drugName,
          "weight_kg": weight,
          "age_years": age,
          "form": "Syrup" // Default for pediatric
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print("Dosage Calculator Error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> assessRisk({
    required int age,
    required String gender,
    required int systolicBp,
    required int diastolicBp,
    required List<String> conditions,
    required List<String> lifestyle,
  }) async {
    try {
      // Mapping old arguments to new ML payload structure
      final response = await _apiService.client.post(
        '/ml/predict-risk',
        data: {
          "age": age,
          "gender": gender,
          "vitals": {
            "systolic_bp": systolicBp, 
            "diastolic_bp": diastolicBp,
            "heart_rate": 72, 
            "resp_rate": 16,
            "spo2": 98,
            "temp": 37.0
          },
          "comorbidities": conditions + lifestyle,
          "lab_results": {}
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          "total_score": (data['risk_score'] * 10).round(),
          "risk_level": data['risk_level'],
          "contributors": (data['risk_factors'] as List).map((f) => {"factor": f}).toList(),
          "recommendation": data['recommendation']
        };
      }
      return null;
    } catch (e) {
      print("Risk Assessment Error: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> checkAlerts({
    required int age,
    required String gender,
    required List<String> conditions,
  }) async {
    try {
      final response = await _apiService.client.post(
        '/alerts/check',
        data: {
          "age": age,
          "gender": gender,
          "conditions": conditions,
        },
      );

      if (response.statusCode == 200 && response.data['alerts'] != null) {
        return List<Map<String, dynamic>>.from(response.data['alerts']);
      }
      return [];
    } catch (e) {
      print("Clinical Alerts Error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> checkAdverseReactions({
    required List<String> symptoms,
    required List<String> currentMeds,
  }) async {
    try {
      final response = await _apiService.client.post(
        '/adverse-events/check',
        data: {
          "symptoms": symptoms,
          "current_meds": currentMeds,
        },
      );

      if (response.statusCode == 200 && response.data['matches'] != null) {
        return List<Map<String, dynamic>>.from(response.data['matches']);
      }
      return [];
    } catch (e) {
      print("Adverse Events Check Error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> auditPrescription({
    required String newDrug,
    required List<String> currentMeds,
  }) async {
    try {
      final response = await _apiService.client.post(
        '/prescription/audit',
        data: {
          "new_drug": newDrug,
          "current_meds": currentMeds,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return {"is_safe": true, "interactions": []};
    } catch (e) {
      print("Prescription Audit Error: $e");
      return {"is_safe": true, "interactions": []};
    }
  }

  Future<Map<String, dynamic>> predictReadmission({
    required int age,
    required int visitsLast30Days,
    required int chronicConditionCount,
    required int daysSinceDischarge,
  }) async {
    try {
      final response = await _apiService.client.post(
        '/analytics/predict-readmission',
        data: {
          "age": age,
          "visits_last_30_days": visitsLast30Days,
          "chronic_condition_count": chronicConditionCount,
          "days_since_discharge": daysSinceDischarge,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return {"risk_level": "Unknown", "risk_score": 0.0};
    } catch (e) {
      print("Readmission Prediction Error: $e");
      return {"risk_level": "Unknown", "risk_score": 0.0};
    }
  }
  Future<Map<String, dynamic>?> predictPatientRisk({
    required int age,
    required String gender,
    required Map<String, dynamic> vitals,
    List<String> comorbidities = const [],
    Map<String, dynamic>? labs,
  }) async {
    try {
      final response = await _apiService.client.post(
        '/ml/predict-risk',
        data: {
          "age": age,
          "gender": gender,
          "vitals": vitals,
          "comorbidities": comorbidities,
          "lab_results": labs,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print("ML Risk Prediction Error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> predictTriage({
    required String symptoms,
    required Map<String, dynamic> vitals,
    int painScore = 0,
    String consciousness = 'Alert',
  }) async {
    try {
      final response = await _apiService.client.post(
        '/ml/predict-triage',
        data: {
          "symptoms": symptoms,
          "vitals": vitals,
          "pain_score": painScore,
          "consciousness": consciousness,
        },
      );
      
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print("ML Triage Error: $e");
      return null;
    }
  }
}
