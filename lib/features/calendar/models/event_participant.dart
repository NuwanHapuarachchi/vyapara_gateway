import 'package:json_annotation/json_annotation.dart';

part 'event_participant.g.dart';

@JsonSerializable()
class EventParticipant {
  final String id;
  final String eventId;
  final String participantId;
  final String participantType;
  final bool isRequired;
  final String responseStatus;
  final String? responseNotes;
  final DateTime createdAt;

  EventParticipant({
    required this.id,
    required this.eventId,
    required this.participantId,
    required this.participantType,
    required this.isRequired,
    required this.responseStatus,
    this.responseNotes,
    required this.createdAt,
  });

  factory EventParticipant.fromJson(Map<String, dynamic> json) =>
      _$EventParticipantFromJson(json);

  Map<String, dynamic> toJson() => _$EventParticipantToJson(this);

  String get participantTypeDisplay {
    switch (participantType) {
      case 'creator':
        return 'Creator';
      case 'partner':
        return 'Business Partner';
      case 'lawyer':
        return 'Lawyer';
      case 'mentor':
        return 'Mentor';
      case 'guest':
        return 'Guest';
      default:
        return 'Participant';
    }
  }

  String get responseStatusDisplay {
    switch (responseStatus) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'declined':
        return 'Declined';
      case 'tentative':
        return 'Tentative';
      default:
        return 'Unknown';
    }
  }

  bool get hasResponded {
    return responseStatus != 'pending';
  }

  bool get isAccepted {
    return responseStatus == 'accepted';
  }

  bool get isDeclined {
    return responseStatus == 'declined';
  }

  EventParticipant copyWith({
    String? id,
    String? eventId,
    String? participantId,
    String? participantType,
    bool? isRequired,
    String? responseStatus,
    String? responseNotes,
    DateTime? createdAt,
  }) {
    return EventParticipant(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      participantId: participantId ?? this.participantId,
      participantType: participantType ?? this.participantType,
      isRequired: isRequired ?? this.isRequired,
      responseStatus: responseStatus ?? this.responseStatus,
      responseNotes: responseNotes ?? this.responseNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
