class AppConfig {
  // CONFIGURATION: Replace this with your Fixed Cloudflare Tunnel URL before building the APK.
  // Example: "https://my-hospital-server.com"
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL', 
    defaultValue: 'http://localhost:8000',
  );
  
  static const String appName = "HMS";
}
