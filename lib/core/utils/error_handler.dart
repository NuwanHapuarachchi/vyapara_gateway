import 'package:flutter/material.dart';

/// Centralized error handling utilities
class ErrorHandler {
  /// Show user-friendly error message
  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show success message
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show warning message
  static void showWarning(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Convert technical errors to user-friendly messages
  static String getHumanReadableError(String error) {
    final errorLower = error.toLowerCase();

    // Network-related errors
    if (errorLower.contains('socketexception') ||
        errorLower.contains('failed host lookup') ||
        errorLower.contains('no address associated with hostname') ||
        errorLower.contains('clientexception')) {
      return 'Unable to connect to server. Please check your internet connection and try again.';
    }

    if (errorLower.contains('timeout') || errorLower.contains('timed out')) {
      return 'Connection timed out. Please check your internet connection and try again.';
    }

    if (errorLower.contains('network is unreachable')) {
      return 'Network is unreachable. Please check your internet connection.';
    }

    // Authentication errors
    if (errorLower.contains('invalid login credentials')) {
      return 'Invalid email or password. Please check your credentials and try again.';
    }

    if (errorLower.contains('email not confirmed')) {
      return 'Please verify your email address before logging in.';
    }

    if (errorLower.contains('user not found')) {
      return 'No account found with this email address.';
    }

    if (errorLower.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }

    if (errorLower.contains('email already registered') ||
        errorLower.contains('user already registered')) {
      return 'An account with this email address already exists.';
    }

    if (errorLower.contains(
          'duplicate key value violates unique constraint "user_profiles_nic_key"',
        ) ||
        errorLower.contains('nic_key') ||
        errorLower.contains('nic already registered')) {
      return 'NIC number is already registered. Please use a different NIC or contact support.';
    }

    if (errorLower.contains('weak password')) {
      return 'Password is too weak. Please choose a stronger password.';
    }

    // Database/Storage errors
    if (errorLower.contains('permission denied') ||
        errorLower.contains('insufficient permissions')) {
      return 'You don\'t have permission to perform this action.';
    }

    if (errorLower.contains('bucket') && errorLower.contains('not found')) {
      return 'Storage service temporarily unavailable. Please try again later.';
    }

    if (errorLower.contains('file too large')) {
      return 'File size is too large. Please choose a smaller file.';
    }

    // Generic cleanup
    String cleanedError = error
        .replaceAll('Exception: ', '')
        .replaceAll('AuthException: ', '')
        .replaceAll('StorageException: ', '')
        .replaceAll('PostgrestException: ', '');

    // If it's still a technical error, provide a generic message
    if (cleanedError.contains('Error:') ||
        cleanedError.contains('Exception') ||
        cleanedError.length > 100) {
      return 'Something went wrong. Please try again or contact support if the problem persists.';
    }

    return cleanedError;
  }

  /// Check if error is network-related
  static bool isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socketexception') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('no address associated with hostname') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('connection refused') ||
        errorString.contains('timeout') ||
        errorString.contains('clientexception');
  }
}
