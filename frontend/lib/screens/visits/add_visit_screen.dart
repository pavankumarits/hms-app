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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414), // Dark Matte Background
      appBar: AppBar(
        title: const Text('New OPD Visit', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section Header
                const Text(
                  "Visit Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4DB6AC), // Muted Teal
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: Color(0xFF2E2E2E), thickness: 1), // Thin divider
                const SizedBox(height: 20),

                // Patient Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedPatientId,
                  isExpanded: true, // Fix overflow error
                  dropdownColor: const Color(0xFF1E1E1E), 
                  decoration: _cleanDecoration('Select Patient', Icons.person_search),
                  style: const TextStyle(color: Color(0xFFEAEAEA)),
                  items: _patients.map((p) => DropdownMenuItem<String>(
                    value: p.id,
                    child: Text('${p.name} (${p.patientUiid ?? "New"})', 
                      style: const TextStyle(color: Color(0xFFEAEAEA)),
                      overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (value) => setState(() => _selectedPatientId = value),
                  validator: (val) => val == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Complaint
                TextFormField(
                  controller: _complaintController,
                  decoration: _cleanDecoration('Chief Complaint', Icons.sick),
                  style: const TextStyle(color: Color(0xFFEAEAEA)),
                  maxLines: 1, 
                  validator: (val) => val!.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Diagnosis
                TextFormField(
                  controller: _diagnosisController,
                  decoration: _cleanDecoration('Diagnosis', Icons.local_hospital),
                  style: const TextStyle(color: Color(0xFFEAEAEA)),
                  maxLines: 1,
                ),
                const SizedBox(height: 16),

                // Treatment / Rx (Fixed Height Box)
                SizedBox(
                  height: 140, // Keep this big as requested
                  child: TextFormField(
                    controller: _treatmentController,
                    decoration: _cleanDecoration('Treatment / Rx', Icons.medication),
                    style: const TextStyle(color: Color(0xFFEAEAEA)),
                    maxLines: null, 
                    expands: true, 
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
                const SizedBox(height: 16),

                // Consultation Fee (Back to Normal Size)
                TextFormField(
                  controller: _billingController,
                  decoration: _cleanDecoration('Consultation Fee', Icons.currency_rupee, hintText: '0.00'),
                  style: const TextStyle(color: Color(0xFFEAEAEA)),
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  height: 56, // Large button
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      backgroundColor: const Color(0xFF00897B), // Teal
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: Colors.black45,
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('Save Visit Record', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _cleanDecoration(String label, IconData icon, {String? hintText}) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      labelStyle: const TextStyle(color: Color(0xFF9E9E9E)), // Muted Grey
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      prefixIcon: Icon(icon, size: 22, color: const Color(0xFF4DB6AC)), // Muted Teal Icon
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2E2E2E)), // Soft Grey
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2E2E2E)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF26A69A), width: 1.5), // Thin Teal highlight
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: const Color(0xFF1E1E1E), // Dark Grey Surface
    );
  }
}
