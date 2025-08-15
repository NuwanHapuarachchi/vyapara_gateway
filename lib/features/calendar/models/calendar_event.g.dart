// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarEvent _$CalendarEventFromJson(Map<String, dynamic> json) =>
    CalendarEvent(
      id: json['id'] as String,
      creatorId: json['creator_id'] as String,
      businessId: json['business_id'] as String?,
      applicationId: json['application_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventType: json['event_type'] as String,
      status: json['status'] as String,
      visibility: json['visibility'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      startTime: json['start_time'] as String,
      endDate: DateTime.parse(json['end_date'] as String),
      endTime: json['end_time'] as String,
      location: json['location'] as String?,
      meetingLink: json['meeting_link'] as String?,
      isOnline: json['is_online'] as bool,
      reminderMinutes: (json['reminder_minutes'] as num?)?.toInt(),
      sendEmailReminder: json['send_email_reminder'] as bool,
      sendSmsReminder: json['send_sms_reminder'] as bool,
      sendPushReminder: json['send_push_reminder'] as bool,
      color: json['color'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CalendarEventToJson(CalendarEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creator_id': instance.creatorId,
      'business_id': instance.businessId,
      'application_id': instance.applicationId,
      'title': instance.title,
      'description': instance.description,
      'event_type': instance.eventType,
      'status': instance.status,
      'visibility': instance.visibility,
      'start_date': instance.startDate.toIso8601String(),
      'start_time': instance.startTime,
      'end_date': instance.endDate.toIso8601String(),
      'end_time': instance.endTime,
      'location': instance.location,
      'meeting_link': instance.meetingLink,
      'is_online': instance.isOnline,
      'reminder_minutes': instance.reminderMinutes,
      'send_email_reminder': instance.sendEmailReminder,
      'send_sms_reminder': instance.sendSmsReminder,
      'send_push_reminder': instance.sendPushReminder,
      'color': instance.color,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
