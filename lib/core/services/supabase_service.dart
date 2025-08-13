import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

/// Service for Supabase operations
class SupabaseService {
  static SupabaseClient get _client => SupabaseConfig.client;

  /// Test database connection
  static Future<bool> testConnection() async {
    try {
      final response = await _client.from('business_types').select('count');
      return true;
    } catch (e) {
      print('Supabase connection test failed: $e');
      return false;
    }
  }

  /// Get user profile by ID
  static Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// Create user profile
  static Future<UserProfile?> createUserProfile({
    required String id,
    required String email,
    required String fullName,
    required String phone,
    required String nic,
    UserRole role = UserRole.businessOwner,
  }) async {
    try {
      final userData = {
        'id': id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'nic': nic,
        'role': role.value,
        'is_email_verified': false,
        'is_nic_verified': false,
        'is_phone_verified': false,
      };

      final response = await _client
          .from('user_profiles')
          .insert(userData)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error creating user profile: $e');
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Update user profile
  static Future<UserProfile?> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _client
          .from('user_profiles')
          .update({...updates, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error updating user profile: $e');
      return null;
    }
  }

  /// Check if NIC already exists
  static Future<bool> isNicExists(String nic) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select('nic')
          .eq('nic', nic)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking NIC: $e');
      return false;
    }
  }

  /// Get business types
  static Future<List<Map<String, dynamic>>> getBusinessTypes() async {
    try {
      final response = await _client
          .from('business_types')
          .select('*')
          .eq('is_active', true)
          .order('display_name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching business types: $e');
      return [];
    }
  }

  /// Validate NIC against sample database
  static Future<Map<String, dynamic>?> validateNic(String nic) async {
    try {
      final response = await _client
          .from('nic_validation_data')
          .select('*')
          .eq('nic', nic)
          .eq('is_valid', true)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error validating NIC: $e');
      return null;
    }
  }
}
