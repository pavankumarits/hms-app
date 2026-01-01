import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'screens/smart_doctor_workbench.dart';

// ... (inside HMSApp)
        home: const SmartDoctorWorkbench(),
import 'services/api_service.dart';
import 'services/sync_service.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Offline Capabilities
  final db = AppDatabase();
  final apiService = ApiService();
  final syncService = SyncService(apiService, db);
  await syncService.init();

  // Check Configuration
  const storage = FlutterSecureStorage();
  final hospitalId = await storage.read(key: 'hospital_id');
  
  // If Hardcoded URL is used, we treat the app as "configured" for server connection
  // However, we still need hospital info. For multi-tenant, login handles hospital ID.
  // So we can skip SetupScreen if we just need the URL.
  final isConfigured = AppConfig.useHardcodedUrl || (hospitalId != null);
  
  runApp(HMSApp(isConfigured: isConfigured));
}

class HMSApp extends StatelessWidget {
  final bool isConfigured;
  const HMSApp({super.key, required this.isConfigured});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'HMS Connect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SmartDoctorWorkbench(),
      ),
    );
  }
}
