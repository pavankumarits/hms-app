import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../services/database_helper.dart';
import '../../services/sync_service.dart';

class AddVisitScreen extends StatefulWidget {
  final String? inputPatientId; // Optional: Pre-select if coming from list
  const AddVisitScreen({super.key, this.inputPatientId});

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _complaintController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _billingController = TextEditingController(); // No initial text

  // State
  String? _selectedPatientId;
  List<Patient> _patients = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.inputPatientId;
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final db = AppDatabase();
    final list = await db.getAllPatients();
    if (mounted) {
      setState(() {
        _patients = list;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _selectedPatientId != null) {
      setState(() => _isLoading = true);
      try {
        final db = AppDatabase();
        final uuid = const Uuid().v4();

        // 1. Create Visit Object (Local)
        final newVisit = Visit(
          id: uuid,
          patientId: _selectedPatientId!,
          doctorId: '1', // Hardcoded doctor for now
          complaint: _complaintController.text.trim(),
          diagnosis: _diagnosisController.text.trim(),
          treatment: _treatmentController.text.trim(),
          billingAmount: double.tryParse(_billingController.text) ?? 0.0,
          visitDate: DateTime.now(),
          syncStatus: 'pending',
        );

        // 2. Insert into SQLite
        await db.into(db.visits).insert(newVisit);

        // 3. Trigger Sync
        // SyncService().performSync(); 

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Visit Saved Locally'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else if (_selectedPatientId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a Patient'), backgroundColor: Colors.orange),
        );
    }
  }

  InputDecoration _cleanDecoration(String label, IconData icon, {String? hintText}) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)), // Light shadow text effect
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New OPD Visit'), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Visit Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                const SizedBox(height: 20),

                // Patient Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedPatientId,
                  decoration: _cleanDecoration('Select Patient', Icons.person_search),
                  items: _patients.map((p) => DropdownMenuItem<String>(
                    value: p.id,
                    child: Text('${p.name} (${p.patientUiid ?? "New"})', overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (value) => setState(() => _selectedPatientId = value),
                  validator: (val) => val == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Complaint
                TextFormField(
                  controller: _complaintController,
                  decoration: _cleanDecoration('Chief Complaint', Icons.sick),
                  maxLines: 2,
                  validator: (val) => val!.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Diagnosis
                TextFormField(
                  controller: _diagnosisController,
                  decoration: _cleanDecoration('Diagnosis', Icons.local_hospital),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Treatment
                TextFormField(
                  controller: _treatmentController,
                  decoration: _cleanDecoration('Treatment / Rx', Icons.medication),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),

                // Billing
                TextFormField(
                  controller: _billingController,
                  decoration: _cleanDecoration('Consultation Fee', Icons.attach_money, hintText: '0.0'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),

                // Submit
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Visit Record', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
