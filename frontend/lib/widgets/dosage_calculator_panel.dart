import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/smart_doctor_service.dart';

class DosageCalculatorPanel extends StatefulWidget {
  final String drugName;
  final int age;
  final double weight;
  final Function(String dose) onDoseCalculated;

  const DosageCalculatorPanel({
    super.key,
    required this.drugName,
    required this.age,
    required this.weight,
    required this.onDoseCalculated,
  });

  @override
  State<DosageCalculatorPanel> createState() => _DosageCalculatorPanelState();
}

class _DosageCalculatorPanelState extends State<DosageCalculatorPanel> {
  final SmartDoctorService _service = SmartDoctorService();
  String? _calculatedDose;
  bool _isLoading = false;

  @override
  void didUpdateWidget(DosageCalculatorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.drugName != oldWidget.drugName || widget.weight != oldWidget.weight) {
      _calculate();
    }
  }

  Future<void> _calculate() async {
    if (widget.drugName.isEmpty) return;

    setState(() => _isLoading = true);
    
    // Call real API
    final result = await _service.calculateDosage(
      drugName: widget.drugName,
      weight: widget.weight,
      age: widget.age.toDouble(),
    );

    if (mounted) {
      if (result != null) {
        final doseMg = result['calculated_dose_mg'];
        final doseMl = result['calculated_dose_ml'];
        final freq = result['frequency'];
        
        String display = "${doseMg}mg";
        if (doseMl != null) {
          display += " (${doseMl} ml)";
        }
        
        setState(() {
          _calculatedDose = display;
          _isLoading = false; 
        });
        
        widget.onDoseCalculated("$_calculatedDose $freq");
        
      } else {
        setState(() {
          _calculatedDose = null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.drugName.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // Light Blue
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication_liquid, color: Color(0xFF2563EB), size: 20),
              const SizedBox(width: 8),
              Text(
                "Safe Dosage (AI Calculator)",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E40AF),
                ),
              ),
              const Spacer(),
              if (_isLoading)
                const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E40AF))),
            ],
          ),
          const SizedBox(height: 12),
          if (_calculatedDose != null)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3)),
                  ),
                  child: Text(
                    _calculatedDose!,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Every 6 hours",
                  style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B)),
                ),
              ],
            )
          else if (!_isLoading)
            Text("No dosage protocol found.", style: GoogleFonts.inter(color: Colors.grey))
        ],
      ),
    );
  }
}
