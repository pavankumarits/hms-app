import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/database_helper.dart';

class PatientHistoryScreen extends StatefulWidget {
  final Patient patient;
  const PatientHistoryScreen({super.key, required this.patient});

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  final AppDatabase _db = AppDatabase();
  List<Visit> _visits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    // Query visits for this patient
    final visits = await (_db.select(_db.visits)..where((v) => v.patientId.equals(widget.patient.id))).get();
    
    // Sort by date descending
    visits.sort((a, b) => b.visitDate.compareTo(a.visitDate));

    if (mounted) {
      setState(() {
        _visits = visits;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Visit History', style: TextStyle(fontSize: 16)),
            Text(widget.patient.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : _visits.isEmpty 
          ? const Center(child: Text("No past visits found.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _visits.length,
              itemBuilder: (context, index) {
                final visit = _visits[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd MMM yyyy').format(visit.visitDate),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: visit.syncStatus == 'synced' ? Colors.green[50] : Colors.orange[50], // Check sync status
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                visit.syncStatus == 'synced' ? 'Synced' : 'Pending',
                                style: TextStyle(fontSize: 11, color: visit.syncStatus == 'synced' ? Colors.green : Colors.orange),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        if (visit.complaint != null && visit.complaint!.isNotEmpty) ...[
                          const Text("Complaint:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(visit.complaint!, style: const TextStyle(fontSize: 15)),
                          const SizedBox(height: 8),
                        ],
                        if (visit.diagnosis != null && visit.diagnosis!.isNotEmpty) ...[
                          const Text("Diagnosis:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(visit.diagnosis!, style: const TextStyle(fontSize: 15)),
                          const SizedBox(height: 8),
                        ],
                        if (visit.treatment != null && visit.treatment!.isNotEmpty) ...[
                          const Text("Treatment:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(visit.treatment!, style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                        ],
                         Row(
                           mainAxisAlignment: MainAxisAlignment.end,
                           children: [
                             Text("Bill: \$${visit.billingAmount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                           ],
                         )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
