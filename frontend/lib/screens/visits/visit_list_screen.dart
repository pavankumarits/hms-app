import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/visit_service.dart';
import 'add_visit_screen.dart';

class VisitListScreen extends StatefulWidget {
  const VisitListScreen({super.key});

  @override
  State<VisitListScreen> createState() => _VisitListScreenState();
}

class _VisitListScreenState extends State<VisitListScreen> {
  List<dynamic> _visits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    try {
      final visits = await VisitService().getVisits();
      if (mounted) {
        setState(() {
          _visits = visits;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OPD Visits')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddVisitScreen()),
          );
          if (result == true) _loadVisits();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _visits.isEmpty
              ? const Center(child: Text('No visits recorded.'))
              : ListView.builder(
                  itemCount: _visits.length,
                  itemBuilder: (context, index) {
                    final visit = _visits[index];
                    final date = DateTime.tryParse(visit['visit_date']) ?? DateTime.now();
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: const Icon(Icons.local_hospital, color: Colors.orange)
                        ),
                        title: Text('Data ID: ${visit['id']}'), 
                        // Enhance backend to return patient name in nested object or separate fetch.
                        // Assuming basic list for now.
                        subtitle: Text(
                             "${DateFormat('yyyy-MM-dd HH:mm').format(date)}\n"
                             "Complaint: ${visit['complaint'] ?? 'N/A'}"
                        ),
                        isThreeLine: true,
                        trailing: Text('\$${visit['billing_amount']}'),
                      ),
                    );
                  },
                ),
    );
  }
}
