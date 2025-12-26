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
    bool pullSuccess = true;
    
    // --- PULL PHASE ---
    try {
      if (kDebugMode) debugPrint("Pulling data from server...");
      
      // 1. Fetch Remote Data
      final remotePatients = await _apiService.fetchPatients();
      final remoteVisits = await _apiService.fetchVisits();
      
      // 2. Process Patients
      if (remotePatients.isNotEmpty) {
        final List<Patient> patientsToInsert = remotePatients.map((json) {
           return Patient(
             id: json['id'],
             patientUiid: json['patient_uiid'],
             name: json['name'],
             gender: json['gender'],
             dob: DateTime.parse(json['dob']),
             phone: json['phone'],
             address: json['address'],
             createdAt: DateTime.parse(json['created_at']),
             updatedAt: DateTime.parse(json['updated_at']),
             syncStatus: 'synced', // Coming from server, so it's synced
           );
        }).toList();
        await _db.batchInsertPatients(patientsToInsert);
      }

      // 3. Process Visits
      if (remoteVisits.isNotEmpty) {
        final List<Visit> visitsToInsert = remoteVisits.map((json) {
           return Visit(
             id: json['id'],
             patientId: json['patient_id'],
             doctorId: json['doctor_id'],
             complaint: json['complaint'],
             diagnosis: json['diagnosis'],
             treatment: json['treatment'],
             billingAmount: (json['billing_amount'] as num).toDouble(),
             visitDate: DateTime.parse(json['visit_date']),
             syncStatus: 'synced',
           );
        }).toList();
        await _db.batchInsertVisits(visitsToInsert);
      }
      
      if (kDebugMode) debugPrint("Pull Completed. Patients: ${remotePatients.length}, Visits: ${remoteVisits.length}");
      
    } catch (e) {
      pullSuccess = false;
      if (kDebugMode) debugPrint("Pull Failed: $e");
      // Decide: Stop or Continue? Let's continue to Push phase to ensure data safety.
    }

    // --- PUSH PHASE ---
    
    // 1. Fetch pending records
    final pendingPatients = await _db.getPendingPatients();
    final pendingVisits = (await _db.select(_db.visits).get()).where((v) => v.syncStatus == 'pending').toList();
    // Add bills later if needed
    
    if (pendingPatients.isEmpty && pendingVisits.isEmpty) {
      return pullSuccess; // Return status of pull if nothing to push
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
      
      if (kDebugMode) debugPrint("Push Completed!");
      return true; // Push success
      
    } catch (e) {
      debugPrint("Push Failed: $e");
      return false; // Sync failed
    }
  }
}
