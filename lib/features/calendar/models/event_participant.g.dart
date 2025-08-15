// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventParticipant _$EventParticipantFromJson(Map<String, dynamic> json) =>
    EventParticipant(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      participantId: json['participantId'] as String,
      participantType: json['participantType'] as String,
      isRequired: json['isRequired'] as bool,
      responseStatus: json['responseStatus'] as String,
      responseNotes: json['responseNotes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$EventParticipantToJson(EventParticipant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'participantId': instance.participantId,
      'participantType': instance.participantType,
      'isRequired': instance.isRequired,
      'responseStatus': instance.responseStatus,
      'responseNotes': instance.responseNotes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
