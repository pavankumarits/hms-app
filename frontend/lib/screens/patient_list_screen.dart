import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';
import '../services/api_service.dart';
import '../services/smart_doctor_service.dart';
import 'patients/add_patient_screen.dart'; // Correct path
import 'visits/add_visit_screen.dart';
import 'patients/patient_history_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final AppDatabase _db = AppDatabase();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patients")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person_add),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPatientScreen()));
          setState(() {}); // Refresh list after adding
        },
      ),
      body: FutureBuilder<List<Patient>>(
        future: _db.getAllPatients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No patients found. Add one!"));
          }
          
          final patients = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              await SyncService(ApiService(), AppDatabase()).performSync(); // Trigger Sync
              setState(() {}); // Reload UI
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(), // Required for RefreshIndicator if list is small
              itemCount: patients.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final p = patients[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(p.name[0].toUpperCase(), style: TextStyle(color: Colors.blue.shade800)),
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${p.patientUiid ?? 'Pending'} | ${p.phone ?? 'No Phone'}"),
                    trailing: const Icon(Icons.more_vert),
                    onTap: () {
                       _showPatientActions(context, p);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showPatientActions(BuildContext context, Patient p) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // 1. View History Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.history),
                label: const Text("View Visit History"),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                onPressed: () {
                  Navigator.pop(context); // Close sheet
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PatientHistoryScreen(patient: p)));
                },
              ),
            ),
            const SizedBox(height: 12),
            
            // 2. New Visit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                 icon: const Icon(Icons.medical_services_outlined, color: Colors.white),
                 label: const Text("New Visit (Revisit)", style: TextStyle(color: Colors.white)),
                 style: ElevatedButton.styleFrom(
                   padding: const EdgeInsets.all(16),
                   backgroundColor: Theme.of(context).primaryColor,
                 ),
                 onPressed: () {
                   Navigator.pop(context);
                   Navigator.push(context, MaterialPageRoute(builder: (_) => AddVisitScreen(inputPatientId: p.id)));
                 },
              ),
            ),
            const SizedBox(height: 12),

            // 3. AI Risk Analysis (New)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.analytics_outlined, color: Colors.purple),
                label: const Text("Run AI Risk Analysis"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple,
                  side: const BorderSide(color: Colors.purple),
                  padding: const EdgeInsets.all(16)
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _runRiskAnalysis(context, p);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _runRiskAnalysis(BuildContext context, Patient p) async {
    // Show Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Calculate Age
    final age = DateTime.now().year - p.dob.year;
    
    // Call AI Service
    // Note: Using default vitals for static demographic check. 
    // In a real scenario, we would fetch the latest visit's vitals.
    final result = await SmartDoctorService().predictPatientRisk(
      age: age,
      gender: p.gender,
      vitals: {"systolic_bp": 120, "heart_rate": 72}, 
      comorbidities: [], 
    );

    Navigator.pop(context); // Close loading

    if (result != null) {
      if (mounted) _showRiskResult(context, result);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("AI Analysis Failed. Check Backend.")));
    }
  }

  void _showRiskResult(BuildContext context, Map<String, dynamic> result) {
    final color = result['risk_level'] == 'High' ? Colors.red : (result['risk_level'] == 'Medium' ? Colors.orange : Colors.green);
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🤖 AI Risk Prediction"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 30,
              child: Icon(Icons.health_and_safety, color: color, size: 30),
            ),
            const SizedBox(height: 16),
            Text("Risk Level: ${result['risk_level']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            Text("Score: ${(result['risk_score'] * 100).toStringAsFixed(1)}%"),
            const SizedBox(height: 8),
            Text(result['recommendation'] ?? "", textAlign: TextAlign.center),
            if (result['risk_factors'] != null) ...[
               const Divider(),
               const Align(alignment: Alignment.centerLeft, child: Text("Risk Factors:", style: TextStyle(fontWeight: FontWeight.bold))),
               ...(result['risk_factors'] as List).map((e) => Align(alignment: Alignment.centerLeft, child: Text("• $e"))).toList(),
            ]
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }
}
