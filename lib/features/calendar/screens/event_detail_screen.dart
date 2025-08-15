import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/neumorphic_widgets.dart';
import '../models/calendar_event.dart';
import '../models/event_participant.dart';
import '../services/calendar_service.dart';

class EventDetailScreen extends StatefulWidget {
  final CalendarEvent event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final CalendarService _calendarService = CalendarService();
  List<EventParticipant> _participants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    try {
      final participants = await _calendarService.getEventParticipants(
        widget.event.id,
      );
      setState(() {
        _participants = participants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading participants: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Event Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                // Navigate to edit screen
              } else if (value == 'delete') {
                _deleteEvent();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(
                  int.parse(widget.event.color.replaceAll('#', '0xFF')),
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(
                    int.parse(widget.event.color.replaceAll('#', '0xFF')),
                  ),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Color(
                            int.parse(
                              widget.event.color.replaceAll('#', '0xFF'),
                            ),
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.event.title,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimary
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(widget.event.color.replaceAll('#', '0xFF')),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.event.eventTypeDisplay,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Event Details
            _buildDetailSection(
              title: 'Event Details',
              children: [
                _buildDetailRow(
                  icon: Icons.access_time,
                  label: 'Time',
                  value:
                      '${widget.event.formattedStartTime} - ${widget.event.formattedEndTime}',
                ),
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: widget.event.formattedDate,
                ),
                if (widget.event.location != null)
                  _buildDetailRow(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: widget.event.location!,
                  ),
                if (widget.event.isOnline && widget.event.meetingLink != null)
                  _buildDetailRow(
                    icon: Icons.link,
                    label: 'Meeting Link',
                    value: widget.event.meetingLink!,
                    isLink: true,
                  ),
                _buildDetailRow(
                  icon: Icons.visibility,
                  label: 'Visibility',
                  value: _getVisibilityDisplay(widget.event.visibility),
                ),
                _buildDetailRow(
                  icon: Icons.info,
                  label: 'Status',
                  value: widget.event.statusDisplay,
                ),
              ],
            ),

            if (widget.event.description != null &&
                widget.event.description!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildDetailSection(
                title: 'Description',
                children: [
                  Text(
                    widget.event.description!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Reminders
            _buildDetailSection(
              title: 'Reminders',
              children: [
                _buildDetailRow(
                  icon: Icons.notifications,
                  label: 'Reminder Time',
                  value: '${widget.event.reminderMinutes} minutes before',
                ),
                _buildDetailRow(
                  icon: Icons.email,
                  label: 'Email Reminder',
                  value: widget.event.sendEmailReminder ? 'Yes' : 'No',
                ),
                _buildDetailRow(
                  icon: Icons.sms,
                  label: 'SMS Reminder',
                  value: widget.event.sendSmsReminder ? 'Yes' : 'No',
                ),
                _buildDetailRow(
                  icon: Icons.notifications_active,
                  label: 'Push Notification',
                  value: widget.event.sendPushReminder ? 'Yes' : 'No',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Participants
            _buildDetailSection(
              title: 'Participants',
              children: [
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_participants.isEmpty)
                  Text(
                    'No participants',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                    ),
                  )
                else
                  ..._participants.map(
                    (participant) => _buildParticipantTile(participant),
                  ),
              ],
            ),

            if (widget.event.notes != null &&
                widget.event.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildDetailSection(
                title: 'Notes',
                children: [
                  Text(
                    widget.event.notes!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: NeumorphicButton(
                    text: 'Edit Event',
                    onPressed: () {
                      // Navigate to edit screen
                    },
                    isGreen: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeumorphicButton(
                    text: 'Delete Event',
                    onPressed: _deleteEvent,
                    isGreen: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required List<Widget> children,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? AppColors.borderLight
                  : AppColors.borderLightTheme,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLink = false,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark
                ? AppColors.textSecondary
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                if (isLink)
                  GestureDetector(
                    onTap: () {
                      // Launch URL
                    },
                    child: Text(
                      value,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                else
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantTile(EventParticipant participant) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _getParticipantColor(participant.participantType),
            child: Text(
              participant.participantType[0].toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.participantTypeDisplay,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  participant.responseStatusDisplay,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _getStatusColor(participant.responseStatus),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(
                participant.responseStatus,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              participant.responseStatusDisplay,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(participant.responseStatus),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getParticipantColor(String participantType) {
    switch (participantType) {
      case 'creator':
        return AppColors.primary;
      case 'partner':
        return AppColors.success;
      case 'lawyer':
        return AppColors.warning;
      case 'mentor':
        return AppColors.info;
      case 'guest':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return AppColors.success;
      case 'declined':
        return AppColors.error;
      case 'tentative':
        return AppColors.warning;
      case 'pending':
      default:
        return AppColors.textSecondary;
    }
  }

  String _getVisibilityDisplay(String visibility) {
    switch (visibility) {
      case 'private':
        return 'Private';
      case 'shared_partners':
        return 'Shared with Partners';
      case 'shared_providers':
        return 'Shared with Providers';
      default:
        return 'Unknown';
    }
  }

  void _deleteEvent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text(
          'Are you sure you want to delete "${widget.event.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _calendarService.deleteEvent(widget.event.id);
                if (mounted) {
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting event: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
