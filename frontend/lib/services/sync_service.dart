import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'api_service.dart';
import 'database_helper.dart';

class SyncService {
  final ApiService _apiService;
  final AppDatabase _db;
  
  SyncService(this._apiService, this._db);
  
  Future<void> init() async {
    // Monitor connectivity
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        performSync();
      }
    });
  }
  
  Future<void> performSync() async {
    if (kDebugMode) print("Starting Sync...");
    
    // 1. Fetch pending records
    final pendingPatients = await _db.getPendingPatients();
    // Fetch visits, bills etc.
    
    if (pendingPatients.isEmpty) return;
    
    try {
      // 2. Construct Payload
      final payload = {
        'patients': pendingPatients.map((p) => {
          'id': p.id,
          'patient_uiid': p.patientUiid,
          'name': p.name,
          'gender': p.gender,
          'dob': p.dob.toIso8601String(),
          'phone': p.phone,
          'address': p.address,
          'created_at': p.createdAt.toIso8601String(),
          'updated_at': p.updatedAt.toIso8601String(),
        }).toList(),
        'visits': (await _db.select(_db.visits).get()).where((v) => v.syncStatus == 'pending').map((v) => {
          'id': v.id,
          'patient_id': v.patientId,
          'doctor_id': v.doctorId,
          'complaint': v.complaint,
          'diagnosis': v.diagnosis,
          'treatment': v.treatment,
          'billing_amount': v.billingAmount,
          'visit_date': v.visitDate.toIso8601String(),
        }).toList(),
        'bills': (await _db.select(_db.bills).get()).where((b) => b.syncStatus == 'pending').map((b) => {
          'id': b.id,
          'visit_id': b.visitId,
          'amount': b.amount,
          'status': b.status,
          'payment_method': b.paymentMethod,
        }).toList()
      };
      
      // 3. Send to Backend
      await _apiService.syncData(payload);
      
      // 4. Mark as Synced
      for (var p in pendingPatients) {
        await _db.markPatientSynced(p.id);
      }
      
      if (kDebugMode) print("Sync Completed!");
      
    } catch (e) {
      print("Sync Failed: $e");
    }
  }
}
