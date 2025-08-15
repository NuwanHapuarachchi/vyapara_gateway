// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarEvent _$CalendarEventFromJson(Map<String, dynamic> json) =>
    CalendarEvent(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      businessId: json['businessId'] as String?,
      applicationId: json['applicationId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventType: json['eventType'] as String,
      status: json['status'] as String,
      visibility: json['visibility'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      startTime: json['startTime'] as String,
      endDate: DateTime.parse(json['endDate'] as String),
      endTime: json['endTime'] as String,
      location: json['location'] as String?,
      meetingLink: json['meetingLink'] as String?,
      isOnline: json['isOnline'] as bool,
      reminderMinutes: (json['reminderMinutes'] as num).toInt(),
      sendEmailReminder: json['sendEmailReminder'] as bool,
      sendSmsReminder: json['sendSmsReminder'] as bool,
      sendPushReminder: json['sendPushReminder'] as bool,
      color: json['color'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CalendarEventToJson(CalendarEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creatorId': instance.creatorId,
      'businessId': instance.businessId,
      'applicationId': instance.applicationId,
      'title': instance.title,
      'description': instance.description,
      'eventType': instance.eventType,
      'status': instance.status,
      'visibility': instance.visibility,
      'startDate': instance.startDate.toIso8601String(),
      'startTime': instance.startTime,
      'endDate': instance.endDate.toIso8601String(),
      'endTime': instance.endTime,
      'location': instance.location,
      'meetingLink': instance.meetingLink,
      'isOnline': instance.isOnline,
      'reminderMinutes': instance.reminderMinutes,
      'sendEmailReminder': instance.sendEmailReminder,
      'sendSmsReminder': instance.sendSmsReminder,
      'sendPushReminder': instance.sendPushReminder,
      'color': instance.color,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
