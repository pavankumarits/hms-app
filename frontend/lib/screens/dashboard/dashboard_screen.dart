import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/stat_card.dart';
import '../auth/login_screen.dart';
import '../patients/patient_list_screen.dart';
import '../visits/visit_list_screen.dart';
import 'audit_log_screen.dart';
import 'file_upload_screen.dart';
import '../../data/api_client.dart';
import 'package:dio/dio.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _stats = {
    "total_patients": 0,
    "new_patients_today": 0,
    "total_visits": 0,
    "active_doctors": 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final response = await ApiClient().dio.get('/analytics/stats');
      if (mounted) {
        setState(() {
          _stats = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('HMS Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(auth.role?.toUpperCase() ?? 'STAFF'),
              accountEmail: const Text('Logged In'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.teal),
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF00BFA5),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Patients'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PatientListScreen())
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_hospital),
              title: const Text('Visits (OPD)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const VisitListScreen())
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Reports / Uploads'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FileUploadScreen())
                );
              },
            ),
            if (auth.role == 'admin')
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Audit Logs'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AuditLogScreen())
                  );
                },
              ),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 2;
          if (constraints.maxWidth > 600) crossAxisCount = 4; // Web layout

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                StatCard(
                  title: 'New Patients (Today)',
                  value: _stats['new_patients_today'].toString(),
                  icon: Icons.person_add,
                  color: Colors.blue,
                ),
                StatCard(
                  title: 'Total Patients',
                  value: _stats['total_patients'].toString(),
                  icon: Icons.people,
                  color: Colors.purple,
                ),
                StatCard(
                  title: 'Total Visits',
                  value: _stats['total_visits'].toString(),
                  icon: Icons.access_time,
                  color: Colors.orange,
                ),
                StatCard(
                  title: 'Active Doctors',
                  value: _stats['active_doctors'].toString(),
                  icon: Icons.medical_services,
                  color: Colors.green,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
