import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration for Vyāpāra Gateway
class SupabaseConfig {
  // Your Supabase credentials
  static const String supabaseUrl = 'https://iqihgblzxtwjguyvohny.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxaWhnYmx6eHR3amd1eXZvaG55Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwNTY0MzcsImV4cCI6MjA3MDYzMjQzN30.p4pnXpJ5GMRzYZ7YRJ0sO7dSKK1Be53cjBurIPKLP1g';

  /// Initialize Supabase
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: true, // Set to false in production
      );
      print('Supabase initialized successfully');
    } catch (e) {
      print('Supabase initialization failed: $e');
      // Don't throw error - allow app to continue in offline mode
      // The app will show network status and provide fallback functionality
    }
  }

  /// Get Supabase client instance
  static SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      print('Supabase client not initialized: $e');
      rethrow;
    }
  }

  /// Get current user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get user ID
  static String? get userId => currentUser?.id;

  /// Get user email
  static String? get userEmail => currentUser?.email;
}
