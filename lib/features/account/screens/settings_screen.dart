import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/providers/navigation_bar_provider.dart';
import '../../../shared/widgets/animated_navigation_bars.dart';

/// Settings Screen for user account management
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Navigate back to dashboard instead of exiting
          context.go('/dashboard');
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Settings',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: null,
            ),
          ),
        ),
        body: user == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Profile Section
                  _buildProfileSection(user),

                  const SizedBox(height: 24),

                  // Account Settings
                  _buildAccountSettings(user),

                  const SizedBox(height: 24),

                  // App Settings
                  _buildAppSettings(user),

                  const SizedBox(height: 32),

                  // Logout Button
                  _buildLogoutButton(),
                ],
              ),
      ),
    );
  }

  Widget _buildProfileSection(UserProfile user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Text(
                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: GoogleFonts.inter(fontSize: 14, color: null),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // TODO: Implement edit profile functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit profile feature coming soon!'),
                  ),
                );
              },
              child: const Text('change information?'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettings(UserProfile user) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Account Settings',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: null,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined, color: null),
            title: const Text('E-mail verification'),
            subtitle: Text(user.email),
            trailing: user.isEmailVerified
                ? const Icon(Icons.check_circle, color: AppColors.success)
                : TextButton(
                    onPressed: () {
                      // TODO: Implement email verification
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email verification sent!'),
                        ),
                      );
                    },
                    child: const Text('Verify'),
                  ),
          ),
          ListTile(
            leading: const Icon(Icons.credit_card_outlined, color: null),
            title: const Text('NIC Proof Upload'),
            subtitle: Text(user.nic ?? 'Not provided'),
            trailing: user.isNicVerified
                ? const Icon(Icons.check_circle, color: AppColors.success)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Text(
                        'pending',
                        style: GoogleFonts.inter(
                          color: AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
            onTap: () {
              // TODO: Implement NIC upload functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('NIC upload feature coming soon!'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone_outlined, color: null),
            title: const Text('Phone Number'),
            subtitle: Text(user.phone ?? 'Not provided'),
            trailing: const Icon(Icons.edit_outlined, color: null),
            onTap: () {
              // TODO: Implement phone number change
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Phone number change feature coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings(UserProfile user) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'App Settings',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: null,
              ),
            ),
          ),
          // Theme toggle
          Builder(
            builder: (context) {
              return SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined, color: null),
                value: AppThemeController.themeMode.value == ThemeMode.dark,
                onChanged: (isDark) {
                  AppThemeController.toggle(isDark);
                },
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle between dark and light theme'),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined, color: null),
            title: const Text('Mobile Notifications'),
            subtitle: const Text('Receive updates on your applications'),
            trailing: Switch(
              value:
                  true, // TODO: Implement notifications preference in UserProfile
              onChanged: (value) {
                // TODO: Add notificationsEnabled to UserProfile model
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications setting coming soon!'),
                  ),
                );
              },
            ),
          ),

          // Navigation Bar Style Selector
          Consumer(
            builder: (context, ref, child) {
              final currentNavType = ref.watch(navigationBarTypeProvider);
              final navNotifier = ref.read(navigationBarTypeProvider.notifier);

              return ListTile(
                leading: const Icon(Icons.view_carousel_outlined, color: null),
                title: const Text('Navigation Style'),
                subtitle: Text(navNotifier.getNavigationTypeName()),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: null,
                  size: 16,
                ),
                onTap: () {
                  _showNavigationStyleDialog(context, ref, currentNavType);
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined, color: null),
            title: const Text('Language'),
            subtitle: const Text('English'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: null,
              size: 16,
            ),
            onTap: () {
              // TODO: Implement language selection
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Language selection coming soon!'),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('Language'),
            subtitle: const Text('English'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implement language selection
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Language selection coming soon!'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: null),
            title: const Text('Help & Support'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: null,
              size: 16,
            ),
            onTap: () {
              // TODO: Implement help & support
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help & support feature coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: () async {
          // Show confirmation dialog
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: null,
                ),
              ),
              content: Text(
                'Are you sure you want to logout?',
                style: GoogleFonts.inter(color: null),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Logout',
                    style: GoogleFonts.inter(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );

          if (confirmed == true && mounted) {
            await ref.read(authProvider.notifier).logout();
            if (mounted) {
              context.go('/login');
            }
          }
        },
        icon: const Icon(Icons.logout, color: AppColors.error),
        label: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showNavigationStyleDialog(
    BuildContext context,
    WidgetRef ref,
    NavigationBarType currentType,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Choose Navigation Style',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final type in NavigationBarType.values)
                  RadioListTile<NavigationBarType>(
                    title: Text(
                      _getNavigationTypeName(type),
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      _getNavigationTypeDescription(type),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    value: type,
                    groupValue: currentType,
                    activeColor: AppColors.accent,
                    onChanged: (NavigationBarType? value) {
                      if (value != null) {
                        ref
                            .read(navigationBarTypeProvider.notifier)
                            .setNavigationType(value);
                        Navigator.of(context).pop();

                        // Show preview message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Navigation style changed to ${_getNavigationTypeName(value)}',
                            ),
                            backgroundColor: AppColors.accent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  String _getNavigationTypeName(NavigationBarType type) {
    switch (type) {
      case NavigationBarType.neumorphic:
        return 'Classic Neumorphic';
      case NavigationBarType.fluidGlass:
        return 'iOS Fluid Glass';
      case NavigationBarType.bubble:
        return 'Bubble Animation';
    }
  }

  String _getNavigationTypeDescription(NavigationBarType type) {
    switch (type) {
      case NavigationBarType.neumorphic:
        return 'Clean design with subtle shadow effects';
      case NavigationBarType.fluidGlass:
        return 'Modern floating glass with blur effects';
      case NavigationBarType.bubble:
        return 'Playful liquid bubble animations';
    }
  }
}
