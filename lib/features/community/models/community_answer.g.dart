// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommunityAnswer _$CommunityAnswerFromJson(Map<String, dynamic> json) =>
    CommunityAnswer(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      authorId: json['authorId'] as String,
      content: json['content'] as String,
      upvotes: (json['upvotes'] as num).toInt(),
      downvotes: (json['downvotes'] as num).toInt(),
      isAccepted: json['isAccepted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      authorName: json['authorName'] as String?,
      authorAvatar: json['authorAvatar'] as String?,
    );

Map<String, dynamic> _$CommunityAnswerToJson(CommunityAnswer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'questionId': instance.questionId,
      'authorId': instance.authorId,
      'content': instance.content,
      'upvotes': instance.upvotes,
      'downvotes': instance.downvotes,
      'isAccepted': instance.isAccepted,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'authorName': instance.authorName,
      'authorAvatar': instance.authorAvatar,
    };
