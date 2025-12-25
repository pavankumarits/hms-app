import 'package:flutter/material.dart';
import '../services/database_helper.dart';
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
          return ListView.builder(
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
          ],
        ),
      ),
    );
  }
}
