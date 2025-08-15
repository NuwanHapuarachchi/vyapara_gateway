import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/widgets/neumorphic_widgets.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with TickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _future;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _future = SupabaseService.getNotifications();
  }

  void _refreshNotifications() {
    setState(() {
      _future = SupabaseService.getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refreshNotifications(),
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(child: _buildFiltersSection()),
              _buildNotificationsSliver(),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 10),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2B804).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFFF2B804),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Notifications',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: _markAllAsRead,
          icon: const Icon(Icons.done_all, color: AppColors.primary),
          tooltip: 'Mark all as read',
        ),
      ],
    );
  }

  Widget _buildNotificationsSliver() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final allNotifications = snapshot.data ?? [];
        final filteredNotifications = _filterNotifications(allNotifications);

        if (filteredNotifications.isEmpty) {
          return SliverToBoxAdapter(child: _buildEmptyState());
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final notification = filteredNotifications[index];
            return Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _buildNotificationCard(notification),
            );
          }, childCount: filteredNotifications.length),
        );
      },
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildFilterChip('All', Icons.apps),
          _buildFilterChip('Unread', Icons.mark_email_unread_outlined),
          _buildFilterChip('Applications', Icons.assignment_outlined),
          _buildFilterChip('System', Icons.settings_outlined),
          _buildFilterChip('Reminders', Icons.schedule_outlined),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final bool isSelected = _selectedFilter == label;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // Match My Applications filter chip visual using GlassCard
    final Color tint = AppColors.primary;
    final Color contentColor = isSelected
        ? (isDark ? Colors.white : tint)
        : (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight);

    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        borderRadius: BorderRadius.circular(12),
        tint: isSelected
            ? (isDark ? tint : AppColors.textSecondary)
            : AppColors.textSecondary,
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: contentColor),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: contentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              _selectedFilter == 'All'
                  ? Icons.notifications_none
                  : Icons.notifications_off,
              size: 60,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedFilter == 'All'
                ? 'No notifications'
                : 'No $_selectedFilter notifications',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final bool isRead = notification['read_at'] != null;
    final String type = _getNotificationType(notification);
    final IconData icon = _getNotificationIcon(type);
    final Color iconColor = _getNotificationColor(type);

    return GestureDetector(
      onTap: () => _markAsRead(notification),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead
              ? (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.cardDark
                    : AppColors.backgroundLight)
              : AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead
                ? (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.borderLight
                      : AppColors.borderLightTheme)
                : AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),

            const SizedBox(width: 16),

            // Notification Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'] ?? 'Notification',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: isRead
                                ? FontWeight.w500
                                : FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),

                  if (notification['body'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      notification['body'],
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          type,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: iconColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTime(notification['created_at']),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight,
                        ),
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

  List<Map<String, dynamic>> _filterNotifications(
    List<Map<String, dynamic>> notifications,
  ) {
    switch (_selectedFilter) {
      case 'Unread':
        return notifications.where((n) => n['read_at'] == null).toList();
      case 'Applications':
        return notifications
            .where((n) => _getNotificationType(n) == 'Application')
            .toList();
      case 'System':
        return notifications
            .where((n) => _getNotificationType(n) == 'System')
            .toList();
      case 'Reminders':
        return notifications
            .where((n) => _getNotificationType(n) == 'Reminder')
            .toList();
      default:
        return notifications;
    }
  }

  String _getNotificationType(Map<String, dynamic> notification) {
    final title = (notification['title'] ?? '').toLowerCase();
    final body = (notification['body'] ?? '').toLowerCase();

    if (title.contains('application') || body.contains('application')) {
      return 'Application';
    }
    if (title.contains('reminder') || body.contains('reminder')) {
      return 'Reminder';
    }
    if (title.contains('system') || body.contains('update')) return 'System';
    return 'General';
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'Application':
        return Icons.assignment;
      case 'Reminder':
        return Icons.schedule;
      case 'System':
        return Icons.settings;
      default:
        return Icons.info;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'Application':
        return Colors.blue;
      case 'Reminder':
        return Colors.orange;
      case 'System':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';

    try {
      final DateTime dateTime = DateTime.parse(timestamp.toString());
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return '';
    }
  }

  Future<void> _markAsRead(Map<String, dynamic> notification) async {
    if (notification['read_at'] != null) return;

    try {
      await SupabaseService.markNotificationRead(notification['id'] as String);
      _refreshNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking notification as read: $e')),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final notifications = await _future;
      final unreadNotifications = notifications.where(
        (n) => n['read_at'] == null,
      );

      for (final notification in unreadNotifications) {
        await SupabaseService.markNotificationRead(
          notification['id'] as String,
        );
      }

      _refreshNotifications();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('All notifications marked as read'),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking all as read: $e')),
        );
      }
    }
  }
}
