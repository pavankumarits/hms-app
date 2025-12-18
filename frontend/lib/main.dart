import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'screens/auth/login_screen.dart';
import 'providers/auth_provider.dart';

import 'services/database_helper.dart';
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
  final isConfigured = hospitalId != null;
  
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
        home: isConfigured ? const LoginScreen() : const SetupScreen(),
      ),
    );
  }
}
