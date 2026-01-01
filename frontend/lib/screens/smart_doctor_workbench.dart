import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../widgets/smart_rx_panel.dart';
import '../widgets/lab_recommendation_panel.dart';
import '../widgets/dosage_calculator_panel.dart';
import '../widgets/risk_assessment_panel.dart';
import '../widgets/clinical_alert_panel.dart';
import '../widgets/adverse_event_alert.dart';
import '../services/smart_doctor_service.dart';

class SmartDoctorWorkbench extends StatefulWidget {
  const SmartDoctorWorkbench({super.key});

  @override
  State<SmartDoctorWorkbench> createState() => _SmartDoctorWorkbenchState();
}

class _SmartDoctorWorkbenchState extends State<SmartDoctorWorkbench> {
  final _diagnosisCtrl = TextEditingController();
  final _treatmentCtrl = TextEditingController();
  List<Map<String, dynamic>> _diagnosisSuggestions = [];
  
  // Simulation: Patient Info
  final int _patientAge = 45;
  final double _patientWeight = 15.0;
  final List<String> _currentMeds = ["Simvastatin 20mg"];
  
  // Risk State & Alerts
  Map<String, dynamic>? _riskData;
  bool _loadingRisk = true;
  List<Map<String, dynamic>> _alerts = [];
  List<Map<String, dynamic>> _adverseMatches = [];
  Map<String, dynamic>? _readmissionRisk;

  @override
  void initState() {
    super.initState();
    _fetchCombinedData();
  }

  Future<void> _checkAdverseReaction(String symptom) async {
    if (symptom.length < 3) return;
    
    // Check if this symptom is a side effect of current meds
    final matches = await SmartDoctorService().checkAdverseReactions(
      symptoms: [symptom],
      currentMeds: _currentMeds,
    );
    
    if (mounted) {
      setState(() {
        _adverseMatches = matches;
      });
    }
  }

  Future<void> _fetchCombinedData() async {
    // 1. Fetch Risk
    final riskResult = await SmartDoctorService().assessRisk(
      age: 45,
      gender: "Male",
      systolicBp: 142,
      diastolicBp: 90,
      conditions: ["Hypertension", "Smoker"],
      lifestyle: ["Obesity"],
    );

    // 2. Fetch Alerts (Preventive Gaps)
    final alertsResult = await SmartDoctorService().checkAlerts(
      age: 45,
      gender: "Male",
      conditions: ["Hypertension", "Smoker"],
    );
    
    // 3. Predict Readmission Risk (Phase 2)
    // Simulated data: 45 yr old, 1 visit, 2 conditions, discharged 30 days ago
    final readmissionResult = await SmartDoctorService().predictReadmission(
      age: 45,
      visitsLast30Days: 1,
      chronicConditionCount: 2,
      daysSinceDischarge: 30,
    );

    if (mounted) {
       setState(() {
         _riskData = riskResult;
         _alerts = alertsResult;
         _readmissionRisk = readmissionResult;
         _loadingRisk = false;
       });
    }
  }

