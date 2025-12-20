import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../data/visit_service.dart';
import '../../data/patient_service.dart';

class AddVisitScreen extends StatefulWidget {
  const AddVisitScreen({super.key});

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _complaintController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _billingController = TextEditingController(text: '0.0');
  
  List<dynamic> _patients = [];
  int? _selectedPatientId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await PatientService().getPatients();
      if (mounted) {
        setState(() {
          _patients = patients;
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint("Error loading patients: $e");
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _selectedPatientId != null) {
      setState(() => _isLoading = true);
      try {
        final visitData = {
          'patient_id': _selectedPatientId,
          'doctor_id': 1, 
          'complaint': _complaintController.text,
          'diagnosis': _diagnosisController.text,
          'treatment': _treatmentController.text,
          'billing_amount': double.tryParse(_billingController.text) ?? 0.0,
        };
        
        await VisitService().createVisit(visitData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Visit Record Saved Successfully')),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else if (_selectedPatientId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a Patient')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New OPD Visit')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
               DropdownButtonFormField<int>(
                value: _selectedPatientId,
                decoration: const InputDecoration(labelText: 'Select Patient'),
                items: _patients.map((p) => DropdownMenuItem<int>(
                  value: p['id'],
                  child: Text('${p['name']} (${p['patient_uiid']})'),
                )).toList(),
                onChanged: (value) => setState(() => _selectedPatientId = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _complaintController,
                decoration: const InputDecoration(labelText: 'Chief Complaint'),
                maxLines: 2,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _diagnosisController,
                decoration: const InputDecoration(labelText: 'Diagnosis'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _treatmentController,
                decoration: const InputDecoration(labelText: 'Treatment / Prescription'),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _billingController,
                decoration: const InputDecoration(labelText: 'Billing Amount'),
                keyboardType: TextInputType.number,
              ),
               const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Save Visit Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
