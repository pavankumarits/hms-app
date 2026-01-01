import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../services/database_helper.dart';
import '../../services/sync_service.dart';
import '../../services/api_service.dart';
import '../../services/smart_doctor_service.dart';

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
        SyncService(ApiService(), db).performSync(); 

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
                  decoration: _cleanDecoration('Chief Complaint', Icons.sick).copyWith(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.emergency, color: Colors.redAccent),
                      tooltip: "Auto Triage",
                      onPressed: () => _openTriageAssistant(context),
                    ),
                  ),
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

  void _openTriageAssistant(BuildContext context) {
    // Local controllers for the dialog
    final hrController = TextEditingController(text: "72");
    final bpController = TextEditingController(text: "120"); // Systolic
    final painController = TextEditingController(text: "0");
    String consciousness = "Alert";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("🚑 Smart Triage Assistant", style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter quick vitals to assess urgency:", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              // HR
              TextFormField(controller: hrController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Heart Rate", filled: true, fillColor: Colors.black12, labelStyle: TextStyle(color: Colors.grey)), style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              // BP
              TextFormField(controller: bpController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Systolic BP", filled: true, fillColor: Colors.black12, labelStyle: TextStyle(color: Colors.grey)), style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              // Pain
              TextFormField(controller: painController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Pain Score (0-10)", filled: true, fillColor: Colors.black12, labelStyle: TextStyle(color: Colors.grey)), style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              // Conciousness
              DropdownButtonFormField<String>(
                value: consciousness,
                dropdownColor: Colors.black87,
                items: ["Alert", "Confused", "Unresponsive"].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
                onChanged: (v) => consciousness = v!,
                decoration: const InputDecoration(labelText: "Consciousness", filled: true, fillColor: Colors.black12, labelStyle: TextStyle(color: Colors.grey)),
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              _performTriage(context, 
                _complaintController.text, 
                double.tryParse(hrController.text) ?? 72, 
                double.tryParse(bpController.text) ?? 120, 
                int.tryParse(painController.text) ?? 0, 
                consciousness
              );
            }, 
            child: const Text("Analyze")
          )
        ],
      ),
    );
  }

  void _performTriage(BuildContext context, String symptoms, double hr, double sbp, int pain, String consciousness) async {
     // Show Loading
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    
    final result = await SmartDoctorService().predictTriage(
      symptoms: symptoms.isEmpty ? "General checkup" : symptoms,
      vitals: {"heart_rate": hr, "systolic_bp": sbp},
      painScore: pain,
      consciousness: consciousness
    );
    
    if (context.mounted) Navigator.pop(context); // Close loading

    if (result != null && context.mounted) {
      _showTriageResult(context, result);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Triage Failed. Check Backend.")));
    }
  }

  void _showTriageResult(BuildContext context, Map<String, dynamic> result) {
     final level = result['triage_level'];
     final color = level <= 2 ? Colors.red : (level == 3 ? Colors.orange : Colors.green);

     showDialog(context: context, builder: (_) => AlertDialog(
       backgroundColor: const Color(0xFF1E1E1E),
       title: Text("Triage: Level $level", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
       content: Column(
         mainAxisSize: MainAxisSize.min,
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text("Category: ${result['category']}", style: const TextStyle(color: Colors.white, fontSize: 18)),
           const SizedBox(height: 8),
           Text("Wait Time: ${result['estimated_wait_time']}", style: const TextStyle(color: Colors.white70)),
           const Divider(color: Colors.grey),
           Text(result['reasoning'] ?? "", style: const TextStyle(color: Colors.white)),
         ],
       ),
       actions: [
         TextButton(onPressed: () {
           // Append to diagnosis
           _diagnosisController.text = "${_diagnosisController.text} [Triage Level $level: ${result['category']}]".trim(); 
           Navigator.pop(context);
         }, child: const Text("Add to Record")),
       ],
     ));
  }
}
