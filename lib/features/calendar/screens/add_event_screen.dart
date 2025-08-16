import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../services/calendar_service.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _calendarService = CalendarService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _meetingLinkController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();

  String _selectedEventType = 'business_appointment';
  String _selectedColor = '#4CAF50'; // Default to business appointment color

  int _reminderMinutes = 30;
  bool _sendEmailReminder = true;
  bool _sendSmsReminder = false;
  bool _sendPushReminder = true;
  bool _isOnline = false;
  bool _isLoading = false;

  // Getter to check if reminders are enabled
  bool get _remindersEnabled => _reminderMinutes > 0;

  final List<Map<String, dynamic>> _eventTypes = [
    {
      'value': 'business_appointment',
      'label': 'Business Appointment',
      'color': '#4CAF50',
    },
    {
      'value': 'legal_consultation',
      'label': 'Legal Consultation',
      'color': '#2196F3',
    },
    {
      'value': 'business_mentoring',
      'label': 'Business Mentoring',
      'color': '#FF9800',
    },
    {
      'value': 'government_office',
      'label': 'Government Office',
      'color': '#9C27B0',
    },
    {
      'value': 'bank_appointment',
      'label': 'Bank Appointment',
      'color': '#607D8B',
    },
    {
      'value': 'general_reminder',
      'label': 'General Reminder',
      'color': '#795548',
    },
    {'value': 'custom_event', 'label': 'Custom Event', 'color': '#E91E63'},
  ];

  @override
  void initState() {
    super.initState();
    // Set initial color based on default event type
    _selectedColor = _eventTypes.firstWhere(
      (t) => t['value'] == _selectedEventType,
    )['color'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _meetingLinkController.dispose();
    _notesController.dispose();
    super.dispose();
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
          'Add Event',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveEvent,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Type Section
              _buildSectionHeader('Event Type', Icons.category),
              const SizedBox(height: 26),
              _buildEventTypeDropdown(isDark),
              const SizedBox(height: 8),

              // Privacy notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All events are private and only visible to you',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Basic Details Section
              _buildSectionHeader('Event Details', Icons.edit),
              const SizedBox(height: 22),

              // Title
              _buildTextField(
                controller: _titleController,
                label: 'Event Title *',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Date and Time Section
              _buildSectionHeader('Date & Time', Icons.schedule),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: _buildDatePicker()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTimePicker()),
                ],
              ),
              const SizedBox(height: 24),

              // Location Section
              _buildSectionHeader('Location', Icons.location_on),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _locationController,
                label: 'Location',
                icon: Icons.place,
              ),
              const SizedBox(height: 16),

              // Online Meeting Toggle
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
                child: Row(
                  children: [
                    Checkbox(
                      value: _isOnline,
                      onChanged: (value) {
                        setState(() {
                          _isOnline = value!;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.video_call,
                      color: _isOnline ? AppColors.primary : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Online Meeting',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              if (_isOnline) ...[
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _meetingLinkController,
                  label: 'Meeting Link',
                  icon: Icons.link,
                ),
              ],
              const SizedBox(height: 24),

              // Reminders Section
              _buildSectionHeader('Reminders', Icons.notifications),
              const SizedBox(height: 16),

              _buildReminderSettings(),
              const SizedBox(height: 24),

              // Notes Section
              _buildSectionHeader('Additional Notes', Icons.note),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _notesController,
                label: 'Notes',
                icon: Icons.note_add,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.cardDark
              : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.borderLight
                : AppColors.borderLightTheme,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _startTime,
        );
        if (time != null) {
          setState(() {
            _startTime = time;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.cardDark
              : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.borderLight
                : AppColors.borderLightTheme,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Time: ${_startTime.format(context)}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final eventData = {
        'creator_id': user.id,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'event_type': _selectedEventType,
        'status': 'scheduled', // Add missing status field
        'visibility': 'private', // Always private
        'start_date': _selectedDate.toIso8601String().split('T')[0],
        'start_time':
            '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
        'end_date': _selectedDate.toIso8601String().split('T')[0],
        'end_time': _addOneHour(
          '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
        ),
        'location': _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        'meeting_link': _meetingLinkController.text.trim().isEmpty
            ? null
            : _meetingLinkController.text.trim(),
        'is_online': _isOnline,
        'reminder_minutes': _reminderMinutes > 0 ? _reminderMinutes : null,
        'send_email_reminder': _reminderMinutes > 0
            ? _sendEmailReminder
            : false,
        'send_sms_reminder': _reminderMinutes > 0 ? _sendSmsReminder : false,
        'send_push_reminder': _reminderMinutes > 0 ? _sendPushReminder : false,
        'color': _selectedColor,
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      };

      await _calendarService.createEvent(eventData);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Helper method to add one hour to time string
  String _addOneHour(String time) {
    final parts = time.split(':');
    int hour = int.parse(parts[0]);
    final minute = parts[1];

    hour = (hour + 1) % 24;
    return '${hour.toString().padLeft(2, '0')}:$minute';
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textPrimary
                : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardDark
            : AppColors.cardLight,
      ),
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildEventTypeDropdown(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[900]
            : Colors.white, // Use white for light theme
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderLight : AppColors.borderLightTheme,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedEventType,
        isExpanded: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          isDense: false,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.primary,
          size: 24,
        ),
        dropdownColor: isDark
            ? Colors.grey[900]
            : Colors.white, // Match container color
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark
              ? Colors.white
              : Colors.black87, // Theme-aware text color
        ),
        selectedItemBuilder: (BuildContext context) {
          return _eventTypes.map<Widget>((type) {
            return Container(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  // Color indicator for selected item
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(
                          (type['color'] as String).replaceAll('#', '0xFF'),
                        ),
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Selected text with proper color
                  Text(
                    type['label'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }).toList();
        },
        items: _eventTypes.map((type) {
          return DropdownMenuItem<String>(
            value: type['value'] as String,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Color indicator with better sizing
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(
                          (type['color'] as String).replaceAll('#', '0xFF'),
                        ),
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Event type label with better text handling
                  Expanded(
                    child: Text(
                      type['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.white
                            : Colors.black87, // Theme-aware text color
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedEventType = value!;
            _selectedColor = _eventTypes.firstWhere(
              (t) => t['value'] == value,
            )['color'];
          });
        },
      ),
    );
  }

  Widget _buildReminderSettings() {
    return Column(
      children: [
        // Reminder time
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.cardDark
                : AppColors.cardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.borderLight
                  : AppColors.borderLightTheme,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.timer, color: AppColors.primary),
              const SizedBox(width: 12),
              const Text('Remind me'),
              const SizedBox(width: 12),
              DropdownButton<int?>(
                value: _reminderMinutes == 0 ? null : _reminderMinutes,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Off')),
                  const DropdownMenuItem(value: 5, child: Text('5 minutes')),
                  const DropdownMenuItem(value: 15, child: Text('15 minutes')),
                  const DropdownMenuItem(value: 30, child: Text('30 minutes')),
                  const DropdownMenuItem(value: 60, child: Text('1 hour')),
                  const DropdownMenuItem(value: 1440, child: Text('1 day')),
                ],
                onChanged: (value) {
                  setState(() {
                    _reminderMinutes = value ?? 0;
                  });
                },
              ),
              const Text('before'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Reminder types
        if (_remindersEnabled) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.cardDark
                  : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.borderLight
                    : AppColors.borderLightTheme,
              ),
            ),
            child: Column(
              children: [
                CheckboxListTile(
                  title: Row(
                    children: [
                      Icon(Icons.email, color: AppColors.primary),
                      const SizedBox(width: 12),
                      const Text('Email'),
                    ],
                  ),
                  value: _sendEmailReminder,
                  onChanged: (value) {
                    setState(() {
                      _sendEmailReminder = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Row(
                    children: [
                      Icon(Icons.sms, color: AppColors.primary),
                      const SizedBox(width: 12),
                      const Text('SMS'),
                    ],
                  ),
                  value: _sendSmsReminder,
                  onChanged: (value) {
                    setState(() {
                      _sendSmsReminder = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Row(
                    children: [
                      Icon(Icons.notifications, color: AppColors.primary),
                      const SizedBox(width: 12),
                      const Text('Push Notification'),
                    ],
                  ),
                  value: _sendPushReminder,
                  onChanged: (value) {
                    setState(() {
                      _sendPushReminder = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
