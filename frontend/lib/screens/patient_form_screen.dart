import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import '../services/database_helper.dart';

class PatientFormScreen extends StatefulWidget {
  const PatientFormScreen({super.key});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _gender = 'Male';
  
  void _savePatient() async {
    if (_formKey.currentState!.validate()) {
      final db = AppDatabase();
      final newId = const Uuid().v4();
      
      final patient = PatientsCompanion.insert(
        id: newId,
        name: _nameCtrl.text,
        gender: _gender,
        dob: DateTime.now().subtract(const Duration(days: 365 * 20)), // Dummy DOB
        phone: Value(_phoneCtrl.text),
        syncStatus: const Value('pending'),
      );
      
      await db.insertPatient(patient);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Patient")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Full Name"),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            DropdownButtonFormField(
              value: _gender,
              items: ["Male", "Female", "Other"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _gender = v.toString()),
              decoration: const InputDecoration(labelText: "Gender"),
            ),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: "Phone"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _savePatient, child: const Text("Save Patient (Offline Mode)"))
          ],
        ),
      ),
    );
  }
}
