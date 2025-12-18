import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import 'dart:io';
import '../services/database_helper.dart';

class VisitFormScreen extends StatefulWidget {
  final String patientId;
  const VisitFormScreen({super.key, required this.patientId});

  @override
  State<VisitFormScreen> createState() => _VisitFormScreenState();
}

class _VisitFormScreenState extends State<VisitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _complaintCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _treatmentCtrl = TextEditingController();
  final _feeCtrl = TextEditingController(text: "0.0");

  // File Upload Logic
  String? _uploadedFileId;
  bool _isUploading = false;

  void _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
        setState(() => _isUploading = true);
        
        try {
            // Note: This only works if Online. Offline file upload is complex.
            // We assume user is online for file upload in this MVP.
            File file = File(result.files.single.path!);
            FormData formData = FormData.fromMap({
                "file": await MultipartFile.fromFile(file.path, filename: result.files.single.name),
                "visit_id": const Uuid().v4(), // Temporary, should link to actual visit if saved
                "file_type": "REPORT"
            });
            
            final api = ApiService();
            await api.client.post("/files/upload/", data: formData);
            
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("File Uploaded!")));
        } catch (e) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload Failed: $e")));
        } finally {
            setState(() => _isUploading = false);
        }
    }
  }

  void _saveVisit() async {
    if (_formKey.currentState!.validate()) {
      final db = AppDatabase();
      final newId = const Uuid().v4();
      
      final visit = VisitsCompanion.insert(
        id: newId,
        patientId: widget.patientId,
        doctorId: "current-doctor-id", // Should get from AuthProvider
        complaint: Value(_complaintCtrl.text),
        diagnosis: Value(_diagnosisCtrl.text),
        treatment: Value(_treatmentCtrl.text),
        billingAmount: Value(double.tryParse(_feeCtrl.text) ?? 0.0),
        syncStatus: const Value('pending'),
      );
      
      await db.into(db.visits).insert(visit);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Visit")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _complaintCtrl,
              decoration: const InputDecoration(labelText: "Chief Complaint"),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _diagnosisCtrl,
              decoration: const InputDecoration(labelText: "Diagnosis"),
              maxLines: 2,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _treatmentCtrl,
              decoration: const InputDecoration(labelText: "Treatment / Rx"),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _feeCtrl,
              decoration: const InputDecoration(labelText: "Consultation Fee"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
                icon: _isUploading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Icon(Icons.upload_file),
                label: Text(_isUploading ? "Uploading..." : "Upload Medical Record (Online Only)"),
                onPressed: _isUploading ? null : _uploadFile,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveVisit, child: const Text("Save Visit"))
          ],
        ),
      ),
    );
  }
}
