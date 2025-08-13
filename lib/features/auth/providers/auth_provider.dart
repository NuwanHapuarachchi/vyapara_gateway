import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/models/user_model.dart';

/// Authentication state notifier using Supabase
class AuthNotifier extends AsyncNotifier<UserProfile?> {
  SupabaseClient get _supabase => SupabaseConfig.client;

  @override
  Future<UserProfile?> build() async {
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;

      if (event == AuthChangeEvent.signedIn) {
        _loadUserProfile();
      } else if (event == AuthChangeEvent.signedOut) {
        state = const AsyncValue.data(null);
      }
    });

    return await _checkAuthStatus();
  }

  /// Check if user is already authenticated
  Future<UserProfile?> _checkAuthStatus() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session?.user != null) {
        return await _loadUserProfile();
      }
      return null;
    } catch (e) {
      print('Auth check failed: $e');
      return null;
    }
  }

  /// Load user profile from database
  Future<UserProfile?> _loadUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        print('No user profile found for user $userId');
        return null;
      }

      final userProfile = UserProfile.fromJson(response);
      state = AsyncValue.data(userProfile);
      return userProfile;
    } catch (e) {
      print('Failed to load user profile: $e');
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile();
      } else {
        throw Exception('Login failed: No user returned');
      }
    } on AuthException catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error('Login failed: $e', StackTrace.current);
    }
  }

  /// Sign up with user details
  Future<void> signup({
    required String fullName,
    required String email,
    required String phone,
    required String nic,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      print('Starting signup process for email: $email');

      // Check if NIC already exists (temporarily disabled to avoid RLS issues)
      // TODO: Re-enable NIC checking once RLS policies are properly configured
      // final existingNic = await _supabase
      //     .from('user_profiles')
      //     .select('nic')
      //     .eq('nic', nic)
      //     .maybeSingle();
      //
      // if (existingNic != null) {
      //   throw Exception('NIC already registered');
      // }

      // Create auth user
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Failed to create user account');
      }

      final userId = response.user!.id;

      // Create user profile with better error handling
      print('Creating user profile for ID: $userId');

      final profileData = {
        'id': userId,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'nic': nic,
        'role': UserRole.businessOwner.value,
        'is_email_verified': response.user!.emailConfirmedAt != null,
        'is_nic_verified': false,
        'is_phone_verified': false,
      };

      try {
        final insertResponse = await _supabase
            .from('user_profiles')
            .insert(profileData)
            .select()
            .maybeSingle();

        if (insertResponse != null) {
          print('User profile created successfully');
          final userProfile = UserProfile.fromJson(insertResponse);
          state = AsyncValue.data(userProfile);
        } else {
          print(
            'Profile insert returned null, trying to load existing profile',
          );
          await _loadUserProfile();
        }
      } catch (profileError) {
        print('Profile creation error: $profileError');
        // Try to load existing profile in case it was created by trigger
        await _loadUserProfile();
      }
    } on AuthException catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error('Signup failed: $e', StackTrace.current);
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Update user profile
  Future<void> updateProfile(UserProfile updatedUser) async {
    try {
      await _supabase
          .from('user_profiles')
          .update(updatedUser.toJson())
          .eq('id', updatedUser.id);

      state = AsyncValue.data(updatedUser);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Send email verification
  Future<void> resendEmailVerification() async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: _supabase.auth.currentUser?.email,
      );
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }
}

/// Auth provider
final authProvider = AsyncNotifierProvider<AuthNotifier, UserProfile?>(() {
  return AuthNotifier();
});

/// Current user provider (convenience)
final currentUserProvider = Provider<UserProfile?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.asData?.value;
});

/// Check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.asData?.value != null;
});

/// Authentication status provider
final authStatusProvider = Provider<AuthStatus>((ref) {
  final authState = ref.watch(authProvider);

  return authState.when(
    loading: () => AuthStatus.loading,
    error: (_, __) => AuthStatus.error,
    data: (user) =>
        user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
  );
});
