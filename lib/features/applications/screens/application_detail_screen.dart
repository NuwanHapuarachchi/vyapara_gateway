import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../core/constants/app_colors.dart';

/// Application Detail Screen showing specific application information
class ApplicationDetailScreen extends ConsumerWidget {
  final String applicationId;

  const ApplicationDetailScreen({super.key, required this.applicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock application detail data
    final application = _getMockApplicationDetail(applicationId);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          application.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Section
            _buildProgressSection(application),

            const SizedBox(height: 24),

            // Application Info
            _buildApplicationInfo(application),

            const SizedBox(height: 24),

            // Document Submission
            _buildDocumentSubmission(application),

            const SizedBox(height: 24),

            // Timeline
            _buildTimeline(application),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(ApplicationDetailData application) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Application Progress',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            LinearPercentIndicator(
              padding: EdgeInsets.zero,
              lineHeight: 8.0,
              percent: application.progress,
              backgroundColor: AppColors.borderLight,
              progressColor: AppColors.primary,
              barRadius: const Radius.circular(4),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(application.progress * 100).toInt()}% Completed',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Est. ${application.estimatedDays} days remaining',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationInfo(ApplicationDetailData application) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Application Information',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              children: [
                _buildInfoRow('Purpose', application.purpose),
                _buildInfoRow('Process', application.process),
                _buildInfoRow('Time', application.timeframe),
                _buildInfoRow('Fee', application.fee),
                _buildInfoRow('Status', application.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildInfoRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentSubmission(ApplicationDetailData application) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Submission',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...application.documents.map((doc) => _buildDocumentItem(doc)),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(DocumentItem document) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          document.isSubmitted
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
          color: document.isSubmitted
              ? AppColors.success
              : AppColors.textTertiary,
        ),
        title: Text(
          document.name,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: document.isSubmitted
            ? Text(
                'Submitted',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.success,
                ),
              )
            : Text(
                'Pending submission',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
        trailing: document.isSubmitted
            ? null
            : TextButton(
                onPressed: () {
                  // TODO: Implement document upload
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(content: Text('Document upload coming soon!')),
                  // );
                },
                child: const Text('Upload'),
              ),
      ),
    );
  }

  Widget _buildTimeline(ApplicationDetailData application) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Application Timeline',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...application.timeline.map((event) => _buildTimelineItem(event)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(TimelineEvent event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: event.isCompleted
                  ? AppColors.success
                  : AppColors.borderLight,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (event.date != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(event.date!),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  ApplicationDetailData _getMockApplicationDetail(String id) {
    return ApplicationDetailData(
      id: id,
      title: 'Business Registration',
      purpose: 'Register a new business entity',
      process: 'Online application with document verification',
      timeframe: '10-15 business days',
      fee: 'LKR 15,000',
      status: 'Under Review',
      progress: 0.6,
      estimatedDays: 5,
      documents: [
        DocumentItem('Business Name Certificate', true),
        DocumentItem('Owner\'s NIC Copy', true),
        DocumentItem('Business Address Proof', true),
        DocumentItem('Bank Statement', false),
        DocumentItem('Business Plan', false),
      ],
      timeline: [
        TimelineEvent(
          'Application Submitted',
          'Your application has been successfully submitted',
          true,
          DateTime.now().subtract(const Duration(days: 7)),
        ),
        TimelineEvent(
          'Initial Review',
          'Application is being reviewed by our team',
          true,
          DateTime.now().subtract(const Duration(days: 5)),
        ),
        TimelineEvent(
          'Document Verification',
          'Documents are being verified',
          false,
          null,
        ),
        TimelineEvent(
          'Final Approval',
          'Final review and approval',
          false,
          null,
        ),
      ],
    );
  }
}

/// Application detail data model
class ApplicationDetailData {
  final String id;
  final String title;
  final String purpose;
  final String process;
  final String timeframe;
  final String fee;
  final String status;
  final double progress;
  final int estimatedDays;
  final List<DocumentItem> documents;
  final List<TimelineEvent> timeline;

  ApplicationDetailData({
    required this.id,
    required this.title,
    required this.purpose,
    required this.process,
    required this.timeframe,
    required this.fee,
    required this.status,
    required this.progress,
    required this.estimatedDays,
    required this.documents,
    required this.timeline,
  });
}

/// Document item model
class DocumentItem {
  final String name;
  final bool isSubmitted;

  DocumentItem(this.name, this.isSubmitted);
}

/// Timeline event model
class TimelineEvent {
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? date;

  TimelineEvent(this.title, this.description, this.isCompleted, this.date);
}
