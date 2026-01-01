import 'package:flutter/material.dart';
import 'dart:async';
import '../services/smart_doctor_service.dart';

class SmartRxPanel extends StatefulWidget {
  final String diagnosis;
  final int patientAge;
  final Function(String) onDrugSelected;
  final List<String> currentMeds;

  const SmartRxPanel({
    super.key,
    required this.diagnosis,
    required this.patientAge,
    required this.onDrugSelected,
    this.currentMeds = const [],
  });

  @override
  State<SmartRxPanel> createState() => _SmartRxPanelState();
}

class _SmartRxPanelState extends State<SmartRxPanel> {
  final SmartDoctorService _service = SmartDoctorService();
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;
  Map<String, dynamic>? _safetyAlert;

  @override
  void didUpdateWidget(SmartRxPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.diagnosis != oldWidget.diagnosis) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 600), () {
        if (widget.diagnosis.length > 3) {
          _fetchSuggestions();
        } else {
          setState(() => _suggestions = []);
        }
      });
    }
  }

  Future<void> _fetchSuggestions() async {
    setState(() => _isLoading = true);
    final results = await _service.predictDrugs(
      diagnosis: widget.diagnosis,
      age: widget.patientAge,
    );
    if (mounted) {
      setState(() {
        _suggestions = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _checkInteraction(String drugName) async {
    if (widget.currentMeds.isEmpty) {
      widget.onDrugSelected(drugName);
      return;
    }

    // Show loading check
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Checking interactions..."), duration: Duration(milliseconds: 500)),
    );

    final result = await _service.auditPrescription(
      newDrug: drugName,
      currentMeds: widget.currentMeds,
    );

    if (mounted) {
      if (result['is_safe'] == false && result['interactions'] != null) {
        final interactions = List<Map<String, dynamic>>.from(result['interactions']);
        if (interactions.isNotEmpty) {
           _showInteractionDialog(drugName, interactions);
           return;
        }
      }
      
      // If safe or no interactions found
      widget.onDrugSelected(drugName);
    }
  }

  void _showInteractionDialog(String newDrug, List<Map<String, dynamic>> interactions) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.deepOrange),
            const SizedBox(width: 8),
            Text("Safety Alert", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Interaction detected with current meds:", style: GoogleFonts.inter(fontSize: 14)),
            const SizedBox(height: 12),
            ...interactions.map((i) => Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED), // Orange-50
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFEDD5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text("${i['interacting_drug']} + $newDrug", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFFC2410C))),
                   const SizedBox(height: 4),
                   Text(i['description'], style: GoogleFonts.inter(fontSize: 12)),
                   if (i['management'] != null)
                     Padding(
                       padding: const EdgeInsets.only(top: 4),
                       child: Text("Advice: ${i['management']}", style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic)),
                     ),
                ],
              ),
            )).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Cancel
            child: const Text("Cancel"),
          ),
          TextButton(
             onPressed: () {
               Navigator.pop(ctx);
               widget.onDrugSelected(newDrug); // Proceed anyway
             },
             child: const Text("Proceed (Override)", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_suggestions.isEmpty && !_isLoading) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF00897B), size: 20),
                const SizedBox(width: 8),
                const Text(
                  "Smart Rx Suggestions",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF37474F), // Professional Grey
                  ),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 12),
            ..._suggestions.map((drug) => _buildDrugOption(drug)).toList(),
            
            if (_safetyAlert != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE), // Light Red
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEF5350)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _safetyAlert!['warnings'][0] ?? "Interaction Detected",
                        style: const TextStyle(
                            color: Color(0xFFC62828), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDrugOption(Map<String, dynamic> drug) {
    final matchScore = drug['match_score'];
    final isTopMatch = matchScore > 95;

    return InkWell(
      onTap: () => _checkInteraction(drug['drug_name']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50], // Very light grey
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
             Icon(
              Icons.medication,
              color: isTopMatch ? const Color(0xFF00897B) : Colors.blueGrey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drug['drug_name'],
                    style: const TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF263238),
                    ),
                  ),
                  Text(
                    drug['line_of_treatment'] == 1 ? "First Line Therapy" : "Second Line",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isTopMatch ? const Color(0xFFE0F2F1) : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isTopMatch ? const Color(0xFF80CBC4) : const Color(0xFF90CAF9),
                ),
              ),
              child: Text(
                "$matchScore% Match",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isTopMatch ? const Color(0xFF00695C) : const Color(0xFF1565C0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
