class AppConfig {
  // ---------------------------------------------------------------------------
  // Static ngrok dev domain - PERMANENT (won't change)
  // ---------------------------------------------------------------------------
  static const String hardcodedUrl = "https://nonenunciative-jadon-deucedly.ngrok-free.dev";
  
  // Set this to true to SKIP the "Server URL" screen forever
  // Set to false if you want to manually enter it on the phone
  static const bool useHardcodedUrl = true;

  // Default fallback (do not change)
  static const String apiBaseUrl = "http://10.0.2.2:8000/api/v1";
}
