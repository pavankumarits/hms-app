import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClinicalAlertPanel extends StatelessWidget {
  final List<Map<String, dynamic>> alerts; 

  const ClinicalAlertPanel({
    super.key,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)), // Amber-200 border
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFBEB), // Amber-50
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_active_outlined, color: Color(0xFFD97706), size: 20),
                const SizedBox(width: 8),
                Text(
                  "Clinical Alerts (${alerts.length})",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
          
          // List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alerts.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFFEF3C7)),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final isHighPriority = alert['priority'] == 'High';
              
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isHighPriority ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert['alert_name'],
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alert['message'],
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          if (alert['reference'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                "Ref: ${alert['reference']}",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF94A3B8),
                                  fontStyle: FontStyle.italic
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
