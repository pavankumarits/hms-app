class AppConfig {
  // ---------------------------------------------------------------------------
  // Local WiFi IP - Use when phone is on SAME WiFi as laptop
  // ---------------------------------------------------------------------------
  static const String hardcodedUrl = "http://10.63.158.120:8000";
  
  // Set this to true to SKIP the "Server URL" screen forever
  // Set to false if you want to manually enter it on the phone
  static const bool useHardcodedUrl = true;

  // Default fallback (do not change)
  static const String apiBaseUrl = "http://10.0.2.2:8000/api/v1";
}
