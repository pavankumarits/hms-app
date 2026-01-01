import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/smart_doctor_service.dart';

class LabRecommendationPanel extends StatefulWidget {
  final String diagnosis;

  const LabRecommendationPanel({
    super.key,
    required this.diagnosis,
  });

  @override
  State<LabRecommendationPanel> createState() => _LabRecommendationPanelState();
}

class _LabRecommendationPanelState extends State<LabRecommendationPanel> {
  final SmartDoctorService _service = SmartDoctorService();
  List<Map<String, dynamic>> _recommendations = [];
  bool _isLoading = false;

  @override
  void didUpdateWidget(LabRecommendationPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.diagnosis != oldWidget.diagnosis && widget.diagnosis.length > 3) {
      _fetchLabs();
    } else if (widget.diagnosis.length <= 3) {
      setState(() => _recommendations = []);
    }
  }

  Future<void> _fetchLabs() async {
    setState(() => _isLoading = true);
    final results = await _service.getLabRecommendations(widget.diagnosis);
    if (mounted) {
      setState(() {
        _recommendations = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_recommendations.isEmpty && !_isLoading) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // Light Green bg
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science, color: Color(0xFF15803D), size: 20),
              const SizedBox(width: 8),
              Text(
                "Suggested Lab Tests (AI)",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF166534),
                ),
              ),
              const Spacer(),
              if (_isLoading)
                const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF166534))),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _recommendations.map((lab) {
              final priority = lab['priority'];
              final isEssential = priority == 'Essential';
              
              return Chip(
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: isEssential ? const Color(0xFF15803D) : const Color(0xFF86EFAC),
                ),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lab['test_name'],
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF14532D),
                        fontSize: 12,
                      ),
                    ),
                    if (isEssential) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.star, size: 12, color: Color(0xFFEAB308)),
                    ]
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
