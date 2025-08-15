// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommunityQuestion _$CommunityQuestionFromJson(Map<String, dynamic> json) =>
    CommunityQuestion(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      businessTypeFilter: (json['businessTypeFilter'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      upvotes: (json['upvotes'] as num).toInt(),
      downvotes: (json['downvotes'] as num).toInt(),
      answerCount: (json['answerCount'] as num).toInt(),
      isAnswered: json['isAnswered'] as bool,
      isFeatured: json['isFeatured'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      authorName: json['authorName'] as String?,
      authorAvatar: json['authorAvatar'] as String?,
      answers: (json['answers'] as List<dynamic>?)
          ?.map((e) => CommunityAnswer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CommunityQuestionToJson(CommunityQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authorId': instance.authorId,
      'title': instance.title,
      'content': instance.content,
      'businessTypeFilter': instance.businessTypeFilter,
      'tags': instance.tags,
      'upvotes': instance.upvotes,
      'downvotes': instance.downvotes,
      'answerCount': instance.answerCount,
      'isAnswered': instance.isAnswered,
      'isFeatured': instance.isFeatured,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'authorName': instance.authorName,
      'authorAvatar': instance.authorAvatar,
      'answers': instance.answers,
    };
