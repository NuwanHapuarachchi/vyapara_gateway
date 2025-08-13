import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/account/screens/settings_screen.dart';
import '../../features/ai_help/screens/ai_chat_screen.dart';
import '../../features/applications/screens/my_applications_screen.dart';
import '../../features/applications/screens/application_detail_screen.dart';
import '../../features/community/screens/community_feed_screen.dart';
import '../../features/community/screens/mentor_chat_screen.dart';
import '../../features/community/screens/reserve_mentor_screen.dart';
import '../../features/test/supabase_test_screen.dart';

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
            builder: (context, state) => const DashboardHomeView(),
          ),
          GoRoute(
            path: '/applications',
            name: 'applications',
            builder: (context, state) => const MyApplicationsScreen(),
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
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/ai-help',
            name: 'ai-help',
            builder: (context, state) => const AiChatScreen(),
          ),
          GoRoute(
            path: '/community',
            name: 'community',
            builder: (context, state) => const CommunityFeedScreen(),
          ),
        ],
      ),

      // Mentor Routes
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

      // Test route (for development)
      GoRoute(
        path: '/test-supabase',
        name: 'test-supabase',
        builder: (context, state) => const SupabaseTestScreen(),
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

  /// Navigate to mentor chat
  static void toMentorChat(BuildContext context, String mentorId) {
    context.go('/mentor-chat/$mentorId');
  }

  /// Navigate to reserve mentor
  static void toReserveMentor(BuildContext context) {
    context.go('/reserve-mentor');
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
