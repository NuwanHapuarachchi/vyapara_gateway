import 'package:json_annotation/json_annotation.dart';

part 'community_answer.g.dart';

@JsonSerializable()
class CommunityAnswer {
  final String id;
  final String questionId;
  final String authorId;
  final String content;
  final int upvotes;
  final int downvotes;
  final bool isAccepted;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields for display
  final String? authorName;
  final String? authorAvatar;

  CommunityAnswer({
    required this.id,
    required this.questionId,
    required this.authorId,
    required this.content,
    required this.upvotes,
    required this.downvotes,
    required this.isAccepted,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorAvatar,
  });

  factory CommunityAnswer.fromJson(Map<String, dynamic> json) =>
      _$CommunityAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$CommunityAnswerToJson(this);

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

  String get displayContent {
    if (content.length > 300) {
      return '${content.substring(0, 300)}...';
    }
    return content;
  }

  CommunityAnswer copyWith({
    String? id,
    String? questionId,
    String? authorId,
    String? content,
    int? upvotes,
    int? downvotes,
    bool? isAccepted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorName,
    String? authorAvatar,
  }) {
    return CommunityAnswer(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      isAccepted: isAccepted ?? this.isAccepted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
    );
  }
}
