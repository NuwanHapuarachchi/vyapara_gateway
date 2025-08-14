import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/network_provider.dart';

/// Widget to display network connectivity status
class NetworkStatusWidget extends ConsumerWidget {
  const NetworkStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkStatusProvider);
    final statusMessage = ref.watch(networkStatusMessageProvider);

    if (statusMessage == null) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor(networkStatus).withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: _getStatusColor(networkStatus).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(networkStatus),
            size: 16,
            color: _getStatusColor(networkStatus),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              statusMessage,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _getStatusColor(networkStatus),
              ),
            ),
          ),
          if (networkStatus == NetworkStatus.disconnected)
            GestureDetector(
              onTap: ref.read(networkRefreshProvider),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(networkStatus).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(networkStatus),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(NetworkStatus status) {
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

  IconData _getStatusIcon(NetworkStatus status) {
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
}

/// Compact network status indicator for app bars
class NetworkStatusIndicator extends ConsumerWidget {
  const NetworkStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkStatusProvider);

    if (networkStatus == NetworkStatus.connected) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _getStatusColor(networkStatus).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        _getStatusIcon(networkStatus),
        size: 16,
        color: _getStatusColor(networkStatus),
      ),
    );
  }

  Color _getStatusColor(NetworkStatus status) {
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

  IconData _getStatusIcon(NetworkStatus status) {
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
}
