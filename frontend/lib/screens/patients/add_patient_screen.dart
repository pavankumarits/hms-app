import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../services/database_helper.dart';
import '../../services/sync_service.dart';
import '../../services/api_service.dart';
import 'package:provider/provider.dart'; // Assuming provider is available, or we pass instances

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  // State
  DateTime _selectedDob = DateTime.now(); // Default to today/registration date
  String _selectedGender = 'Male';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Save to Local DB
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final db = AppDatabase();
        final uuid = const Uuid().v4();
        
        // 1. Generate Sequential ID (P-YYYYMMDD-XXXX)
        final now = DateTime.now();
        final datePrefix = 'P${DateFormat('yyyyMMdd').format(now)}-'; // P20251227-
        
        // Get last ID for today
        final lastId = await db.getLastPatientIdForDate(datePrefix);
        
        int nextSeq = 1;
        if (lastId != null) {
          // Parse "P20251227-0001" -> 0001
          try {
             final parts = lastId.split('-');
             if (parts.isNotEmpty) {
               nextSeq = int.parse(parts.last) + 1;
             }
          } catch (e) {
            print("Error parsing ID sequence: $e");
            // Fallback to 1 if parsing fails
          }
        }
        
        final newUiid = '$datePrefix${nextSeq.toString().padLeft(4, '0')}'; // P20251227-0001

        // 2. Create Patient Object (Local)
        final newPatient = Patient(
          id: uuid,
          patientUiid: newUiid,
          name: _nameController.text.trim(),
          gender: _selectedGender,
          dob: _selectedDob,
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: 'pending', // Mark for Sync
        );

        // 2. Insert into SQLite
        await db.insertPatient(newPatient);

        // 3. Trigger Background Sync (Fire and Forget)
        // We catch errors silently here so UI doesn't freeze
        SyncService(ApiService(), db).performSync();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Patient Saved Locally'), 
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
          Navigator.of(context).pop(true); // Return success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Reusable Decoration for clean UI (Dark Theme)
  InputDecoration _cleanDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF9E9E9E)), // Muted Grey
      prefixIcon: Icon(icon, size: 22, color: const Color(0xFF4DB6AC)), // Muted Teal
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
        borderSide: const BorderSide(color: Color(0xFF26A69A), width: 1.5), // Thin Teal
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: const Color(0xFF1E1E1E), // Dark Grey Surface
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414), // Dark Matte Background
      appBar: AppBar(
        title: const Text('New Patient Registration', style: TextStyle(color: Colors.white)),
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
                const Text(
                  "Patient Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4DB6AC), // Muted Teal
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: Color(0xFF2E2E2E), thickness: 1),
                const SizedBox(height: 20),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: _cleanDecoration('Full Name', Icons.person),
                  style: const TextStyle(color: Color(0xFFEAEAEA)), // Off-white text
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => value!.trim().isEmpty ? 'Please enter name' : null,
                ),
                const SizedBox(height: 16),

                // Gender & Date Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        dropdownColor: const Color(0xFF1E1E1E),
                        decoration: _cleanDecoration('Gender', Icons.wc),
                        style: const TextStyle(color: Color(0xFFEAEAEA)),
                        items: ['Male', 'Female', 'Other'].map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label, style: const TextStyle(color: Color(0xFFEAEAEA))),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedGender = value!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _dateController,
                            decoration: _cleanDecoration('Date of Birth', Icons.calendar_today),
                            style: const TextStyle(color: Color(0xFFEAEAEA)),
                            validator: (val) => val!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  decoration: _cleanDecoration('Mobile Number', Icons.phone),
                  style: const TextStyle(color: Color(0xFFEAEAEA)),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Address
                TextFormField(
                  controller: _addressController,
                  decoration: _cleanDecoration('Address / City', Icons.home),
                  style: const TextStyle(color: Color(0xFFEAEAEA)),
                  maxLines: 2,
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  height: 56, // Large button
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      backgroundColor: const Color(0xFF00897B),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: Colors.black45,
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Patient', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
