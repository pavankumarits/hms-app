import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdverseEventAlert extends StatelessWidget {
  final List<Map<String, dynamic>> matches;

  const AdverseEventAlert({super.key, required this.matches});

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), // Light Red background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Possible Adverse Drug Reaction Detected",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF991B1B),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...matches.map((match) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                   const Text("• ", style: TextStyle(color: Color(0xFFB91C1C))),
                   Expanded(
                     child: RichText(
                       text: TextSpan(
                         style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF7F1D1D)),
                         children: [
                           TextSpan(text: "\"${match['side_effect']}\"", style: const TextStyle(fontWeight: FontWeight.bold)),
                           const TextSpan(text: " may be caused by "),
                           TextSpan(text: match['drug_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                           TextSpan(text: " (${match['likelihood']})", style: TextStyle(color: const Color(0xFF7F1D1D).withOpacity(0.8), fontSize: 12)),
                         ],
                       ),
                     ),
                   ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 4),
          Text(
            "Verify before prescribing additional medication to treat this symptom.",
            style: GoogleFonts.inter(fontSize: 11, fontStyle: FontStyle.italic, color: const Color(0xFF991B1B)),
          )
        ],
      ),
    );
  }
}
