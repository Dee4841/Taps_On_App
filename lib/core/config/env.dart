class Env {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://monvesaedughbmokesuw.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vbnZlc2FlZHVnaGJtb2tlc3V3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA3NjEwNTUsImV4cCI6MjA2NjMzNzA1NX0.HdOxDIRpNp6L5QbFz9Dzbyum2hqqC3_T5Bjsy9ncJvY',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://monvesaedughbmokesuw.supabase.co/functions/v1',
  );
}
