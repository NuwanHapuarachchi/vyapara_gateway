import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/neumorphic_widgets.dart';

/// My Applications Screen with beautiful, modern design
class MyApplicationsScreen extends ConsumerStatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  ConsumerState<MyApplicationsScreen> createState() =>
      _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends ConsumerState<MyApplicationsScreen>
    with TickerProviderStateMixin {
  ApplicationFilter _currentFilter = ApplicationFilter.all;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Enhanced mock application data
  final List<ApplicationData> _applications = [
    ApplicationData(
      id: '1',
      title: 'Company Registration Form',
      description:
          'Private Limited Company registration with complete documentation',
      status: ApplicationStatus.approved,
      submittedDate: DateTime(2025, 1, 9),
      expectedCompletion: DateTime(2025, 1, 15),
      progress: 100,
      category: ApplicationCategory.companyRegistration,
      priority: ApplicationPriority.high,
      documentsCount: 8,
    ),
    ApplicationData(
      id: '2',
      title: 'Bank Account Opening',
      description: 'Commercial bank account setup for business operations',
      status: ApplicationStatus.inProgress,
      submittedDate: DateTime(2025, 1, 8),
      expectedCompletion: DateTime(2025, 1, 20),
      progress: 65,
      category: ApplicationCategory.banking,
      priority: ApplicationPriority.medium,
      documentsCount: 5,
    ),
    ApplicationData(
      id: '3',
      title: 'Tax Registration Certificate',
      description: 'VAT registration and tax identification number acquisition',
      status: ApplicationStatus.rejected,
      submittedDate: DateTime(2025, 1, 5),
      expectedCompletion: DateTime(2025, 1, 12),
      progress: 0,
      category: ApplicationCategory.taxation,
      priority: ApplicationPriority.high,
      documentsCount: 4,
      rejectionReason: 'Incomplete financial statements',
    ),
    ApplicationData(
      id: '4',
      title: 'Business License Application',
      description: 'Municipal business operating license for retail operations',
      status: ApplicationStatus.pending,
      submittedDate: DateTime(2025, 1, 12),
      expectedCompletion: DateTime(2025, 1, 25),
      progress: 0,
      category: ApplicationCategory.licensing,
      priority: ApplicationPriority.medium,
      documentsCount: 6,
    ),
    ApplicationData(
      id: '5',
      title: 'Import License',
      description: 'International trade import license for product categories',
      status: ApplicationStatus.inProgress,
      submittedDate: DateTime(2025, 1, 10),
      expectedCompletion: DateTime(2025, 1, 28),
      progress: 30,
      category: ApplicationCategory.trade,
      priority: ApplicationPriority.low,
      documentsCount: 12,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredApplications = _getFilteredApplications();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/dashboard');
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // App Bar
                _buildSliverAppBar(),

                // Statistics Cards
                _buildStatisticsSection(),

                // Filter Chips
                _buildFilterChips(),

                // Applications List
                _buildApplicationsList(filteredApplications),

                // Bottom Spacing
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2B804).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.assignment_outlined,
                color: Color(0xFFF2B804),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'My Applications',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: const [],
    );
  }

  Widget _buildStatisticsSection() {
    final stats = _calculateStatistics();

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total',
                '${stats['total']}',
                Icons.assignment_outlined,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Approved',
                '${stats['approved']}',
                Icons.check_circle_outline,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'In Progress',
                '${stats['inProgress']}',
                Icons.timelapse_outlined,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Rejected',
                '${stats['rejected']}',
                Icons.cancel_outlined,
                AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      tint: color,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            _buildFilterChip(ApplicationFilter.all, 'All', Icons.apps),
            _buildFilterChip(
              ApplicationFilter.approved,
              'Approved',
              Icons.check_circle,
            ),
            _buildFilterChip(
              ApplicationFilter.inProgress,
              'In Progress',
              Icons.timelapse,
            ),
            _buildFilterChip(
              ApplicationFilter.rejected,
              'Rejected',
              Icons.cancel,
            ),
            _buildFilterChip(
              ApplicationFilter.pending,
              'Pending',
              Icons.schedule,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    ApplicationFilter filter,
    String label,
    IconData icon,
  ) {
    final isSelected = _currentFilter == filter;

    final Color tint = _getFilterTint(filter);
    final Color contentColor = isSelected
        ? Colors.white
        : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: BorderRadius.circular(12),
        tint: isSelected ? tint : AppColors.textSecondary,
        onTap: () => _setFilter(filter),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: contentColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: contentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFilterTint(ApplicationFilter filter) {
    // Use same color for all filters
    return AppColors.primary;
  }

  Widget _buildApplicationsList(List<ApplicationData> applications) {
    if (applications.isEmpty) {
      return _buildEmptyState();
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: _buildApplicationCard(applications[index], index),
        );
      }, childCount: applications.length),
    );
  }

  Widget _buildApplicationCard(ApplicationData application, int index) {
    final statusColor = _getStatusColor(application.status);
    final statusIcon = _getStatusIcon(application.status);
    final categoryIcon = _getCategoryIcon(application.category);
    final priorityColor = _getPriorityColor(application.priority);

    // Use Sri Lankan theme tint based on category
    final Color tint = _getCategoryTint(application.category);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      tint: tint,
      onTap: () {
        // TODO: Navigate to application detail
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withOpacity(0.15),
                      statusColor.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(categoryIcon, color: statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            application.title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: priorityColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            application.priority.name.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: priorityColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      application.description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Status and Progress
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      application.status.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (application.status == ApplicationStatus.inProgress) ...[
                Text(
                  '${application.progress}%',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: LinearProgressIndicator(
                    value: application.progress / 100,
                    backgroundColor: statusColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(statusColor),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Bottom Row
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Submitted ${_formatDate(application.submittedDate)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.folder_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '${application.documentsCount} docs',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ],
          ),

          // Rejection Reason (if applicable)
          if (application.status == ApplicationStatus.rejected &&
              application.rejectionReason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 16,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reason: ${application.rejectionReason}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 60,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _getEmptyStateTitle(),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateMessage(),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            NeumorphicButton(
              text: 'Start New Application',
              onPressed: () {
                // TODO: Navigate to new application
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        _showNewApplicationBottomSheet();
      },
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: Text(
        'New Application',
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showNewApplicationBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start New Application',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose the type of business registration or service you need',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildApplicationTypeCard(
              'Company Registration',
              'Register your private limited company',
              Icons.business,
              const Color(0xFF3B82F6),
            ),
            _buildApplicationTypeCard(
              'Bank Account Opening',
              'Open business bank account',
              Icons.account_balance,
              const Color(0xFF10B981),
            ),
            _buildApplicationTypeCard(
              'Tax Registration',
              'Register for VAT and tax identification',
              Icons.receipt_long,
              const Color(0xFFF59E0B),
            ),
            _buildApplicationTypeCard(
              'Business License',
              'Obtain municipal operating license',
              Icons.verified,
              const Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationTypeCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: NeumorphicCard(
        padding: const EdgeInsets.all(16),
        onTap: () {
          Navigator.pop(context);
          if (title == 'Company Registration') {
            context.go('/business-registration');
          }
          // TODO: Navigate to other specific application forms
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _calculateStatistics() {
    return {
      'total': _applications.length,
      'approved': _applications
          .where((app) => app.status == ApplicationStatus.approved)
          .length,
      'inProgress': _applications
          .where((app) => app.status == ApplicationStatus.inProgress)
          .length,
      'rejected': _applications
          .where((app) => app.status == ApplicationStatus.rejected)
          .length,
      'pending': _applications
          .where((app) => app.status == ApplicationStatus.pending)
          .length,
    };
  }

  List<ApplicationData> _getFilteredApplications() {
    switch (_currentFilter) {
      case ApplicationFilter.approved:
        return _applications
            .where((app) => app.status == ApplicationStatus.approved)
            .toList();
      case ApplicationFilter.inProgress:
        return _applications
            .where((app) => app.status == ApplicationStatus.inProgress)
            .toList();
      case ApplicationFilter.rejected:
        return _applications
            .where((app) => app.status == ApplicationStatus.rejected)
            .toList();
      case ApplicationFilter.pending:
        return _applications
            .where((app) => app.status == ApplicationStatus.pending)
            .toList();
      case ApplicationFilter.all:
      default:
        return _applications;
    }
  }

  void _setFilter(ApplicationFilter filter) {
    setState(() {
      _currentFilter = filter;
    });
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.approved:
        return const Color(0xFF10B981);
      case ApplicationStatus.inProgress:
        return const Color(0xFFF59E0B);
      case ApplicationStatus.rejected:
        return const Color(0xFFEF4444);
      case ApplicationStatus.pending:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getStatusIcon(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.approved:
        return Icons.check_circle;
      case ApplicationStatus.inProgress:
        return Icons.timelapse;
      case ApplicationStatus.rejected:
        return Icons.cancel;
      case ApplicationStatus.pending:
        return Icons.schedule;
    }
  }

  IconData _getCategoryIcon(ApplicationCategory category) {
    switch (category) {
      case ApplicationCategory.companyRegistration:
        return Icons.business;
      case ApplicationCategory.banking:
        return Icons.account_balance;
      case ApplicationCategory.taxation:
        return Icons.receipt_long;
      case ApplicationCategory.licensing:
        return Icons.verified;
      case ApplicationCategory.trade:
        return Icons.import_export;
    }
  }

  Color _getPriorityColor(ApplicationPriority priority) {
    switch (priority) {
      case ApplicationPriority.high:
        return const Color(0xFFEF4444);
      case ApplicationPriority.medium:
        return const Color(0xFFF59E0B);
      case ApplicationPriority.low:
        return const Color(0xFF6B7280);
    }
  }

  Color _getCategoryTint(ApplicationCategory category) {
    // Use same color for all categories
    return AppColors.primary;
  }

  String _getEmptyStateTitle() {
    switch (_currentFilter) {
      case ApplicationFilter.approved:
        return 'No Approved Applications';
      case ApplicationFilter.inProgress:
        return 'No Applications in Progress';
      case ApplicationFilter.rejected:
        return 'No Rejected Applications';
      case ApplicationFilter.pending:
        return 'No Pending Applications';
      case ApplicationFilter.all:
      default:
        return 'No Applications Yet';
    }
  }

  String _getEmptyStateMessage() {
    switch (_currentFilter) {
      case ApplicationFilter.approved:
        return 'You don\'t have any approved applications at the moment.';
      case ApplicationFilter.inProgress:
        return 'No applications are currently being processed.';
      case ApplicationFilter.rejected:
        return 'No applications have been rejected.';
      case ApplicationFilter.pending:
        return 'No applications are waiting for review.';
      case ApplicationFilter.all:
      default:
        return 'Start your business registration journey by creating your first application.';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'today';
    } else if (difference == 1) {
      return 'yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Enhanced Application Data Model
class ApplicationData {
  final String id;
  final String title;
  final String description;
  final ApplicationStatus status;
  final DateTime submittedDate;
  final DateTime? expectedCompletion;
  final int progress; // 0-100
  final ApplicationCategory category;
  final ApplicationPriority priority;
  final int documentsCount;
  final String? rejectionReason;

  ApplicationData({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.submittedDate,
    this.expectedCompletion,
    this.progress = 0,
    required this.category,
    required this.priority,
    required this.documentsCount,
    this.rejectionReason,
  });
}

/// Application Status Enum
enum ApplicationStatus {
  pending,
  inProgress,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.inProgress:
        return 'In Progress';
      case ApplicationStatus.approved:
        return 'Approved';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }
}

/// Application Category Enum
enum ApplicationCategory {
  companyRegistration,
  banking,
  taxation,
  licensing,
  trade;

  String get displayName {
    switch (this) {
      case ApplicationCategory.companyRegistration:
        return 'Company Registration';
      case ApplicationCategory.banking:
        return 'Banking';
      case ApplicationCategory.taxation:
        return 'Taxation';
      case ApplicationCategory.licensing:
        return 'Licensing';
      case ApplicationCategory.trade:
        return 'Trade';
    }
  }
}

/// Application Priority Enum
enum ApplicationPriority {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case ApplicationPriority.low:
        return 'Low';
      case ApplicationPriority.medium:
        return 'Medium';
      case ApplicationPriority.high:
        return 'High';
    }
  }
}

/// Application Filter Enum
enum ApplicationFilter { all, pending, inProgress, approved, rejected }
