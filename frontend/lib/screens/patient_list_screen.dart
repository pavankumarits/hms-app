import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'patient_form_screen.dart';
import 'visit_form_screen.dart';

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
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientFormScreen()));
          setState(() {}); // Refresh list
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
            itemBuilder: (context, index) {
              final p = patients[index];
              return ListTile(
                leading: CircleAvatar(child: Text(p.name[0])),
                title: Text(p.name),
                subtitle: Text("ID: ${p.patientUiid ?? 'Pending'} | Status: ${p.syncStatus}"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                   showModalBottomSheet(
                     context: context,
                     builder: (context) => Container(
                       padding: const EdgeInsets.all(16),
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           ListTile(
                             leading: const Icon(Icons.medical_services),
                             title: const Text("New Visit"),
                             onTap: () {
                               Navigator.pop(context);
                               Navigator.push(context, MaterialPageRoute(builder: (_) => VisitFormScreen(patientId: p.id)));
                             },
                           ),
                         ],
                       ),
                     ),
                   );
                },
              );
            },
          );
        },
      ),
    );
  }
}
