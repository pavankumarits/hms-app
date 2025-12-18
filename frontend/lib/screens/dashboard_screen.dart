import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../core/theme.dart';
import 'patient_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Patient Statistics", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: FutureBuilder<Map<String, dynamic>>(
                future: ApiService().fetchGraphData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(child: Text("Unable to load chart data"));
                  }
                  
                  final data = snapshot.data!;
                  final List<dynamic> values = data['values'] ?? [];
                  
                  return BarChart(
                    BarChartData(
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) {
                             if (val.toInt() < values.length) {
                               return Text("D${val.toInt() + 1}");
                             }
                             return const Text('');
                          }),
                        ),
                      ),
                      barGroups: List.generate(values.length, (index) {
                         return BarChartGroupData(
                           x: index, 
                           barRods: [BarChartRodData(toY: (values[index] as int).toDouble(), color: Colors.blue)]
                         );
                      }),
                    ),
                  );
                }
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.people),
                    label: const Text("Manage Patients"),
                    onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientListScreen()));
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.sync),
                    label: const Text("Sync Now"),
                    onPressed: () async {
                      // Trigger manual sync
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
