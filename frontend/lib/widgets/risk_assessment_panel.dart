import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RiskAssessmentPanel extends StatelessWidget {
  final int riskScore; // 0-100
  final String riskLevel; // Low, Medium, High
  final List<String> contributors; // e.g. ["Age > 65", "High BP"]
  final String recommendation;

  const RiskAssessmentPanel({
    super.key,
    required this.riskScore,
    required this.riskLevel,
    required this.contributors,
    required this.recommendation,
  });

  Color _getRiskColor() {
    if (riskLevel == 'High') return const Color(0xFFEF4444); // Red
    if (riskLevel == 'Medium') return const Color(0xFFF59E0B); // Amber
    return const Color(0xFF10B981); // Emerald
  }

  Color _getRiskBgColor() {
    if (riskLevel == 'High') return const Color(0xFFFEF2F2);
    if (riskLevel == 'Medium') return const Color(0xFFFFFBEB);
    return const Color(0xFFECFDF5);
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRiskColor();
    final bgColor = _getRiskBgColor();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.health_and_safety, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            "$riskLevel Risk",
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Container(height: 12, width: 1, color: color.withOpacity(0.3)),
          const SizedBox(width: 8),
          Text(
            "Score: $riskScore",
            style: GoogleFonts.inter(fontSize: 12, color: color.withOpacity(0.8)),
          ),
          if (contributors.isNotEmpty) ...[
             const SizedBox(width: 8),
             Icon(Icons.info_outline, color: color.withOpacity(0.8), size: 14),
          ]
        ],
      ),
    );
  }
}
