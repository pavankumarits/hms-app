import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../services/api_service.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    try {
      final response = await ApiService().client.get('/ml/dashboard-insights');
      if (mounted) {
        setState(() {
          _data = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load analytics: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hospital AI Analytics")),
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Header with Model Status
                      _buildStatusCard(),
                      const SizedBox(height: 16),
                      
                      // 2. Outbreak Prediction (Hero Card)
                      _buildOutbreakCard(),
                      const SizedBox(height: 16),
                      
                      // 3. Resource Forecast
                      _buildResourceCard(),
                      const SizedBox(height: 16),

                      // 4. Clinical Risk Summary
                      _buildRiskSummaryCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: Colors.blueGrey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
             const Icon(Icons.psychology, color: Colors.greenAccent, size: 32),
             const SizedBox(width: 16),
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const Text("AI System Status", style: TextStyle(color: Colors.white70)),
                 Text(_data?['ml_model_status'] ?? "Unknown", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
               ],
             )
          ],
        ),
      ),
    );
  }

  Widget _buildOutbreakCard() {
    final outbreak = _data?['outbreak_prediction'] ?? {};
    final riskLevel = outbreak['risk_level'] ?? "Low";
    final isHigh = riskLevel == "High" || riskLevel == "Medium";
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.coronavirus, color: isHigh ? Colors.orange : Colors.green),
                const SizedBox(width: 8),
                const Text("Disease Outbreak Prediction", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text("Disease: ${outbreak['disease']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text("Trend: ${outbreak['trend']} (${outbreak['predicted_cases_next_week']} cases exp.)"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isHigh ? Colors.orange[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isHigh ? Colors.orange : Colors.green)
              ),
              child: Row(children: [
                 const Icon(Icons.info_outline, size: 16),
                 const SizedBox(width: 8),
                 Expanded(child: Text(outbreak['alert'] ?? "No alerts", style: TextStyle(color: isHigh ? Colors.orange[900] : Colors.green[900])))
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard() {
    final res = _data?['resource_forecast'] ?? {};
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Resource Utilization Forecast", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 _statItem("Current Occ.", res['current_occupancy']),
                 _statItem("Pred. 24h", res['predicted_occupancy_24h']),
                 _statItem("Status", res['status'], color: res['status'] == 'Strain Likely' ? Colors.red : Colors.green),
              ],
            ),
            const SizedBox(height: 12),
            Text("Rec: ${res['recommendation']}", style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
  
  Widget _statItem(String label, String? val, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(val ?? "-", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color ?? Colors.black87)),
      ],
    );
  }

  Widget _buildRiskSummaryCard() {
    final risk = _data?['clinical_risk_summary'] ?? {};
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(children: [
               Text("${risk['high_risk_patients_monitored']}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
               const Text("High Risk Patients")
            ]),
            Column(children: [
               Text("${risk['readmission_watch_list']}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple)),
               const Text("Readmission Watch")
            ]),
          ],
        ),
      ),
    );
  }
}
