import 'dart:typed_data';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

/// Service for Supabase operations with enhanced error handling
class SupabaseService {
  static SupabaseClient get _client => SupabaseConfig.client;

  /// Check if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Retry mechanism for network operations
  static Future<T> _retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) rethrow;

        // Check if it's a network-related error
        if (_isNetworkError(e)) {
          print('Network error (attempt $attempts/$maxRetries): $e');
          await Future.delayed(delay * attempts); // Exponential backoff
        } else {
          rethrow; // Non-network errors should not be retried
        }
      }
    }
    throw Exception('Operation failed after $maxRetries attempts');
  }

  /// Check if error is network-related
  static bool _isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socketexception') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('no address associated with hostname') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('connection refused') ||
        errorString.contains('timeout') ||
        errorString.contains('clientexception');
  }

  /// Enhanced error handling wrapper
  static Future<T?> _safeOperation<T>(
    Future<T> Function() operation, {
    T? fallback,
    String? operationName,
  }) async {
    try {
      // Check internet connectivity first
      if (!await hasInternetConnection()) {
        print('${operationName ?? 'Operation'} failed: No internet connection');
        return fallback;
      }

      return await _retryOperation(operation);
    } catch (e) {
      print('${operationName ?? 'Operation'} failed: $e');

      if (_isNetworkError(e)) {
        print(
          'Network connectivity issue detected. Using fallback data if available.',
        );
      }

      return fallback;
    }
  }

  /// Test database connection
  static Future<bool> testConnection() async {
    final result = await _safeOperation<bool>(
      () async {
        await _client.from('business_types').select('count');
        return true;
      },
      fallback: false,
      operationName: 'Database connection test',
    );
    return result ?? false;
  }

  /// =============================
  /// Notifications
  /// =============================
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final String? userId = SupabaseConfig.userId;
    if (userId == null) return [];

    // Fallback data for offline mode
    final fallbackNotifications = [
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
        'body': 'Please upload your tax certificate to complete your profile.',
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
      {
        'id': '4',
        'title': 'Network Connection',
        'body': 'You are currently offline. Some features may be limited.',
        'read_at': null,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    final result = await _safeOperation<List<Map<String, dynamic>>>(
      () async {
        final response = await _client
            .from('notifications')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', ascending: false);
        return List<Map<String, dynamic>>.from(response);
      },
      fallback: fallbackNotifications,
      operationName: 'Fetch notifications',
    );

    return result ?? fallbackNotifications;
  }

  /// Mark notification as read
  static Future<void> markNotificationRead(String id) async {
    await _safeOperation<void>(() async {
      await _client
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    }, operationName: 'Mark notification as read');
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

  /// Get all events for the current user
  static Future<List<Map<String, dynamic>>> getAllEvents() async {
    try {
      final String? userId = SupabaseConfig.userId;
      if (userId == null) return [];

      final response = await _client
          .from('events')
          .select('*')
          .eq('user_id', userId)
          .order('start_at');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching all events: $e');
      return [];
    }
  }

  /// Get upcoming events for the current user
  static Future<List<Map<String, dynamic>>> getUpcomingEvents() async {
    try {
      final String? userId = SupabaseConfig.userId;
      if (userId == null) return [];

      final response = await _client
          .from('events')
          .select('*')
          .eq('user_id', userId)
          .gte('start_at', DateTime.now().toIso8601String())
          .order('start_at')
          .limit(10);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching upcoming events: $e');
      // Return sample events if table doesn't exist
      return [
        {
          'id': '1',
          'title': 'Business Registration Appointment',
          'description': 'Complete business registration process',
          'event_type': 'appointment',
          'start_at': DateTime.now()
              .add(const Duration(days: 2))
              .toIso8601String(),
          'color': '#10B981',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'title': 'Tax Consultation',
          'description': 'Meet with tax advisor for annual planning',
          'event_type': 'meeting',
          'start_at': DateTime.now()
              .add(const Duration(days: 5))
              .toIso8601String(),
          'color': '#3B82F6',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '3',
          'title': 'License Renewal Deadline',
          'description': 'Business license renewal due',
          'event_type': 'deadline',
          'start_at': DateTime.now()
              .add(const Duration(days: 10))
              .toIso8601String(),
          'color': '#EF4444',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ];
    }
  }

  /// Get events for a specific date
  static Future<List<Map<String, dynamic>>> getEventsForDate(
    DateTime date,
  ) async {
    try {
      final String? userId = SupabaseConfig.userId;
      if (userId == null) return [];

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _client
          .from('events')
          .select('*')
          .eq('user_id', userId)
          .gte('start_at', startOfDay.toIso8601String())
          .lt('start_at', endOfDay.toIso8601String())
          .order('start_at');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching events for date: $e');
      return [];
    }
  }

  /// Create a new event
  static Future<Map<String, dynamic>?> createEvent(
    Map<String, dynamic> eventData,
  ) async {
    try {
      final String? userId = SupabaseConfig.userId;
      if (userId == null) return null;

      final data = {
        ...eventData,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('events')
          .insert(data)
          .select()
          .single();

      print('Event created successfully: ${response['id']}');
      return response;
    } catch (e) {
      print('Error creating event: $e');
      return null;
    }
  }

  /// Update an existing event
  static Future<Map<String, dynamic>?> updateEvent(
    String eventId,
    Map<String, dynamic> eventData,
  ) async {
    try {
      final data = {
        ...eventData,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('events')
          .update(data)
          .eq('id', eventId)
          .select()
          .single();

      print('Event updated successfully: $eventId');
      return response;
    } catch (e) {
      print('Error updating event: $e');
      return null;
    }
  }

  /// Delete an event
  static Future<bool> deleteEvent(String eventId) async {
    try {
      await _client.from('events').delete().eq('id', eventId);

      print('Event deleted successfully: $eventId');
      return true;
    } catch (e) {
      print('Error deleting event: $e');
      return false;
    }
  }

  /// Get event by ID
  static Future<Map<String, dynamic>?> getEventById(String eventId) async {
    try {
      final response = await _client
          .from('events')
          .select('*')
          .eq('id', eventId)
          .single();
      return response;
    } catch (e) {
      print('Error fetching event by ID: $e');
      return null;
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

  /// Clean up orphaned auth users (users without profiles)
  static Future<void> cleanupOrphanedUsers() async {
    try {
      // This would require admin privileges, so we'll just log the issue
      print(
        'Warning: Orphaned auth users detected. Manual cleanup may be required.',
      );
      print(
        'Check Supabase Dashboard > Authentication > Users for users without profiles.',
      );
    } catch (e) {
      print('Error during cleanup: $e');
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
