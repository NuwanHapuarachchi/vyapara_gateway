import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../../core/providers/network_provider.dart';
import '../../core/utils/error_handler.dart';
import '../../shared/widgets/neumorphic_widgets.dart';

/// Screen to test network connectivity and error handling
class NetworkTestScreen extends ConsumerStatefulWidget {
  const NetworkTestScreen({super.key});

  @override
  ConsumerState<NetworkTestScreen> createState() => _NetworkTestScreenState();
}

class _NetworkTestScreenState extends ConsumerState<NetworkTestScreen> {
  bool _isTestingConnection = false;
  bool _isTestingNotifications = false;
  String? _connectionResult;
  String? _notificationsResult;

  @override
  Widget build(BuildContext context) {
    final networkStatus = ref.watch(networkStatusProvider);
    final isConnected = ref.watch(isConnectedProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Network & Error Testing',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Network Status Card
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getNetworkIcon(networkStatus),
                        color: _getNetworkColor(networkStatus),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Network Status',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Status: ${networkStatus.name}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: _getNetworkColor(networkStatus),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isConnected
                        ? 'Connected to internet'
                        : 'No internet connection detected',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: ref.read(networkRefreshProvider),
                      child: const Text('Refresh Network Status'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Connection Test Card
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Database Connection Test',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_connectionResult != null) ...[
                    Text(
                      _connectionResult!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _connectionResult!.contains('Success')
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isTestingConnection ? null : _testConnection,
                      child: _isTestingConnection
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Test Database Connection'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Notifications Test Card
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications Fetch Test',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_notificationsResult != null) ...[
                    Text(
                      _notificationsResult!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _notificationsResult!.contains('Success')
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isTestingNotifications
                          ? null
                          : _testNotifications,
                      child: _isTestingNotifications
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Test Notifications'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Error Handling Test Card
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error Handling Test',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Test different types of error messages',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () => _showTestError('Network Error'),
                        child: const Text('Network Error'),
                      ),
                      ElevatedButton(
                        onPressed: () => _showTestError('Auth Error'),
                        child: const Text('Auth Error'),
                      ),
                      ElevatedButton(
                        onPressed: () => _showTestError('Success'),
                        child: const Text('Success'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNetworkIcon(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.connected:
        return Icons.wifi;
      case NetworkStatus.disconnected:
        return Icons.wifi_off;
      case NetworkStatus.checking:
        return Icons.refresh;
      case NetworkStatus.unknown:
        return Icons.help_outline;
    }
  }

  Color _getNetworkColor(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.connected:
        return Colors.green;
      case NetworkStatus.disconnected:
        return Colors.red;
      case NetworkStatus.checking:
        return Colors.orange;
      case NetworkStatus.unknown:
        return AppColors.textSecondary;
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionResult = null;
    });

    try {
      final result = await SupabaseService.testConnection();
      setState(() {
        _connectionResult = result
            ? 'Success: Database connection established'
            : 'Failed: Could not connect to database';
      });
    } catch (e) {
      setState(() {
        _connectionResult =
            'Error: ${ErrorHandler.getHumanReadableError(e.toString())}';
      });
    } finally {
      setState(() {
        _isTestingConnection = false;
      });
    }
  }

  Future<void> _testNotifications() async {
    setState(() {
      _isTestingNotifications = true;
      _notificationsResult = null;
    });

    try {
      final notifications = await SupabaseService.getNotifications();
      setState(() {
        _notificationsResult =
            'Success: Fetched ${notifications.length} notifications';
      });
    } catch (e) {
      setState(() {
        _notificationsResult =
            'Error: ${ErrorHandler.getHumanReadableError(e.toString())}';
      });
    } finally {
      setState(() {
        _isTestingNotifications = false;
      });
    }
  }

  void _showTestError(String type) {
    switch (type) {
      case 'Network Error':
        ErrorHandler.showError(
          context,
          'Unable to connect to server. Please check your internet connection and try again.',
        );
        break;
      case 'Auth Error':
        ErrorHandler.showError(
          context,
          'Invalid email or password. Please check your credentials and try again.',
        );
        break;
      case 'Success':
        ErrorHandler.showSuccess(context, 'Operation completed successfully!');
        break;
    }
  }
}
