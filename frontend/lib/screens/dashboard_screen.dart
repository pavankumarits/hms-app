import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/sync_service.dart'; // Added
import '../services/database_helper.dart'; // Added
import '../core/theme.dart';
import 'patient_list_screen.dart';
import 'dashboard/analytics_dashboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    // Auto-Sync on Launch
    WidgetsBinding.instance.addPostFrameCallback((_) => _triggerSync());
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _triggerSync() async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);
    _rotationController.repeat(); // Start rotation

    try {
      // Initialize services (ideally via Provider)
      // Assuming singleton or simple instance for now
      final syncService = SyncService(ApiService(), AppDatabase());
      final success = await syncService.performSync();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data Synced"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        _rotationController.stop();
        _rotationController.reset();
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: _isSyncing ? null : _triggerSync,
              child: RotationTransition(
                turns: _rotationController,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isSyncing ? Colors.teal.shade50 : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.refresh, 
                    size: 26, 
                    color: _isSyncing ? Colors.teal : Colors.grey[700]
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Statistics Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 4))
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Weekly Overview", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 180,
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: ApiService().fetchGraphData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                        }
                        
                        final List<dynamic> values = (snapshot.hasData && snapshot.data != null) 
                            ? snapshot.data!['values'] ?? List.filled(7, 0)
                            : List.filled(7, 0); // Default to zeros if error/empty
                        
                        // Ensure we have 7 days
                        final displayValues = values.length >= 7 ? values.take(7).toList() : List.filled(7, 0);

                        return BarChart(
                          BarChartData(
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Clean look, no Y axis numbers
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) {
                                   if (val.toInt() < displayValues.length) {
                                     return Padding(
                                       padding: const EdgeInsets.only(top: 8.0),
                                       child: Text("D${val.toInt() + 1}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                     );
                                   }
                                   return const Text('');
                                }),
                              ),
                            ),
                            barGroups: List.generate(displayValues.length, (index) {
                               return BarChartGroupData(
                                 x: index,
                                 barRods: [
                                   BarChartRodData(
                                     toY: (displayValues[index] as int).toDouble(),
                                     color: Theme.of(context).primaryColor,
                                     width: 12,
                                     borderRadius: BorderRadius.circular(6),
                                     backDrawRodData: BackgroundBarChartRodData(show: true, toY: 10, color: Colors.grey[100]), // Background bar
                                   )
                                 ]
                               );
                            }),
                          ),
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Primary Action Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.people_outline, size: 24),
                label: const Text("Manage Patients", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                onPressed: () async {
                   await Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientListScreen()));
                   // Trigger sync when returning from managing patients
                   _triggerSync();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Analytics Button (New)
            SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.insights, size: 24, color: Colors.indigo),
                label: const Text("Hospital Analytics", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.indigo)),
                onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen()));
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.indigo),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
