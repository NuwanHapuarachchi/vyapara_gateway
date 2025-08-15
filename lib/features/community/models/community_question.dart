import 'package:json_annotation/json_annotation.dart';
import 'community_answer.dart';

part 'community_question.g.dart';

@JsonSerializable()
class CommunityQuestion {
  final String id;
  final String authorId;
  final String title;
  final String content;
  final List<String>? businessTypeFilter;
  final List<String>? tags;
  final int upvotes;
  final int downvotes;
  final int answerCount;
  final bool isAnswered;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields for display
  final String? authorName;
  final String? authorAvatar;
  final List<CommunityAnswer>? answers;

  CommunityQuestion({
    required this.id,
    required this.authorId,
    required this.title,
    required this.content,
    this.businessTypeFilter,
    this.tags,
    required this.upvotes,
    required this.downvotes,
    required this.answerCount,
    required this.isAnswered,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorAvatar,
    this.answers,
  });

  factory CommunityQuestion.fromJson(Map<String, dynamic> json) =>
      _$CommunityQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityQuestionToJson(this);

  // Helper methods
  int get totalVotes => upvotes - downvotes;

  bool get hasPositiveVotes => totalVotes > 0;

  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get displayTitle {
    if (title.length > 100) {
      return '${title.substring(0, 100)}...';
    }
    return title;
  }

  String get displayContent {
    if (content.length > 200) {
      return '${content.substring(0, 200)}...';
    }
    return content;
  }

  List<String> get displayTags {
    return tags?.take(5).toList() ?? [];
  }

  CommunityQuestion copyWith({
    String? id,
    String? authorId,
    String? title,
    String? content,
    List<String>? businessTypeFilter,
    List<String>? tags,
    int? upvotes,
    int? downvotes,
    int? answerCount,
    bool? isAnswered,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorName,
    String? authorAvatar,
    List<CommunityAnswer>? answers,
  }) {
    return CommunityQuestion(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      content: content ?? this.content,
      businessTypeFilter: businessTypeFilter ?? this.businessTypeFilter,
      tags: tags ?? this.tags,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      answerCount: answerCount ?? this.answerCount,
      isAnswered: isAnswered ?? this.isAnswered,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      answers: answers ?? this.answers,
    );
  }
}
