import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../../shared/widgets/neumorphic_widgets.dart';

/// Main Dashboard Screen with Bottom Navigation
class DashboardScreen extends ConsumerStatefulWidget {
  final Widget child;

  const DashboardScreen({super.key, required this.child});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime? _lastBackPressed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackButton(context);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: widget.child,
        bottomNavigationBar: NeumorphicBottomNavBar(
          currentIndex: _getCurrentIndex(context),
          onTap: (index) {
            switch (index) {
              case 0:
                AppNavigation.toSettings(context);
                break;
              case 1:
                // Notifications - placeholder
                break;
              case 2:
                AppNavigation.toDashboard(context);
                break;
              case 3:
                AppNavigation.toCommunity(context);
                break;
              case 4:
                AppNavigation.toApplications(context);
                break;
            }
          },
        ),
      ),
    );
  }

  /// Handle back button press with double tap to exit functionality
  void _handleBackButton(BuildContext context) {
    final currentLocation = GoRouterState.of(context).fullPath;

    // If not on dashboard home, navigate to dashboard
    if (currentLocation != '/dashboard') {
      context.go('/dashboard');
      return;
    }

    // If on dashboard home, implement double tap to exit
    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      // First tap or more than 2 seconds since last tap
      _lastBackPressed = now;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Press back again to exit',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Second tap within 2 seconds - exit app
      SystemNavigator.pop();
    }
  }

  /// Get current index based on route
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).fullPath;
    if (location?.startsWith('/settings') == true) return 0;
    if (location?.startsWith('/applications') == true) return 4;
    if (location?.startsWith('/community') == true) return 3;
    return 2; // Default to dashboard/home
  }
}

/// Dashboard Home View - Main content matching Figma design
class DashboardHomeView extends ConsumerWidget {
  const DashboardHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Body content with padding
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // My Applications section
                    _buildMyApplicationsSection(context),

                    const SizedBox(height: 32),

                    // Start New Application Button
                    _buildNewApplicationButton(context),

                    const SizedBox(height: 32),

                    // Feature grid
                    _buildFeatureGrid(context),

                    const SizedBox(height: 32),

                    // AI Help button
                    _buildAiHelpButton(context),

                    const SizedBox(height: 100), // Space for bottom navigation
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Sidebar toggle
          SizedBox(
            width: 30,
            height: 30,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.menu, color: AppColors.primary, size: 30),
              padding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(width: 12),

          // Dashboard title
          Expanded(
            child: Text(
              'Dashboard',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFA9A9A9),
              ),
            ),
          ),

          // Profile icon
          Container(
            width: 57,
            height: 57,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  offset: const Offset(4, 4),
                  blurRadius: 8,
                ),
                BoxShadow(
                  color: const Color(0xFF323030).withValues(alpha: 0.25),
                  offset: const Offset(-4, -4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Color(0xFFA9A9A9), size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildMyApplicationsSection(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      tint: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.business_center,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'My Business Applications',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => AppNavigation.toApplications(context),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Application items
          _buildApplicationItem(
            context,
            'Business Registration Application',
            'In Progress',
            Icons.pending_actions,
            const Color(0xFFF59E0B),
          ),

          const SizedBox(height: 12),

          _buildApplicationItem(
            context,
            'Tax Registration Certificate',
            'Approved',
            Icons.check_circle,
            const Color(0xFF10B981),
          ),

          const SizedBox(height: 12),

          _buildApplicationItem(
            context,
            'Trade Permit Application',
            'Document Required',
            Icons.warning,
            const Color(0xFFEF4444),
          ),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: () => AppNavigation.toApplications(context),
            child: Center(
              child: Text(
                'View All Applications',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accentGreen,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationItem(
    BuildContext context,
    String title,
    String status,
    IconData statusIcon,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF323030), width: 1),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFA9A9A9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF6B7280), size: 16),
        ],
      ),
    );
  }

  Widget _buildNewApplicationButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        tint: AppColors.accentGreen,
        onTap: () => AppNavigation.toApplications(context),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.accentGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add_business,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start New Business Registration',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFA9A9A9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Begin your business registration process',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return Column(
      children: [
        Text(
          'Business Services',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFA9A9A9),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Application Tracking
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                tint: AppColors.slBlue,
                onTap: () => AppNavigation.toApplications(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBBD8FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        color: Color(0xFF092F63),
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track Applications',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFA9A9A9),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Business Community
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                tint: AppColors.slGreen,
                onTap: () => AppNavigation.toCommunity(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCE2E3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.groups_outlined,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Community',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFA9A9A9),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Settings
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                tint: AppColors.slMaroon,
                onTap: () => AppNavigation.toSettings(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: Color(0xFFDC2626),
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Settings',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFA9A9A9),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAiHelpButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        tint: AppColors.accent,
        onTap: () => AppNavigation.toAiHelp(context),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF8FBFFA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.help_outline,
                color: Color(0xFF2859C5),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Chatbot Help',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFA9A9A9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get instant help with your business registration',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
