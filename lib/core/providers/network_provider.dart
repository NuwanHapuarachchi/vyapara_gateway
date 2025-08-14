import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';

/// Network status enum
enum NetworkStatus { unknown, checking, connected, disconnected }

/// Global network status
NetworkStatus _currentNetworkStatus = NetworkStatus.unknown;
Timer? _networkTimer;
final List<void Function(NetworkStatus)> _listeners = [];

/// Network monitoring service
class NetworkMonitor {
  static bool _isInitialized = false;

  static void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    // Check immediately
    checkConnection();

    // Then check every 30 seconds
    _networkTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      checkConnection();
    });
  }

  /// Check network connection status
  static Future<void> checkConnection() async {
    try {
      final hasConnection = await SupabaseService.hasInternetConnection();
      final newStatus = hasConnection
          ? NetworkStatus.connected
          : NetworkStatus.disconnected;

      if (newStatus != _currentNetworkStatus) {
        _currentNetworkStatus = newStatus;
        _notifyListeners();
      }
    } catch (e) {
      if (_currentNetworkStatus != NetworkStatus.disconnected) {
        _currentNetworkStatus = NetworkStatus.disconnected;
        _notifyListeners();
      }
    }
  }

  /// Force refresh network status
  static Future<void> refresh() async {
    _currentNetworkStatus = NetworkStatus.checking;
    _notifyListeners();
    await checkConnection();
  }

  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener(_currentNetworkStatus);
    }
  }

  static void addListener(void Function(NetworkStatus) listener) {
    _listeners.add(listener);
  }

  static void removeListener(void Function(NetworkStatus) listener) {
    _listeners.remove(listener);
  }

  static void dispose() {
    _networkTimer?.cancel();
    _listeners.clear();
    _isInitialized = false;
  }
}

/// Network status provider
final networkStatusProvider = Provider<NetworkStatus>((ref) {
  // Initialize monitoring
  NetworkMonitor.initialize();

  return _currentNetworkStatus;
});

/// Convenience provider to check if connected
final isConnectedProvider = Provider<bool>((ref) {
  final status = ref.watch(networkStatusProvider);
  return status == NetworkStatus.connected;
});

/// Provider to get network status message
final networkStatusMessageProvider = Provider<String?>((ref) {
  final status = ref.watch(networkStatusProvider);

  switch (status) {
    case NetworkStatus.disconnected:
      return 'No internet connection. Some features may be limited.';
    case NetworkStatus.checking:
      return 'Checking connection...';
    case NetworkStatus.connected:
    case NetworkStatus.unknown:
      return null;
  }
});

/// Provider for manual refresh
final networkRefreshProvider = Provider<void Function()>((ref) {
  return () => NetworkMonitor.refresh();
});
