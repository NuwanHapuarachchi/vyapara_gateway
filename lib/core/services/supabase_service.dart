import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

/// Service for Supabase operations
class SupabaseService {
  static SupabaseClient get _client => SupabaseConfig.client;

  /// Test database connection
  static Future<bool> testConnection() async {
    try {
      await _client.from('business_types').select('count');
      return true;
    } catch (e) {
      print('Supabase connection test failed: $e');
      return false;
    }
  }

  /// =============================
  /// Notifications
  /// =============================
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final String? userId = SupabaseConfig.userId;
      if (userId == null) return [];
      final response = await _client
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching notifications: $e');
      // Return sample notifications if table doesn't exist
      return [
        {
          'id': '1',
          'title': 'Application Status Update',
          'body': 'Your business registration application is being reviewed.',
          'read_at': null,
          'created_at': DateTime.now()
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
        },
        {
          'id': '2',
          'title': 'Document Upload Required',
          'body':
              'Please upload your tax certificate to complete your profile.',
          'read_at': null,
          'created_at': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
        },
        {
          'id': '3',
          'title': 'Welcome to Vyapara Gateway',
          'body': 'Thank you for joining our business management platform.',
          'read_at': DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String(),
          'created_at': DateTime.now()
              .subtract(const Duration(days: 3))
              .toIso8601String(),
        },
      ];
    }
  }

  /// Mark notification as read
  static Future<void> markNotificationRead(String id) async {
    try {
      await _client
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// =============================
  /// Documents (Storage bucket: 'business-documents')
  /// =============================
  static const String _documentsBucket = 'business-documents';

  /// Test storage bucket connectivity
  static Future<bool> testStorageBucket() async {
    try {
      final userId = SupabaseConfig.userId;
      if (userId == null) {
        print('Storage test failed: User not authenticated');
        return false;
      }

      print('Testing storage bucket: $_documentsBucket');

      // Try to list files in the bucket
      final results = await _client.storage
          .from(_documentsBucket)
          .list(path: '$userId/', searchOptions: const SearchOptions());

      print('Storage bucket test successful. Found ${results.length} files.');
      return true;
    } catch (e) {
      print('Storage bucket test failed: $e');

      if (e.toString().contains('bucket') ||
          e.toString().contains('not found')) {
        print(
          'Bucket "$_documentsBucket" does not exist. Please create it in Supabase Dashboard.',
        );
      }
      if (e.toString().contains('permission') ||
          e.toString().contains('policy')) {
        print(
          'Permission denied. Check RLS policies for bucket "$_documentsBucket".',
        );
      }

      return false;
    }
  }

  /// List files for current user in storage
  static Future<List<FileObject>> listUserDocuments() async {
    try {
      final String folder = '${SupabaseConfig.userId}/';
      final results = await _client.storage
          .from(_documentsBucket)
          .list(path: folder, searchOptions: const SearchOptions());
      return results;
    } catch (e) {
      print('Error listing documents: $e');
      return [];
    }
  }

  /// Upload document bytes and return public URL (if bucket is public)
  static Future<String?> uploadDocumentBytes({
    required Uint8List data,
    required String fileName,
    String contentType = 'application/octet-stream',
  }) async {
    try {
      final userId = SupabaseConfig.userId;
      if (userId == null) {
        print('Error: User not authenticated');
        return null;
      }

      print('Uploading document: $fileName to bucket: $_documentsBucket');
      print('User ID: $userId');
      print('File size: ${data.length} bytes');
      print('Content type: $contentType');

      final String path = '$userId/$fileName';
      print('Upload path: $path');

      await _client.storage
          .from(_documentsBucket)
          .uploadBinary(
            path,
            data,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );

      print('Upload successful, getting public URL...');

      // Return a signed URL for private buckets or public URL for public buckets
      final publicUrl = _client.storage
          .from(_documentsBucket)
          .getPublicUrl(path);

      print('Generated URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Error uploading document: $e');
      print('Stack trace: ${StackTrace.current}');

      // More detailed error information
      if (e.toString().contains('bucket')) {
        print('Bucket error - check if bucket "$_documentsBucket" exists');
      }
      if (e.toString().contains('permission') ||
          e.toString().contains('policy')) {
        print('Permission error - check RLS policies and authentication');
      }
      if (e.toString().contains('size')) {
        print('File size error - check file size limits');
      }

      return null;
    }
  }

  /// Delete a document by path
  static Future<bool> deleteDocument(String path) async {
    try {
      print('Deleting document: $path from bucket: $_documentsBucket');

      final result = await _client.storage.from(_documentsBucket).remove([
        path,
      ]);

      print('Delete result: $result');

      // Empty list means success, non-empty list contains errors
      final success = result.isEmpty;
      print('Delete ${success ? 'successful' : 'failed'}');

      return success;
    } catch (e) {
      print('Error deleting document: $e');

      // More detailed error information
      if (e.toString().contains('permission') ||
          e.toString().contains('policy')) {
        print('Permission error - check RLS policies for delete operation');
      }
      if (e.toString().contains('not found')) {
        print('File not found - may have been already deleted');
      }

      return false;
    }
  }

  /// =============================
  /// Payments
  /// =============================
  static Future<List<Map<String, dynamic>>> getPayments() async {
    try {
      final String? userId = SupabaseConfig.userId;
      if (userId == null) return [];
      final response = await _client
          .from('payments')
          .select('*')
          .eq('payer_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching payments: $e');
      // Return sample payments if table doesn't exist
      return [
        {
          'id': '1',
          'title': 'Business Registration Fee',
          'amount_cents': 925000,
          'status': 'completed',
          'created_at': DateTime.now()
              .subtract(const Duration(days: 5))
              .toIso8601String(),
        },
        {
          'id': '2',
          'title': 'Annual License Renewal',
          'amount_cents': 150000,
          'status': 'pending',
          'created_at': DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String(),
        },
        {
          'id': '3',
          'title': 'Tax Filing Service',
          'amount_cents': 75000,
          'status': 'completed',
          'created_at': DateTime.now()
              .subtract(const Duration(days: 10))
              .toIso8601String(),
        },
      ];
    }
  }

  static Future<Map<String, dynamic>?> createPaymentDraft({
    required String title,
    required int amountCents,
  }) async {
    try {
      final response = await _client
          .from('payments')
          .insert({
            'user_id': SupabaseConfig.userId,
            'title': title,
            'amount_cents': amountCents,
            'status': 'pending',
          })
          .select()
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error creating payment draft: $e');
      return null;
    }
  }

  /// =============================
  /// Calendar / Events
  /// =============================
  static Future<List<Map<String, dynamic>>> getUpcomingEvents() async {
    try {
      final String? userId = SupabaseConfig.userId;
      if (userId == null) return [];

      // Try to fetch from events table, fallback to sample data if table doesn't exist
      final response = await _client
          .from('events')
          .select('*')
          .eq('user_id', userId)
          .gte('start_at', DateTime.now().toIso8601String())
          .order('start_at');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching events: $e');
      // Return sample events if table doesn't exist
      return [
        {
          'id': '1',
          'title': 'Business Registration Appointment',
          'description': 'Complete business registration process',
          'start_at': DateTime.now()
              .add(const Duration(days: 2))
              .toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'title': 'Tax Consultation',
          'description': 'Meet with tax advisor for annual planning',
          'start_at': DateTime.now()
              .add(const Duration(days: 5))
              .toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '3',
          'title': 'License Renewal Deadline',
          'description': 'Business license renewal due',
          'start_at': DateTime.now()
              .add(const Duration(days: 10))
              .toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        },
      ];
    }
  }

  /// =============================
  /// Mentors & Reservations
  /// =============================
  static Future<List<Map<String, dynamic>>> getMentors() async {
    try {
      final response = await _client.from('mentors').select('*').order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching mentors: $e');
      return [];
    }
  }

  static Future<bool> reserveMentor({required String mentorId}) async {
    try {
      await _client.from('mentor_reservations').insert({
        'user_id': SupabaseConfig.userId,
        'mentor_id': mentorId,
        'status': 'reserved',
        'reserved_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error reserving mentor: $e');
      return false;
    }
  }

  /// =============================
  /// Mentor Chat Messages (simple fetch/insert)
  /// =============================
  static Future<List<Map<String, dynamic>>> getMessages({
    required String mentorId,
  }) async {
    try {
      final response = await _client
          .from('mentor_messages')
          .select('*')
          .or('user_id.eq.${SupabaseConfig.userId},mentor_id.eq.$mentorId')
          .order('created_at');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  static Future<void> sendMessage({
    required String mentorId,
    required String text,
  }) async {
    try {
      await _client.from('mentor_messages').insert({
        'user_id': SupabaseConfig.userId,
        'mentor_id': mentorId,
        'text': text,
      });
    } catch (e) {
      print('Error sending message: $e');
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

  // Removed duplicate - using the one in Business Registration section below

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
      // Return sample validation data for demo
      final sampleNics = {
        '123456789V': {
          'nic': '123456789V',
          'full_name': 'John Perera',
          'date_of_birth': '1990-05-15',
          'gender': 'Male',
          'is_valid': true,
        },
        '987654321V': {
          'nic': '987654321V',
          'full_name': 'Jane Silva',
          'date_of_birth': '1985-12-20',
          'gender': 'Female',
          'is_valid': true,
        },
        '555666777V': {
          'nic': '555666777V',
          'full_name': 'Ravi Fernando',
          'date_of_birth': '1992-08-10',
          'gender': 'Male',
          'is_valid': true,
        },
      };

      return sampleNics[nic];
    }
  }

  /// =============================
  /// Business Registration
  /// =============================
  static Future<List<Map<String, dynamic>>> getBusinessTypes() async {
    try {
      final response = await _client
          .from('business_types')
          .select('*')
          .order('display_name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching business types: $e');
      // Return sample business types with Sri Lankan requirements
      return [
        {
          'id': '1',
          'type': 'sole_proprietorship',
          'display_name': 'Sole Proprietorship',
          'description':
              'Individual business ownership registered at Divisional Secretariat Office',
          'required_documents': [
            'application_form_divisional_secretariat',
            'grama_niladhari_certified_report',
            'nic_copy',
            'business_premises_proof',
            'trade_permit_municipal',
          ],
          'estimated_processing_days': 7,
          'base_fee': 2500.00,
          'registration_office': 'Divisional Secretariat Office',
        },
        {
          'id': '2',
          'type': 'partnership',
          'display_name': 'Partnership',
          'description':
              'Business partnership registered at Divisional Secretariat Office',
          'required_documents': [
            'application_form_divisional_secretariat',
            'grama_niladhari_certified_report',
            'partners_nic_copies',
            'partnership_agreement',
            'business_premises_proof',
            'trade_permit_municipal',
          ],
          'estimated_processing_days': 10,
          'base_fee': 5000.00,
          'registration_office': 'Divisional Secretariat Office',
        },
        {
          'id': '3',
          'type': 'private_limited_company',
          'display_name': 'Private Limited Company',
          'description':
              'Private limited company registered through eROC system',
          'required_documents': [
            'form_1_company_registration',
            'form_18_director_consent',
            'form_19_secretary_consent',
            'articles_of_association',
            'directors_shareholders_id_copies',
          ],
          'estimated_processing_days': 14,
          'base_fee': 15000.00,
          'registration_office': 'Department of Registrar of Companies (eROC)',
          'additional_requirements': [
            'Company name reservation required',
            'TIN from IRD after registration',
          ],
        },
        {
          'id': '4',
          'type': 'public_limited_company',
          'display_name': 'Public Limited Company',
          'description':
              'Public limited company registered through eROC system',
          'required_documents': [
            'form_1_company_registration',
            'form_18_director_consent',
            'form_19_secretary_consent',
            'articles_of_association',
            'directors_shareholders_id_copies',
          ],
          'estimated_processing_days': 21,
          'base_fee': 25000.00,
          'registration_office': 'Department of Registrar of Companies (eROC)',
          'additional_requirements': [
            'Company name reservation required',
            'Public notice of incorporation',
            'TIN from IRD after registration',
          ],
        },
      ];
    }
  }

  static Future<bool> createBusinessRegistration(
    Map<String, dynamic> registrationData,
  ) async {
    try {
      final String? userId = SupabaseConfig.userId;
      if (userId == null) return false;

      // First create the business record
      final businessResponse = await _client
          .from('businesses')
          .insert({
            'owner_id': userId,
            'business_name': registrationData['business_name'],
            'business_type': registrationData['business_type'],
            'business_type_id': registrationData['business_type_id'],
            'proposed_trade_name': registrationData['proposed_trade_name'],
            'nature_of_business': registrationData['nature_of_business'],
            'business_address': registrationData['business_address'],
            'business_details': registrationData['business_details'],
            'status': registrationData['status'],
          })
          .select()
          .single();

      final businessId = businessResponse['id'];

      // Create the application record
      await _client.from('business_applications').insert({
        'business_id': businessId,
        'applicant_id': userId,
        'status': 'submitted',
        'current_step': 'document_review',
        'total_steps': 5,
        'completed_steps': 5,
        'submitted_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error creating business registration: $e');
      return false;
    }
  }
}
