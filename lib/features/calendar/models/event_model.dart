import 'package:flutter/material.dart';

/// Event model for calendar functionality
class Event {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final EventType type;
  final EventPriority priority;
  final DateTime startAt;
  final DateTime? endAt;
  final bool allDay;
  final String? location;
  final Color color;
  final bool isRecurring;
  final String? recurrencePattern;
  final DateTime? recurrenceEndDate;
  final List<int> reminderMinutes;
  final List<String> attendees;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.type = EventType.personal,
    this.priority = EventPriority.normal,
    required this.startAt,
    this.endAt,
    this.allDay = false,
    this.location,
    this.color = Colors.blue,
    this.isRecurring = false,
    this.recurrencePattern,
    this.recurrenceEndDate,
    this.reminderMinutes = const [],
    this.attendees = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create Event from JSON (Supabase response)
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: EventType.fromString(json['event_type'] as String? ?? 'personal'),
      priority: EventPriority.fromString(
        json['priority'] as String? ?? 'normal',
      ),
      startAt: DateTime.parse(json['start_at'] as String),
      endAt: json['end_at'] != null
          ? DateTime.parse(json['end_at'] as String)
          : null,
      allDay: json['all_day'] as bool? ?? false,
      location: json['location'] as String?,
      color: Color(
        int.parse(
          (json['color'] as String? ?? '#3B82F6').replaceFirst('#', '0xFF'),
        ),
      ),
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurrencePattern: json['recurrence_pattern'] as String?,
      recurrenceEndDate: json['recurrence_end_date'] != null
          ? DateTime.parse(json['recurrence_end_date'] as String)
          : null,
      reminderMinutes: json['reminder_minutes'] != null
          ? List<int>.from(json['reminder_minutes'] as List)
          : [],
      attendees: json['attendees'] != null
          ? List<String>.from(json['attendees'] as List)
          : [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert Event to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'event_type': type.value,
      'priority': priority.value,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
      'all_day': allDay,
      'location': location,
      'color': '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
      'is_recurring': isRecurring,
      'recurrence_pattern': recurrencePattern,
      'recurrence_end_date': recurrenceEndDate?.toIso8601String(),
      'reminder_minutes': reminderMinutes,
      'attendees': attendees,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of Event with updated fields
  Event copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    EventType? type,
    EventPriority? priority,
    DateTime? startAt,
    DateTime? endAt,
    bool? allDay,
    String? location,
    Color? color,
    bool? isRecurring,
    String? recurrencePattern,
    DateTime? recurrenceEndDate,
    List<int>? reminderMinutes,
    List<String>? attendees,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      allDay: allDay ?? this.allDay,
      location: location ?? this.location,
      color: color ?? this.color,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      attendees: attendees ?? this.attendees,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if event is on a specific date
  bool isOnDate(DateTime date) {
    final eventDate = DateTime(startAt.year, startAt.month, startAt.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return eventDate.isAtSameMomentAs(checkDate);
  }

  /// Get formatted time range
  String get timeRange {
    if (allDay) return 'All day';

    final startTime =
        '${startAt.hour.toString().padLeft(2, '0')}:${startAt.minute.toString().padLeft(2, '0')}';
    if (endAt == null) return startTime;

    final endTime =
        '${endAt!.hour.toString().padLeft(2, '0')}:${endAt!.minute.toString().padLeft(2, '0')}';
    return '$startTime - $endTime';
  }

  /// Get formatted date
  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${startAt.day} ${months[startAt.month - 1]}, ${startAt.year}';
  }
}

/// Event type enum
enum EventType {
  appointment('appointment'),
  deadline('deadline'),
  reminder('reminder'),
  meeting('meeting'),
  personal('personal'),
  business('business');

  const EventType(this.value);
  final String value;

  static EventType fromString(String value) {
    return EventType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => EventType.personal,
    );
  }

  String get displayName {
    switch (this) {
      case EventType.appointment:
        return 'Appointment';
      case EventType.deadline:
        return 'Deadline';
      case EventType.reminder:
        return 'Reminder';
      case EventType.meeting:
        return 'Meeting';
      case EventType.personal:
        return 'Personal';
      case EventType.business:
        return 'Business';
    }
  }

  IconData get icon {
    switch (this) {
      case EventType.appointment:
        return Icons.event_available;
      case EventType.deadline:
        return Icons.schedule;
      case EventType.reminder:
        return Icons.notifications;
      case EventType.meeting:
        return Icons.group;
      case EventType.personal:
        return Icons.person;
      case EventType.business:
        return Icons.business;
    }
  }
}

/// Event priority enum
enum EventPriority {
  low('low'),
  normal('normal'),
  high('high'),
  urgent('urgent');

  const EventPriority(this.value);
  final String value;

  static EventPriority fromString(String value) {
    return EventPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => EventPriority.normal,
    );
  }

  String get displayName {
    switch (this) {
      case EventPriority.low:
        return 'Low';
      case EventPriority.normal:
        return 'Normal';
      case EventPriority.high:
        return 'High';
      case EventPriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case EventPriority.low:
        return Colors.green;
      case EventPriority.normal:
        return Colors.blue;
      case EventPriority.high:
        return Colors.orange;
      case EventPriority.urgent:
        return Colors.red;
    }
  }
}
