import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart'; // Required for Value and Companions
import 'api_service.dart';
import 'database_helper.dart';

class SyncService {
  final ApiService _apiService;
  final AppDatabase _db;
  
  SyncService(this._apiService, this._db);
  
  Future<void> init() async {
    // Monitor connectivity
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (!results.contains(ConnectivityResult.none)) {
        performSync();
      }
    });
  }
  
  Future<bool> performSync() async {
    if (kDebugMode) debugPrint("Starting Sync...");
    
    // 1. Fetch pending records
    final pendingPatients = await _db.getPendingPatients();
    final pendingVisits = (await _db.select(_db.visits).get()).where((v) => v.syncStatus == 'pending').toList();
    // Add bills later if needed
    
    if (pendingPatients.isEmpty && pendingVisits.isEmpty) {
      return false; // Nothing to sync
    }
    
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
        'visits': pendingVisits.map((v) => {
          'id': v.id,
          'patient_id': v.patientId,
          'doctor_id': v.doctorId,
          'complaint': v.complaint,
          'diagnosis': v.diagnosis,
          'treatment': v.treatment,
          'billing_amount': v.billingAmount,
          'visit_date': v.visitDate.toIso8601String(),
        }).toList(),
        'bills': [], // Add bills logic if table exists and populated
        'audit_logs': []
      };
      
      // 3. Send to Backend
      await _apiService.syncData(payload);
      
      // 4. Mark as Synced
      for (var p in pendingPatients) {
        await _db.markPatientSynced(p.id);
      }
      for (var v in pendingVisits) {
        // Need a similar method for visits or generic update
        await (_db.update(_db.visits)..where((t) => t.id.equals(v.id))).write(const VisitsCompanion(syncStatus: Value('synced')));
      }
      
      if (kDebugMode) debugPrint("Sync Completed!");
      return true; // Sync success
      
    } catch (e) {
      debugPrint("Sync Failed: $e");
      return false; // Sync failed
    }
  }
}
