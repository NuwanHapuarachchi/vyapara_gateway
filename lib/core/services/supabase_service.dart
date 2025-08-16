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
      // Try multiple methods for better reliability in release builds

      // Method 1: Try DNS lookup
      try {
        final result = await InternetAddress.lookup(
          'google.com',
        ).timeout(const Duration(seconds: 5));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
      } catch (e) {
        print('DNS lookup failed: $e');
      }

      // Method 2: Try HTTP request to a reliable endpoint
      try {
        final httpClient = HttpClient();
        httpClient.connectionTimeout = const Duration(seconds: 5);
        final request = await httpClient.getUrl(
          Uri.parse('https://www.google.com'),
        );
        final response = await request.close().timeout(
          const Duration(seconds: 5),
        );
        httpClient.close();
        return response.statusCode == 200;
      } catch (e) {
        print('HTTP connectivity check failed: $e');
      }

      // Method 3: Try connecting to Supabase directly
      try {
        final httpClient = HttpClient();
        httpClient.connectionTimeout = const Duration(seconds: 5);
        final request = await httpClient.getUrl(
          Uri.parse('https://iqihgblzxtwjguyvohny.supabase.co/rest/v1/'),
        );
        final response = await request.close().timeout(
          const Duration(seconds: 5),
        );
        httpClient.close();
        return response.statusCode == 200 ||
            response.statusCode == 401; // 401 is expected without auth
      } catch (e) {
        print('Supabase connectivity check failed: $e');
      }

      return false;
    } catch (e) {
      print('General connectivity check failed: $e');
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
  static const String _nicBucket = 'nic';

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

  /// List documents for a specific applicant folder (by user id)
  static Future<List<FileObject>> listDocumentsForApplicant(
    String applicantId,
  ) async {
    try {
      final String folder = '$applicantId/';
      print('Listing documents for applicant: $applicantId');
      final results = await _client.storage
          .from(_documentsBucket)
          .list(path: folder, searchOptions: const SearchOptions());
      print('Found ${results.length} files for applicant $applicantId');
      return results;
    } catch (e) {
      print('Error listing documents for $applicantId: $e');
      return [];
    }
  }

  /// Recursively count files for an applicant's folder
  static Future<int> countDocumentsForApplicantRecursive(
    String applicantId,
  ) async {
    try {
      return await _countFilesInPath('$applicantId/');
    } catch (e) {
      print('Error counting documents for $applicantId: $e');
      return 0;
    }
  }

  /// Prefer counting inside applicantId/applicationNumber/ if present,
  /// otherwise fall back to applicantId/ root
  static Future<int> countDocumentsForApplication(
    String applicantId,
    String? applicationNumber,
  ) async {
    try {
      if (applicationNumber != null && applicationNumber.isNotEmpty) {
        final byApp = await _countFilesInPath(
          '$applicantId/$applicationNumber/',
        );
        if (byApp > 0) return byApp;
      }
      return await countDocumentsForApplicantRecursive(applicantId);
    } catch (e) {
      print('Error counting docs for $applicantId/$applicationNumber: $e');
      return 0;
    }
  }

  static Future<int> _countFilesInPath(String path, {int depth = 0}) async {
    // Guard against excessive recursion
    if (depth > 5) return 0;

    try {
      print('Listing files at path: $path in bucket: $_documentsBucket');
      final items = await _client.storage
          .from(_documentsBucket)
          .list(path: path, searchOptions: const SearchOptions());

      print('Found ${items.length} items at path: $path');
      for (final item in items) {
        print('  - ${item.name}');
      }

      // For our structure, listing the applicant folder returns the files directly
      return items.length;
    } catch (e) {
      print('Error listing files at path $path: $e');
      return 0;
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

  /// =============================
  /// NIC Storage (bucket: 'nic')
  /// =============================
  static Future<String?> uploadNicBytes({
    required Uint8List data,
    required String fileName,
    String contentType = 'application/octet-stream',
  }) async {
    try {
      final String? userId = SupabaseConfig.userId;
      if (userId == null) {
        print('NIC upload failed: User not authenticated');
        return null;
      }

      final String path = '$userId/$fileName';
      await _client.storage
          .from(_nicBucket)
          .uploadBinary(
            path,
            data,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );

      // Optionally return a public URL if bucket is public
      final publicUrl = _client.storage.from(_nicBucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('Error uploading NIC bytes: $e');
      return null;
    }
  }

  static Future<List<FileObject>> listNicFilesForUser(String userId) async {
    try {
      return await _client.storage
          .from(_nicBucket)
          .list(path: '$userId/', searchOptions: const SearchOptions());
    } catch (e) {
      print('Error listing NIC files: $e');
      return [];
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
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching payments: $e');
      // Do not show dummy values; surface no data on failure
      return [];
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
  /// Service Providers (Mentors & Lawyers)
  /// =============================
  static Future<List<Map<String, dynamic>>> getProviders({
    required UserRole providerType,
    bool onlyVerified = true,
  }) async {
    try {
      dynamic query = _client
          .from('service_providers')
          .select(
            'id, user_id, provider_type, specialization, experience_years, qualification, license_number, hourly_rate, bio, rating, total_reviews, is_verified, is_available, user:user_profiles(full_name, profile_image_url)',
          )
          .eq('provider_type', providerType.value);

      if (onlyVerified) {
        query = query.eq('is_verified', true);
      }

      final response = await query.order('rating', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching providers: $e');
      return [];
    }
  }

  /// Public listing by role from user_profiles (fallback when provider table is empty)
  static Future<List<Map<String, dynamic>>> getUsersByRole(
    UserRole role,
  ) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select('id, full_name, profile_image_url, role')
          .eq('role', role.value)
          .order('full_name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching users by role: $e');
      return [];
    }
  }

  static Future<bool> applyAsProvider({
    required UserRole providerType,
    List<String>? specialization,
    int? experienceYears,
    String? qualification,
    String? licenseNumber,
    double? hourlyRate,
    String? bio,
    Map<String, dynamic>? verificationDocuments,
  }) async {
    try {
      final String? userId = SupabaseConfig.userId;
      if (userId == null) return false;

      await _client.from('service_providers').insert({
        'user_id': userId,
        'provider_type': providerType.value,
        'specialization': specialization ?? [],
        'experience_years': experienceYears,
        'qualification': qualification,
        'license_number': licenseNumber,
        'hourly_rate': hourlyRate,
        'bio': bio,
        'verification_documents': verificationDocuments,
        'is_verified': false,
        'is_available': false,
      });
      return true;
    } catch (e) {
      print('Error applying as provider: $e');
      return false;
    }
  }

  static Future<bool> verifyProvider({
    required String providerId,
    required bool isVerified,
    bool updateUserRole = true,
  }) async {
    try {
      // Update provider verification status
      final provider = await _client
          .from('service_providers')
          .update({
            'is_verified': isVerified,
            'is_available': isVerified,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', providerId)
          .select('user_id, provider_type')
          .single();

      if (updateUserRole && isVerified) {
        final String targetRole = provider['provider_type'] as String;
        final String targetUserId = provider['user_id'] as String;
        await _client
            .from('user_profiles')
            .update({
              'role': targetRole,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', targetUserId);
      }
      return true;
    } catch (e) {
      print('Error verifying provider: $e');
      return false;
    }
  }

  /// Availability Slots
  static Future<List<Map<String, dynamic>>> getAvailabilitySlots(
    String providerId,
  ) async {
    try {
      final response = await _client
          .from('availability_slots')
          .select('*')
          .eq('provider_id', providerId)
          .order('day_of_week');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching availability slots: $e');
      return [];
    }
  }

  static Future<bool> upsertAvailabilitySlots({
    required String providerId,
    required List<Map<String, dynamic>> slots,
  }) async {
    try {
      // Upsert by replacing existing slots for simplicity
      await _client
          .from('availability_slots')
          .delete()
          .eq('provider_id', providerId);
      if (slots.isNotEmpty) {
        final data = slots
            .map(
              (s) => {
                'provider_id': providerId,
                'day_of_week': s['day_of_week'],
                'start_time': s['start_time'],
                'end_time': s['end_time'],
                'is_available': s['is_available'] ?? true,
              },
            )
            .toList();
        await _client.from('availability_slots').insert(data);
      }
      return true;
    } catch (e) {
      print('Error upserting availability slots: $e');
      return false;
    }
  }

  /// =============================
  /// Direct Chat (user <-> provider) using chat_sessions/chat_messages
  /// =============================
  static Future<Map<String, dynamic>?> getOrCreateDirectChatSession(
    String otherUserId, {
    String? sessionTitle,
  }) async {
    try {
      final String? currentUserId = SupabaseConfig.userId;
      if (currentUserId == null) return null;

      // Find existing session between the two users (either direction)
      final existing = await _client
          .from('chat_sessions')
          .select('*')
          .or(
            'and(user_id.eq.$currentUserId,participant_id.eq.$otherUserId),and(user_id.eq.$otherUserId,participant_id.eq.$currentUserId)',
          )
          .maybeSingle();

      if (existing != null) return existing;

      final created = await _client
          .from('chat_sessions')
          .insert({
            'user_id': currentUserId,
            'participant_id': otherUserId,
            'session_title': sessionTitle,
            'last_message_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      return created;
    } catch (e) {
      print('Error getting/creating chat session: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getSessionMessages(
    String sessionId,
  ) async {
    try {
      final response = await _client
          .from('chat_messages')
          .select('*')
          .eq('session_id', sessionId)
          .order('created_at');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching session messages: $e');
      return [];
    }
  }

  static Future<bool> sendSessionMessage({
    required String sessionId,
    required String content,
  }) async {
    try {
      final String? currentUserId = SupabaseConfig.userId;
      if (currentUserId == null) return false;

      await _client.from('chat_messages').insert({
        'session_id': sessionId,
        'message_type': 'user',
        'content': content,
        'metadata': {'sender_id': currentUserId},
      });

      await _client
          .from('chat_sessions')
          .update({'last_message_at': DateTime.now().toIso8601String()})
          .eq('id', sessionId);
      return true;
    } catch (e) {
      print('Error sending session message: $e');
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

  /// Upload NIC document and update user profile
  static Future<bool> uploadNicDocument({
    required String userId,
    required Uint8List documentData,
    required String fileName,
    String contentType = 'image/jpeg',
  }) async {
    try {
      // Upload document to storage
      final documentUrl = await uploadDocumentBytes(
        data: documentData,
        fileName: fileName,
        contentType: contentType,
      );

      if (documentUrl == null) {
        throw Exception('Failed to upload document');
      }

      // Update user profile with document information
      final updatedUser = await updateUserProfile(userId, {
        'nic_document_url': documentUrl,
        'nic_uploaded_at': DateTime.now().toIso8601String(),
        'nic_verification_status': 'pending',
      });

      return updatedUser != null;
    } catch (e) {
      print('Error uploading NIC document: $e');
      return false;
    }
  }

  /// Get NIC document verification status
  static Future<String?> getNicVerificationStatus(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select('nic_verification_status')
          .eq('id', userId)
          .maybeSingle();

      return response?['nic_verification_status'] as String?;
    } catch (e) {
      print('Error getting NIC verification status: $e');
      return null;
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
          'district': 'Colombo',
          'is_valid': true,
        },
        '987654321V': {
          'nic': '987654321V',
          'full_name': 'Jane Silva',
          'date_of_birth': '1985-12-20',
          'gender': 'Female',
          'district': 'Kandy',
          'is_valid': true,
        },
        '555666777V': {
          'nic': '555666777V',
          'full_name': 'Ravi Fernando',
          'date_of_birth': '1992-08-10',
          'gender': 'Male',
          'district': 'Gampaha',
          'is_valid': true,
        },
      };

      return sampleNics[nic];
    }
  }

  /// Add NIC to validation data table during signup
  static Future<bool> addNicToValidationData({
    required String nic,
    required String fullName,
    String? dateOfBirth,
    String? gender,
    String? district,
  }) async {
    try {
      // Check if NIC already exists
      final existingNic = await _client
          .from('nic_validation_data')
          .select('nic')
          .eq('nic', nic)
          .maybeSingle();

      if (existingNic != null) {
        print('NIC $nic already exists in validation data');
        return true; // Already exists, consider it successful
      }

      // Extract info from NIC if not provided
      final nicInfo = _extractInfoFromNic(nic);

      // Add new NIC to validation data
      await _client.from('nic_validation_data').insert({
        'nic': nic,
        'full_name': fullName,
        'date_of_birth': dateOfBirth ?? nicInfo['dateOfBirth'] ?? '1990-01-01',
        'gender': gender ?? nicInfo['gender'] ?? 'Not Specified',
        'district': district ?? 'Unknown',
        'is_valid': true,
      });

      print('Successfully added NIC $nic to validation data');
      return true;
    } catch (e) {
      print('Error adding NIC to validation data: $e');
      return false;
    }
  }

  /// Extract basic info from Sri Lankan NIC number
  static Map<String, String?> _extractInfoFromNic(String nic) {
    try {
      if (nic.length == 10 && nic.endsWith('V')) {
        // Old format: 123456789V
        final yearPart = int.parse(nic.substring(0, 2));
        final daysPart = int.parse(nic.substring(2, 5));

        // Determine year (assuming current century for years 00-30, previous for 31-99)
        final currentYear = DateTime.now().year;
        final currentCentury = (currentYear ~/ 100) * 100;
        final year = yearPart <= 30
            ? currentCentury + yearPart
            : currentCentury - 100 + yearPart;

        // Determine gender and day of year
        final isWoman = daysPart > 500;
        final actualDayOfYear = isWoman ? daysPart - 500 : daysPart;

        // Calculate approximate date (this is a simplified calculation)
        final dateOfBirth = DateTime(
          year,
          1,
          1,
        ).add(Duration(days: actualDayOfYear - 1));

        return {
          'dateOfBirth':
              '${dateOfBirth.year}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}',
          'gender': isWoman ? 'Female' : 'Male',
        };
      } else if (nic.length == 12) {
        // New format: 200015501234
        final year = int.parse(nic.substring(0, 4));
        final daysPart = int.parse(nic.substring(4, 7));

        final isWoman = daysPart > 500;
        final actualDayOfYear = isWoman ? daysPart - 500 : daysPart;

        final dateOfBirth = DateTime(
          year,
          1,
          1,
        ).add(Duration(days: actualDayOfYear - 1));

        return {
          'dateOfBirth':
              '${dateOfBirth.year}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}',
          'gender': isWoman ? 'Female' : 'Male',
        };
      }
    } catch (e) {
      print('Error extracting info from NIC $nic: $e');
    }

    return {'dateOfBirth': null, 'gender': null};
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
      final applicationResponse = await _client
          .from('business_applications')
          .insert({
            'business_id': businessId,
            'applicant_id': userId,
            'status': 'submitted',
            'current_step': 'document_review',
            'total_steps': 5,
            'completed_steps': 5,
            'submitted_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final applicationId = applicationResponse['id'];

      // Register uploaded documents in application_documents table
      final uploadedDocuments =
          registrationData['business_details']?['uploaded_documents']
              as Map<String, dynamic>?;
      if (uploadedDocuments != null && uploadedDocuments.isNotEmpty) {
        print(
          'Registering ${uploadedDocuments.length} documents for application $applicationId',
        );

        final documentPaths = uploadedDocuments.values.cast<String>().toList();
        await registerApplicationDocuments(applicationId, documentPaths);
      }

      return true;
    } catch (e) {
      print('Error creating business registration: $e');
      return false;
    }
  }

  /// =============================
  /// Applications (Business Applications for current user)
  /// =============================
  static Future<List<Map<String, dynamic>>> getUserApplications() async {
    try {
      final String? userId = SupabaseConfig.userId;
      print('Getting applications for user: $userId');
      if (userId == null) {
        print('No user ID found');
        return [];
      }

      // Fetch business applications for the authenticated user
      print('Querying business_applications table...');
      final response = await _client
          .from('business_applications')
          .select(
            'id, application_number, status, submitted_at, completed_steps, total_steps, rejection_reason, estimated_completion_date, applicant_id',
          )
          .eq('applicant_id', userId)
          .order('submitted_at', ascending: false);

      print('Found ${response.length} applications in database');
      for (final app in response) {
        print(
          '  - ${app['application_number']}: ${app['status']} (applicant: ${app['applicant_id']})',
        );
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching user applications: $e');
      return [];
    }
  }

  /// =============================
  /// Document Status Tracking
  /// =============================

  /// Register documents when they are uploaded to an application
  static Future<bool> registerApplicationDocuments(
    String applicationId,
    List<String> documentPaths,
  ) async {
    try {
      print(
        'Registering ${documentPaths.length} documents for application $applicationId',
      );
      print('Document paths: ${documentPaths.join(', ')}');

      final documentsData = documentPaths
          .map(
            (path) => {
              'application_id': applicationId,
              'document_name': path.split('/').last,
              'document_path': path,
              'document_type': _inferDocumentType(path),
              'status': 'submitted',
            },
          )
          .toList();

      print('Documents to insert: ${documentsData.length}');
      for (final doc in documentsData) {
        print('  - ${doc['document_name']} (${doc['document_type']})');
      }

      await _client.from('application_documents').insert(documentsData);

      print(
        'Successfully registered ${documentsData.length} documents for application $applicationId',
      );
      return true;
    } catch (e) {
      print('Error registering documents: $e');
      return false;
    }
  }

  /// Get document status summary for an application
  static Future<Map<String, dynamic>> getApplicationDocumentSummary(
    String applicationId,
  ) async {
    try {
      print('Getting document summary for application: $applicationId');
      final response = await _client
          .from('application_documents')
          .select('status, rejection_reason')
          .eq('application_id', applicationId);

      final documents = List<Map<String, dynamic>>.from(response);
      print(
        'Found ${documents.length} documents in application_documents table for $applicationId',
      );

      if (documents.isEmpty) {
        print(
          'No documents found for application $applicationId, returning empty summary',
        );
        return {
          'overall_status': 'submitted',
          'progress': 0,
          'approved_docs': 0,
          'rejected_docs': 0,
          'pending_docs': 0,
          'total_docs': 0,
          'has_rejections': false,
          'rejection_reasons': <String>[],
        };
      }

      final approved = documents.where((d) => d['status'] == 'approved').length;
      final rejected = documents.where((d) => d['status'] == 'rejected').length;
      final underReview = documents
          .where((d) => d['status'] == 'under_review')
          .length;
      final submitted = documents
          .where((d) => d['status'] == 'submitted')
          .length;
      final total = documents.length;

      // Calculate overall status
      String overallStatus;
      if (rejected > 0) {
        overallStatus = 'rejected';
      } else if (approved == total) {
        overallStatus = 'approved';
      } else if (underReview > 0 || submitted > 0) {
        overallStatus = 'document_review';
      } else {
        overallStatus = 'submitted';
      }

      // Calculate progress percentage
      final progress = total > 0 ? ((approved / total) * 100).round() : 0;

      // Get rejection reasons
      final rejectionReasons = documents
          .where(
            (d) => d['status'] == 'rejected' && d['rejection_reason'] != null,
          )
          .map((d) => d['rejection_reason'] as String)
          .toList();

      return {
        'overall_status': overallStatus,
        'progress': progress,
        'approved_docs': approved,
        'rejected_docs': rejected,
        'pending_docs': submitted + underReview,
        'total_docs': total,
        'has_rejections': rejected > 0,
        'rejection_reasons': rejectionReasons,
      };
    } catch (e) {
      print('Error getting application document summary: $e');
      return {
        'overall_status': 'submitted',
        'progress': 0,
        'approved_docs': 0,
        'rejected_docs': 0,
        'pending_docs': 0,
        'total_docs': 0,
        'has_rejections': false,
        'rejection_reasons': <String>[],
      };
    }
  }

  /// Get detailed document list for an application (for detailed view)
  static Future<List<Map<String, dynamic>>> getApplicationDocuments(
    String applicationId,
  ) async {
    try {
      final response = await _client
          .from('application_documents')
          .select('*')
          .eq('application_id', applicationId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting application documents: $e');
      return [];
    }
  }

  /// Helper method to infer document type from file name
  static String _inferDocumentType(String path) {
    final fileName = path.toLowerCase();

    // Sri Lankan business registration specific document types
    if (fileName.contains('application_form') || fileName.contains('form_1')) {
      return 'registration_form';
    } else if (fileName.contains('grama_niladhari') ||
        fileName.contains('certified_report')) {
      return 'grama_niladhari_report';
    } else if (fileName.contains('nic_copy') || fileName.contains('id_copy')) {
      return 'identification';
    } else if (fileName.contains('premises_proof') ||
        fileName.contains('business_premises')) {
      return 'business_premises';
    } else if (fileName.contains('trade_permit') ||
        fileName.contains('municipal')) {
      return 'trade_permit';
    } else if (fileName.contains('partnership_agreement') ||
        fileName.contains('partners')) {
      return 'partnership_agreement';
    } else if (fileName.contains('form_18') ||
        fileName.contains('director_consent')) {
      return 'director_consent';
    } else if (fileName.contains('form_19') ||
        fileName.contains('secretary_consent')) {
      return 'secretary_consent';
    } else if (fileName.contains('articles_of_association') ||
        fileName.contains('articles')) {
      return 'articles_of_association';
    } else if (fileName.contains('directors') ||
        fileName.contains('shareholders')) {
      return 'director_shareholder_id';
    } else if (fileName.contains('address') || fileName.contains('proof')) {
      return 'proof_of_address';
    }
    return 'other';
  }

  /// Update getUserApplications to include document status
  static Future<List<Map<String, dynamic>>>
  getUserApplicationsWithStatus() async {
    try {
      final String? userId = SupabaseConfig.userId;
      print('Getting applications with status for user: $userId');
      if (userId == null) {
        print('No user ID found');
        return [];
      }

      // Fetch business applications for the authenticated user
      print('Querying business_applications table...');
      final response = await _client
          .from('business_applications')
          .select(
            'id, application_number, status, submitted_at, completed_steps, total_steps, rejection_reason, estimated_completion_date, applicant_id',
          )
          .eq('applicant_id', userId)
          .order('submitted_at', ascending: false);

      print('Found ${response.length} applications in database');

      // Enhance each application with document status
      final enhancedApplications = <Map<String, dynamic>>[];

      for (final app in response) {
        final applicationId = app['id'].toString();
        final docSummary = await getApplicationDocumentSummary(applicationId);

        // Create enhanced application data
        final enhancedApp = Map<String, dynamic>.from(app);
        enhancedApp['document_summary'] = docSummary;

        // Override status if document review reveals different status
        if (docSummary['overall_status'] != 'submitted') {
          enhancedApp['calculated_status'] = docSummary['overall_status'];
        }

        enhancedApplications.add(enhancedApp);

        print(
          '  - ${app['application_number']}: ${enhancedApp['calculated_status'] ?? app['status']} '
          '(${docSummary['approved_docs']}/${docSummary['total_docs']} docs approved)',
        );
      }

      return enhancedApplications;
    } catch (e) {
      print('Error fetching user applications with status: $e');
      return getUserApplications(); // Fallback to original method
    }
  }

  /// =============================
  /// Admin/Testing Methods
  /// =============================

  /// For testing: Create sample document records for an existing application
  static Future<bool> createSampleDocumentRecords(String applicationId) async {
    try {
      final sampleDocs = [
        {
          'application_id': applicationId,
          'document_name': 'business_registration_form.pdf',
          'document_path': 'user_folder/business_registration_form.pdf',
          'document_type': 'registration_form',
          'status': 'approved',
        },
        {
          'application_id': applicationId,
          'document_name': 'proof_of_address.pdf',
          'document_path': 'user_folder/proof_of_address.pdf',
          'document_type': 'proof_of_address',
          'status': 'under_review',
        },
        {
          'application_id': applicationId,
          'document_name': 'nic_copy.pdf',
          'document_path': 'user_folder/nic_copy.pdf',
          'document_type': 'identification',
          'status': 'rejected',
          'rejection_reason':
              'Document is not clear, please upload a clearer copy',
        },
        {
          'application_id': applicationId,
          'document_name': 'business_premises_proof.pdf',
          'document_path': 'user_folder/business_premises_proof.pdf',
          'document_type': 'business_document',
          'status': 'submitted',
        },
        {
          'application_id': applicationId,
          'document_name': 'trade_permit_application.pdf',
          'document_path': 'user_folder/trade_permit_application.pdf',
          'document_type': 'trade_permit',
          'status': 'approved',
        },
      ];

      await _client.from('application_documents').insert(sampleDocs);

      print(
        'Created ${sampleDocs.length} sample document records for application $applicationId',
      );
      return true;
    } catch (e) {
      print('Error creating sample document records: $e');
      return false;
    }
  }

  /// For existing applications: Register documents from uploaded_documents in business_details
  static Future<bool> registerExistingApplicationDocuments(
    String applicationId,
  ) async {
    try {
      // Get the application and business details
      final appResponse = await _client
          .from('business_applications')
          .select('business_id')
          .eq('id', applicationId)
          .single();

      final businessResponse = await _client
          .from('businesses')
          .select('business_details')
          .eq('id', appResponse['business_id'])
          .single();

      final businessDetails =
          businessResponse['business_details'] as Map<String, dynamic>;
      final uploadedDocuments =
          businessDetails['uploaded_documents'] as Map<String, dynamic>?;

      print(
        'Business details for application $applicationId: ${businessDetails.keys.toList()}',
      );
      print('Uploaded documents field: $uploadedDocuments');

      if (uploadedDocuments != null && uploadedDocuments.isNotEmpty) {
        print(
          'Found ${uploadedDocuments.length} uploaded documents to register',
        );
        print('Document types and URLs: $uploadedDocuments');

        final documentPaths = uploadedDocuments.values.cast<String>().toList();
        print('Extracted document paths: $documentPaths');

        await registerApplicationDocuments(applicationId, documentPaths);

        return true;
      } else {
        print('No uploaded documents found for application $applicationId');
        print('Business details structure: ${businessDetails}');
        return false;
      }
    } catch (e) {
      print('Error registering existing application documents: $e');
      return false;
    }
  }

  /// Fix all applications that have uploaded documents but aren't registered
  static Future<void> fixAllApplicationDocuments() async {
    try {
      final String? userId = SupabaseConfig.userId;
      if (userId == null) return;

      print('Fixing document registration for all user applications...');

      // Get all user applications
      final applications = await _client
          .from('business_applications')
          .select('id, business_id')
          .eq('applicant_id', userId);

      for (final app in applications) {
        final applicationId = app['id'];
        print(
          'Checking application $applicationId for unregistered documents...',
        );

        // Check if documents are already registered
        final existingDocs = await _client
            .from('application_documents')
            .select('id')
            .eq('application_id', applicationId);

        if (existingDocs.isEmpty) {
          print(
            'No documents registered for application $applicationId, attempting to register...',
          );
          await registerExistingApplicationDocuments(applicationId);
        } else {
          print(
            'Application $applicationId already has ${existingDocs.length} documents registered',
          );
        }
      }

      print('Finished fixing document registration');
    } catch (e) {
      print('Error fixing application documents: $e');
    }
  }
}
