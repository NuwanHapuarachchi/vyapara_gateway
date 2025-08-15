import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/neumorphic_widgets.dart';
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
  TimeOfDay _endTime = TimeOfDay.now().replacing(
    hour: TimeOfDay.now().hour + 1,
  );

  String _selectedEventType = 'business_appointment';
  String _selectedVisibility = 'private';
  String _selectedColor = '#2196F3';

  int _reminderMinutes = 30;
  bool _sendEmailReminder = true;
  bool _sendSmsReminder = false;
  bool _sendPushReminder = true;
  bool _isOnline = false;
  bool _isLoading = false;

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

  final List<Map<String, dynamic>> _colors = [
    {'value': '#2196F3', 'label': 'Blue'},
    {'value': '#4CAF50', 'label': 'Green'},
    {'value': '#FF9800', 'label': 'Orange'},
    {'value': '#9C27B0', 'label': 'Purple'},
    {'value': '#F44336', 'label': 'Red'},
    {'value': '#607D8B', 'label': 'Blue Grey'},
    {'value': '#795548', 'label': 'Brown'},
    {'value': '#E91E63', 'label': 'Pink'},
  ];

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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Type Selection
              Text(
                'Event Type',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderLight
                        : AppColors.borderLightTheme,
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedEventType,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  items: _eventTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type['value'] as String,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse(
                                  (type['color'] as String).replaceAll(
                                    '#',
                                    '0xFF',
                                  ),
                                ),
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(type['label'] as String),
                        ],
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
              ),

              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Event Title *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // Date and Time Selection
              Row(
                children: [
                  Expanded(child: _buildDatePicker()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTimePicker()),
                ],
              ),

              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),

              const SizedBox(height: 16),

              // Online Meeting
              Row(
                children: [
                  Checkbox(
                    value: _isOnline,
                    onChanged: (value) {
                      setState(() {
                        _isOnline = value!;
                      });
                    },
                  ),
                  const Text('Online Meeting'),
                ],
              ),

              if (_isOnline) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _meetingLinkController,
                  decoration: InputDecoration(
                    labelText: 'Meeting Link',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.link),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Visibility
              Text(
                'Visibility',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderLight
                        : AppColors.borderLightTheme,
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedVisibility,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'private', child: Text('Private')),
                    DropdownMenuItem(
                      value: 'shared_partners',
                      child: Text('Shared with Partners'),
                    ),
                    DropdownMenuItem(
                      value: 'shared_providers',
                      child: Text('Shared with Providers'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedVisibility = value!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Color Selection
              Text(
                'Event Color',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colors.map((color) {
                  final isSelected = _selectedColor == color['value'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color['value'];
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(color['value'].replaceAll('#', '0xFF')),
                        ),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color(
                                    int.parse(
                                      color['value'].replaceAll('#', '0xFF'),
                                    ),
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Reminders
              Text(
                'Reminders',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),

              // Reminder time
              Row(
                children: [
                  const Text('Remind me'),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: _reminderMinutes,
                    items: [
                      const DropdownMenuItem(
                        value: 5,
                        child: Text('5 minutes'),
                      ),
                      const DropdownMenuItem(
                        value: 15,
                        child: Text('15 minutes'),
                      ),
                      const DropdownMenuItem(
                        value: 30,
                        child: Text('30 minutes'),
                      ),
                      const DropdownMenuItem(value: 60, child: Text('1 hour')),
                      const DropdownMenuItem(value: 1440, child: Text('1 day')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _reminderMinutes = value!;
                      });
                    },
                  ),
                  const Text('before'),
                ],
              ),

              const SizedBox(height: 12),

              // Reminder types
              CheckboxListTile(
                title: const Text('Email'),
                value: _sendEmailReminder,
                onChanged: (value) {
                  setState(() {
                    _sendEmailReminder = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('SMS'),
                value: _sendSmsReminder,
                onChanged: (value) {
                  setState(() {
                    _sendSmsReminder = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Push Notification'),
                value: _sendPushReminder,
                onChanged: (value) {
                  setState(() {
                    _sendPushReminder = value!;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 8),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: GoogleFonts.inter(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _startTime,
            );
            if (time != null) {
              setState(() {
                _startTime = time;
                // Auto-adjust end time if it's before start time
                if (_endTime.hour < _startTime.hour ||
                    (_endTime.hour == _startTime.hour &&
                        _endTime.minute <= _startTime.minute)) {
                  _endTime = _startTime.replacing(hour: _startTime.hour + 1);
                }
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 8),
                Text(
                  _startTime.format(context),
                  style: GoogleFonts.inter(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _endTime,
            );
            if (time != null) {
              setState(() {
                _endTime = time;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 8),
                Text(
                  _endTime.format(context),
                  style: GoogleFonts.inter(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
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
        'title': _titleController.text,
        'description': _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        'event_type': _selectedEventType,
        'visibility': _selectedVisibility,
        'start_date': _selectedDate.toIso8601String().split('T')[0],
        'start_time':
            '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
        'end_date': _selectedDate.toIso8601String().split('T')[0],
        'end_time':
            '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
        'location': _locationController.text.isEmpty
            ? null
            : _locationController.text,
        'meeting_link': _meetingLinkController.text.isEmpty
            ? null
            : _meetingLinkController.text,
        'is_online': _isOnline,
        'reminder_minutes': _reminderMinutes,
        'send_email_reminder': _sendEmailReminder,
        'send_sms_reminder': _sendSmsReminder,
        'send_push_reminder': _sendPushReminder,
        'color': _selectedColor,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating event: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
