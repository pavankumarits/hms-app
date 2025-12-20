import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'auth/login_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _adminUserController = TextEditingController();
  final _adminPassController = TextEditingController();
  final _pinController = TextEditingController();
  
  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();

  Future<void> _submitSetup() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    String baseUrl = _urlController.text.trim();
    if (!baseUrl.startsWith('http')) baseUrl = 'https://$baseUrl';
    if (baseUrl.endsWith('/')) baseUrl = baseUrl.substring(0, baseUrl.length - 1);

    try {
      // 1. Call /api/v1/setup
      // We use a raw Dio instance because ApiService might not be configured yet
      // or we want to test the specific URL provided by user.
      final dio = Dio();
      final response = await dio.post(
        '$baseUrl/api/v1/setup',
        data: {
          "hospital_name": _nameController.text,
          "admin_username": _adminUserController.text,
          "admin_password": _adminPassController.text,
          "admin_pin": _pinController.text
        },
      );

      if (response.statusCode == 200) {
        final hospitalId = response.data['hospital_id'];
        
        // 2. Save Config
        await _storage.write(key: 'api_base_url', value: baseUrl);
        await _storage.write(key: 'hospital_id', value: hospitalId);
        await _storage.write(key: 'admin_pin', value: _pinController.text); // Save locally for verifying "Change Hospital"

        if (mounted) {
           Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen())
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Setup Failed: $e")),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hospital Setup (First Launch)")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Welcome! Let's set up your Hospital Server.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Hospital Name", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: "Server Tunnel URL", 
                  hintText: "https://....trycloudflare.com",
                  border: OutlineInputBorder()
                ),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              
              const Divider(),
              const SizedBox(height: 16),
              const Text("Create Admin Account", style: TextStyle(fontWeight: FontWeight.bold)),
               const SizedBox(height: 10),

              TextFormField(
                controller: _adminUserController,
                decoration: const InputDecoration(labelText: "Admin Username", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _adminPassController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Admin Password", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              
              const SizedBox(height: 16),
              
               TextFormField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Settings PIN (for App)", border: OutlineInputBorder()),
                validator: (v) => v!.length < 4 ? "Min 4 digits" : null,
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitSetup,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: _isLoading ? const CircularProgressIndicator() : const Text("INITIALIZE SYSTEM"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
