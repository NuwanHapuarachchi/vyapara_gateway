import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'page_transitions.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/account/screens/settings_screen.dart';
import '../../features/account/screens/nic_upload_screen.dart';
import '../../features/ai_help/screens/ai_chat_screen.dart';
import '../../features/applications/screens/my_applications_screen.dart';
import '../../features/applications/screens/application_detail_screen.dart';
import '../../features/community/screens/community_feed_screen.dart';
import '../../features/community/screens/mentor_chat_screen.dart';
import '../../features/community/screens/reserve_mentor_screen.dart';
import '../../features/community/screens/providers_list_screen.dart';
import '../../features/community/screens/provider_apply_screen.dart';
import '../../features/community/screens/provider_verification_screen.dart';
import '../../features/test/supabase_test_screen.dart';
import '../../features/test/network_test_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/documents/screens/document_vault_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/payments/screens/payment_screen.dart';
import '../../features/business_registration/screens/business_registration_wizard.dart';
import '../../features/banking/screens/bank_selection_screen.dart';
import '../../features/tax/screens/tax_registration_screens.dart';
import '../../features/licensing/screens/municipal_license_screens.dart';

/// Application routing configuration using GoRouter
class AppRouter {
  AppRouter._();

  static final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // Main Dashboard with nested routes
      ShellRoute(
        builder: (context, state, child) => DashboardScreen(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            pageBuilder: (context, state) =>
                PageTransitions.fadeScaleTransition(
                  context,
                  state,
                  const DashboardHomeView(),
                ),
          ),
          GoRoute(
            path: '/applications',
            name: 'applications',
            pageBuilder: (context, state) => PageTransitions.slideTransition(
              context,
              state,
              const MyApplicationsScreen(),
            ),
            routes: [
              GoRoute(
                path: '/detail/:id',
                name: 'application-detail',
                builder: (context, state) {
                  final applicationId = state.pathParameters['id']!;
                  return ApplicationDetailScreen(applicationId: applicationId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => PageTransitions.slideUpTransition(
              context,
              state,
              const SettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/nic-upload',
            name: 'nic-upload',
            pageBuilder: (context, state) => PageTransitions.slideUpTransition(
              context,
              state,
              const NicUploadScreen(),
            ),
          ),

          GoRoute(
            path: '/ai-help',
            name: 'ai-help',
            pageBuilder: (context, state) => PageTransitions.heroTransition(
              context,
              state,
              const AiChatScreen(),
            ),
          ),
          GoRoute(
            path: '/community',
            name: 'community',
            pageBuilder: (context, state) =>
                PageTransitions.sharedAxisTransition(
                  context,
                  state,
                  const CommunityFeedScreen(),
                ),
          ),
          GoRoute(
            path: '/calendar',
            name: 'calendar',
            pageBuilder: (context, state) => PageTransitions.slideTransition(
              context,
              state,
              const CalendarScreen(),
            ),
          ),
          GoRoute(
            path: '/documents',
            name: 'documents',
            pageBuilder: (context, state) => PageTransitions.slideTransition(
              context,
              state,
              const DocumentVaultScreen(),
            ),
          ),
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            pageBuilder: (context, state) => PageTransitions.slideUpTransition(
              context,
              state,
              const NotificationsScreen(),
            ),
          ),
          GoRoute(
            path: '/payments',
            name: 'payments',
            pageBuilder: (context, state) => PageTransitions.slideTransition(
              context,
              state,
              const PaymentScreen(),
            ),
          ),
          GoRoute(
            path: '/business-registration',
            name: 'business-registration',
            pageBuilder: (context, state) =>
                PageTransitions.fadeScaleTransition(
                  context,
                  state,
                  const BusinessRegistrationWizard(),
                ),
          ),
          // Banking flow
          GoRoute(
            path: '/banking/select',
            name: 'banking-select',
            pageBuilder: (context, state) => PageTransitions.slideTransition(
              context,
              state,
              const BankSelectionScreen(),
            ),
          ),
          GoRoute(
            path: '/banking/prepare',
            name: 'banking-prepare',
            pageBuilder: (context, state) => PageTransitions.slideTransition(
              context,
              state,
              const BankPreparationScreen(),
            ),
          ),
          GoRoute(
            path: '/banking/final',
            name: 'banking-final',
            pageBuilder: (context, state) => PageTransitions.slideUpTransition(
              context,
              state,
              const BankFinalStepsScreen(),
            ),
          ),
          // Tax flow
          GoRoute(
            path: '/tax/brief',
            name: 'tax-brief',
            pageBuilder: (context, state) => PageTransitions.slideTransition(
              context,
              state,
              const TaxBriefingScreen(),
            ),
          ),
          GoRoute(
            path: '/tax/form',
            name: 'tax-form',
            pageBuilder: (context, state) => PageTransitions.slideTransition(
              context,
              state,
              const TaxRegistrationFormScreen(),
            ),
          ),
          GoRoute(
            path: '/tax/review',
            name: 'tax-review',
            pageBuilder: (context, state) => PageTransitions.slideUpTransition(
              context,
              state,
              const TaxSubmitScreen(),
            ),
          ),
          // Municipal License flow
          GoRoute(
            path: '/license/location',
            name: 'license-location',
            pageBuilder: (context, state) => PageTransitions.slideTransition(
              context,
              state,
              const LocationConfirmScreen(),
            ),
          ),
          GoRoute(
            path: '/license/requirements',
            name: 'license-requirements',
            pageBuilder: (context, state) => PageTransitions.slideTransition(
              context,
              state,
              const RequirementsChecklistScreen(),
            ),
          ),
          GoRoute(
            path: '/license/form',
            name: 'license-form',
            pageBuilder: (context, state) => PageTransitions.slideTransition(
              context,
              state,
              const TradeLicenseFormScreen(),
            ),
          ),
          GoRoute(
            path: '/license/payment',
            name: 'license-payment',
            pageBuilder: (context, state) => PageTransitions.slideUpTransition(
              context,
              state,
              const LicensePaymentScreen(),
            ),
          ),
          // Provider discovery & application routes
          GoRoute(
            path: '/mentors',
            name: 'mentors',
            pageBuilder: (context, state) => PageTransitions.slideTransition(
              context,
              state,
              const ProvidersListScreen(providerKind: 'mentor'),
            ),
          ),
          GoRoute(
            path: '/lawyers',
            name: 'lawyers',
            pageBuilder: (context, state) => PageTransitions.slideTransition(
              context,
              state,
              const ProvidersListScreen(providerKind: 'lawyer'),
            ),
          ),
          GoRoute(
            path: '/apply-provider',
            name: 'apply-provider',
            pageBuilder: (context, state) => PageTransitions.slideUpTransition(
              context,
              state,
              const ProviderApplyScreen(),
            ),
          ),
          GoRoute(
            path: '/verify-providers',
            name: 'verify-providers',
            pageBuilder: (context, state) => PageTransitions.slideUpTransition(
              context,
              state,
              const ProviderVerificationScreen(),
            ),
          ),
        ],
      ),

      // Mentor Routes (outside shell for full-screen experience)
      GoRoute(
        path: '/mentor-chat/:mentorId',
        name: 'mentor-chat',
        builder: (context, state) {
          final mentorId = state.pathParameters['mentorId']!;
          return MentorChatScreen(mentorId: mentorId);
        },
      ),
      GoRoute(
        path: '/reserve-mentor',
        name: 'reserve-mentor',
        builder: (context, state) => const ReserveMentorScreen(),
      ),

      // Test routes (for development)
      GoRoute(
        path: '/test-supabase',
        name: 'test-supabase',
        builder: (context, state) => const SupabaseTestScreen(),
      ),
      GoRoute(
        path: '/test-network',
        name: 'test-network',
        builder: (context, state) => const NetworkTestScreen(),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.fullPath}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );

  /// Get the router instance
  static GoRouter get router => _router;
}

/// Navigation utilities
class AppNavigation {
  AppNavigation._();

  /// Navigate to splash screen
  static void toSplash(BuildContext context) {
    context.go('/splash');
  }

  /// Navigate to login screen
  static void toLogin(BuildContext context) {
    context.go('/login');
  }

  /// Navigate to signup screen
  static void toSignup(BuildContext context) {
    context.go('/signup');
  }

  /// Navigate to dashboard
  static void toDashboard(BuildContext context) {
    context.go('/dashboard');
  }

  /// Navigate to settings
  static void toSettings(BuildContext context) {
    context.go('/settings');
  }

  /// Navigate to NIC upload
  static void toNicUpload(BuildContext context) {
    context.go('/nic-upload');
  }

  /// Navigate to AI help
  static void toAiHelp(BuildContext context) {
    context.go('/ai-help');
  }

  /// Navigate to applications
  static void toApplications(BuildContext context) {
    context.go('/applications');
  }

  /// Navigate to specific application detail
  static void toApplicationDetail(BuildContext context, String applicationId) {
    context.go('/applications/detail/$applicationId');
  }

  /// Navigate to community feed
  static void toCommunity(BuildContext context) {
    context.go('/community');
  }

  /// Navigate to calendar
  static void toCalendar(BuildContext context) {
    context.go('/calendar');
  }

  /// Navigate to documents vault
  static void toDocuments(BuildContext context) {
    context.go('/documents');
  }

  /// Navigate to notifications
  static void toNotifications(BuildContext context) {
    context.go('/notifications');
  }

  /// Navigate to payments
  static void toPayments(BuildContext context) {
    context.go('/payments');
  }

  /// Navigate to business registration wizard
  static void toBusinessRegistration(BuildContext context) {
    context.go('/business-registration');
  }

  /// Navigate to mentor chat
  static void toMentorChat(BuildContext context, String mentorId) {
    context.go('/mentor-chat/$mentorId');
  }

  /// Navigate to reserve mentor
  static void toReserveMentor(BuildContext context) {
    context.go('/reserve-mentor');
  }

  static void toMentors(BuildContext context) {
    context.go('/mentors');
  }

  static void toLawyers(BuildContext context) {
    context.go('/lawyers');
  }

  static void toApplyProvider(BuildContext context) {
    context.go('/apply-provider');
  }

  static void toVerifyProviders(BuildContext context) {
    context.go('/verify-providers');
  }

  /// Go back if possible
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/dashboard');
    }
  }

  /// Handle system back button
  static bool handleSystemBack(BuildContext context) {
    // Always navigate to dashboard instead of exiting
    final currentLocation = GoRouterState.of(context).fullPath;
    if (currentLocation != '/dashboard') {
      context.go('/dashboard');
      return true; // Prevent system back
    }
    return false; // Allow system back (will exit app)
  }
}