  String _selectedDrugName = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light Blue-Grey Background (Clean)
      appBar: AppBar(
        title: Text(
          "Doctor Workbench (AI-Assisted)",
          style: GoogleFonts.inter(
            color: const Color(0xFF1E293B), // Dark Slate
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFF64748B)),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Header Card
            _buildPatientHeader(),
            const SizedBox(height: 16),
            
            // 0.5 Preventive Alerts (Injects here)
            if (_alerts.isNotEmpty)
               ClinicalAlertPanel(alerts: _alerts),

            const SizedBox(height: 8),

            // 0. Symptoms Input (AI Chain Start)
            Text(
              "SYMPTOMS (AI DIAGNOSIS)",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF64748B),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: TextField(
                style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: "e.g. fever, headache, chest pain...",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                  suffixIcon: const Icon(Icons.auto_awesome_mosaic, color: Color(0xFF6366F1)),
                ),
                onChanged: (val) {
                  if (val.length > 3) {
                     // Debounce logic omitted for brevity, calling directly for demo
                     SmartDoctorService().predictDiagnosis(val).then((suggestions) {
                        setState(() { _diagnosisSuggestions = suggestions; });
                     });
                     
                     // Check for adverse events (e.g. "Cough")
                     _checkAdverseReaction(val);
                  }
                },
              ),
            ),
            if (_diagnosisSuggestions.isNotEmpty)
               Padding(
                 padding: const EdgeInsets.only(top: 10),
                 child: Wrap(
                   spacing: 8,
                   children: _diagnosisSuggestions.map((s) => ActionChip(
                     backgroundColor: const Color(0xFFEEF2FF),
                     label: Text("${s['name']} (${s['confidence']}%)", style: const TextStyle(color: Color(0xFF4338CA), fontWeight: FontWeight.bold)),
                     onPressed: () {
                        setState(() {
                          _diagnosisCtrl.text = s['name'];
                          _diagnosisSuggestions = []; // clear
                        });
                     },
                   )).toList(),
                 ),
               ),
             
             // 0.8 Adverse Event Alert (Injects here)
             if (_adverseMatches.isNotEmpty)
                AdverseEventAlert(matches: _adverseMatches),

             const SizedBox(height: 24),

            // 1. Diagnosis Input
            Text(
              "DIAGNOSIS",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF64748B),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _diagnosisCtrl,
                style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: "Enter diagnosis (e.g. Hypertension)...",
                  hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                  suffixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                ),
                onChanged: (val) {
                  setState(() {}); // Trigger rebuild to update SmartRxPanel
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 1.5 Lab Recommendations Panel (Injects here)
            LabRecommendationPanel(diagnosis: _diagnosisCtrl.text),
            
            // 2. The Smart AI Panel (Injects here)
            SmartRxPanel(
              diagnosis: _diagnosisCtrl.text,
              patientAge: _patientAge,
              currentMeds: _currentMeds,
              onDrugSelected: (drugName) {
                setState(() {
                   // Instead of adding immediately, we select it for dosage calc
                   _selectedDrugName = drugName;
                });
              },
            ),

            const SizedBox(height: 16),

            // 2.5 Dosage Calculator (Injects here)
            if (_selectedDrugName.isNotEmpty)
               DosageCalculatorPanel(
                 drugName: _selectedDrugName,
                 age: _patientAge,
                 weight: _patientWeight,
                 onDoseCalculated: (doseInfo) {
                    setState(() {
                      _treatmentCtrl.text = "${_treatmentCtrl.text}$_selectedDrugName - $doseInfo\n";
                      _selectedDrugName = ""; // Reset after adding
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Added $_selectedDrugName ($doseInfo)"),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                 },
               ),

            const SizedBox(height: 24),

            // 3. Treatment Plan
            Text(
              "TREATMENT PLAN",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF64748B),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _treatmentCtrl,
                maxLines: 6,
                style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: "Prescribed meds will appear here...",
                  hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),

            const SizedBox(height: 24),
            
            // 4. Discharge Planning (AI Readmission Prediction)
            if (_readmissionRisk != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _readmissionRisk!['risk_level'] == 'High' 
                      ? const Color(0xFFFEF2F2) 
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _readmissionRisk!['risk_level'] == 'High'
                          ? const Color(0xFFFECACA)
                          : const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                       children: [
                         Icon(
                           _readmissionRisk!['risk_level'] == 'High' ? Icons.warning_rounded : Icons.check_circle,
                           color: _readmissionRisk!['risk_level'] == 'High' ? Colors.red : Colors.green,
                         ),
                         const SizedBox(width: 8),
                         Text(
                           "Readmission Risk: ${_readmissionRisk!['risk_level']}",
                           style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                         ),
                         const Spacer(),
                         Text(
                           "${_readmissionRisk!['risk_score']}% probability",
                           style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey[600]),
                         )
                       ],
                     ),
                     const SizedBox(height: 8),
                     Text(
                       "Recommendation: ${_readmissionRisk!['recommendation']}",
                       style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                     ),
                  ],
                ),
              ),

             const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6), // Professional Blue
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Finalize Prescription",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFE0F2FE),
            child: Text("JD", style: TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "John Doe",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                "Male, 45 Years • ID: #PT-88219",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const Spacer(),
          const Spacer(),
          if (_loadingRisk)
             const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          else if (_riskData != null)
             RiskAssessmentPanel(
               riskScore: _riskData!['total_score'],
               riskLevel: _riskData!['risk_level'],
               contributors: List<String>.from(_riskData!['contributors'].map((c) => c['factor'])),
               recommendation: _riskData!['recommendation'],
             )
        ],
      ),
    );
  }
}
