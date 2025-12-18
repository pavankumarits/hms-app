import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = const FlutterSecureStorage();
  final _urlController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isAuthenticated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUrl();
  }

  Future<void> _loadCurrentUrl() async {
    String? savedUrl = await _storage.read(key: 'api_base_url');
    _urlController.text = savedUrl ?? AppConfig.apiBaseUrl;
    setState(() => _isLoading = false);
  }

  void _verifyPin() {
    // Hardcoded PIN for simplicity as requested (Non-technical user constraint)
    if (_pinController.text == "1234") {
      setState(() => _isAuthenticated = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid PIN")),
      );
    }
  }

  Future<void> _saveSettings() async {
    if (_urlController.text.isEmpty) return;
    
    // Auto-fix URL format
    String url = _urlController.text.trim();
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
    }

    await _storage.write(key: 'api_base_url', value: url);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server URL Updated! Restart App.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Settings")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(20.0),
            child: _isAuthenticated ? _buildUrlForm() : _buildPinForm(),
          ),
    );
  }

  Widget _buildPinForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.security, size: 60, color: Colors.grey),
        const SizedBox(height: 20),
        const Text("Enter Admin PIN to configure Server"),
        const SizedBox(height: 10),
        TextField(
          controller: _pinController,
          decoration: const InputDecoration(
            labelText: "PIN",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          obscureText: true,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _verifyPin, 
          child: const Text("Unlock Settings")
        ),
      ],
    );
  }

  Widget _buildUrlForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Server Configuration", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        const Text("Backend URL (Cloudflare Tunnel):"),
        const SizedBox(height: 5),
        TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            hintText: "https://your-tunnel-url.trycloudflare.com",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        const Text("Tip: Copy the URL from the black server window on your laptop.", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text("Save Configuration"),
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ),
      ],
    );
  }
}
