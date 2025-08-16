import 'package:json_annotation/json_annotation.dart';

part 'calendar_event.g.dart';

@JsonSerializable()
class CalendarEvent {
  final String id;
  @JsonKey(name: 'creator_id')
  final String creatorId;
  @JsonKey(name: 'business_id')
  final String? businessId;
  @JsonKey(name: 'application_id')
  final String? applicationId;
  final String title;
  final String? description;
  @JsonKey(name: 'event_type')
  final String eventType;
  final String status;
  final String visibility;
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_date')
  final DateTime endDate;
  @JsonKey(name: 'end_time')
  final String endTime;
  final String? location;
  @JsonKey(name: 'meeting_link')
  final String? meetingLink;
  @JsonKey(name: 'is_online')
  final bool isOnline;
  @JsonKey(name: 'reminder_minutes')
  final int? reminderMinutes; // Changed to nullable
  @JsonKey(name: 'send_email_reminder')
  final bool sendEmailReminder;
  @JsonKey(name: 'send_sms_reminder')
  final bool sendSmsReminder;
  @JsonKey(name: 'send_push_reminder')
  final bool sendPushReminder;
  final String color;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  CalendarEvent({
    required this.id,
    required this.creatorId,
    this.businessId,
    this.applicationId,
    required this.title,
    this.description,
    required this.eventType,
    required this.status,
    required this.visibility,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    this.location,
    this.meetingLink,
    required this.isOnline,
    this.reminderMinutes, // Changed to nullable
    required this.sendEmailReminder,
    required this.sendSmsReminder,
    required this.sendPushReminder,
    required this.color,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarEventToJson(this);

  // Helper methods
  DateTime get startDateTime => DateTime(
    startDate.year,
    startDate.month,
    startDate.day,
    int.parse(startTime.split(':')[0]),
    int.parse(startTime.split(':')[1]),
  );

  DateTime get endDateTime => DateTime(
    endDate.year,
    endDate.month,
    endDate.day,
    int.parse(endTime.split(':')[0]),
    int.parse(endTime.split(':')[1]),
  );

  bool get isToday {
    final now = DateTime.now();
    return startDate.year == now.year &&
        startDate.month == now.month &&
        startDate.day == now.day;
  }

  bool get isUpcoming {
    return startDateTime.isAfter(DateTime.now());
  }

  bool get isPast {
    return endDateTime.isBefore(DateTime.now());
  }

  String get formattedStartTime {
    final time = startTime.split(':');
    final hour = int.parse(time[0]);
    final minute = time[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String get formattedEndTime {
    final time = endTime.split(':');
    final hour = int.parse(time[0]);
    final minute = time[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String get formattedDate {
    return '${startDate.day}/${startDate.month}/${startDate.year}';
  }

  // Helper methods for reminders
  bool get hasReminders => reminderMinutes != null && reminderMinutes! > 0;

  String get reminderText {
    if (!hasReminders) return 'No reminders';
    if (reminderMinutes! < 60) return '$reminderMinutes minutes before';
    if (reminderMinutes! < 1440) {
      return '${(reminderMinutes! / 60).round()} hours before';
    }
    return '${(reminderMinutes! / 1440).round()} days before';
  }

  String get eventTypeDisplay {
    switch (eventType) {
      case 'business_appointment':
        return 'Business Appointment';
      case 'legal_consultation':
        return 'Legal Consultation';
      case 'business_mentoring':
        return 'Business Mentoring';
      case 'government_office':
        return 'Government Office';
      case 'bank_appointment':
        return 'Bank Appointment';
      case 'general_reminder':
        return 'General Reminder';
      case 'custom_event':
        return 'Custom Event';
      default:
        return 'Event';
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'scheduled':
        return 'Scheduled';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'rescheduled':
        return 'Rescheduled';
      default:
        return 'Unknown';
    }
  }

  CalendarEvent copyWith({
    String? id,
    String? creatorId,
    String? businessId,
    String? applicationId,
    String? title,
    String? description,
    String? eventType,
    String? status,
    String? visibility,
    DateTime? startDate,
    String? startTime,
    DateTime? endDate,
    String? endTime,
    String? location,
    String? meetingLink,
    bool? isOnline,
    int? reminderMinutes,
    bool? sendEmailReminder,
    bool? sendSmsReminder,
    bool? sendPushReminder,
    String? color,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      businessId: businessId ?? this.businessId,
      applicationId: applicationId ?? this.applicationId,
      title: title ?? this.title,
      description: description ?? this.description,
      eventType: eventType ?? this.eventType,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      startDate: startDate ?? this.startDate,
      startTime: startTime ?? this.startTime,
      endDate: endDate ?? this.endDate,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      meetingLink: meetingLink ?? this.meetingLink,
      isOnline: isOnline ?? this.isOnline,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      sendEmailReminder: sendEmailReminder ?? this.sendEmailReminder,
      sendSmsReminder: sendSmsReminder ?? this.sendSmsReminder,
      sendPushReminder: sendPushReminder ?? this.sendPushReminder,
      color: color ?? this.color,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
