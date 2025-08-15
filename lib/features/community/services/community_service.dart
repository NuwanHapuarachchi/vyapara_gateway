import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/community_question.dart';
import '../models/community_answer.dart';

class CommunityService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Getter for current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // Get all community questions with author info and answers
  Future<List<CommunityQuestion>> getQuestions() async {
    try {
      final response = await _supabase
          .from('community_questions')
          .select('''
            *,
            user_profiles!community_questions_author_id_fkey(
              full_name,
              profile_image_url
            )
          ''')
          .order('created_at', ascending: false);

      return response.map((json) {
        final userProfile = json['user_profiles'] as Map<String, dynamic>?;
        return CommunityQuestion.fromJson({
          ...json,
          'authorName': userProfile?['full_name'] ?? 'Anonymous User',
          'authorAvatar': userProfile?['profile_image_url'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch questions: $e');
    }
  }

  // Get a specific question with all its answers
  Future<CommunityQuestion?> getQuestionWithAnswers(String questionId) async {
    try {
      // Get the question
      final questionResponse = await _supabase
          .from('community_questions')
          .select('''
            *,
            user_profiles!community_questions_author_id_fkey(
              full_name,
              profile_image_url
            )
          ''')
          .eq('id', questionId)
          .single();

      // questionResponse is guaranteed to be non-null from single()

      // Get all answers for this question
      final answersResponse = await _supabase
          .from('community_answers')
          .select('''
            *,
            user_profiles!community_answers_author_id_fkey(
              full_name,
              profile_image_url
            )
          ''')
          .eq('question_id', questionId)
          .order('created_at', ascending: true);

      final answers = answersResponse.map((json) {
        final userProfile = json['user_profiles'] as Map<String, dynamic>?;
        return CommunityAnswer.fromJson({
          ...json,
          'authorName': userProfile?['full_name'] ?? 'Anonymous User',
          'authorAvatar': userProfile?['profile_image_url'],
        });
      }).toList();

      final userProfile =
          questionResponse['user_profiles'] as Map<String, dynamic>?;
      return CommunityQuestion.fromJson({
        ...questionResponse,
        'authorName': userProfile?['full_name'] ?? 'Anonymous User',
        'authorAvatar': userProfile?['avatar_url'],
        'answers': answers,
      });
    } catch (e) {
      throw Exception('Failed to fetch question: $e');
    }
  }

  // Create a new question
  Future<CommunityQuestion> createQuestion(
    Map<String, dynamic> questionData,
  ) async {
    try {
      final response = await _supabase
          .from('community_questions')
          .insert(questionData)
          .select()
          .single();

      return CommunityQuestion.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create question: $e');
    }
  }

  // Update a question
  Future<CommunityQuestion> updateQuestion(
    String questionId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _supabase
          .from('community_questions')
          .update(updates)
          .eq('id', questionId)
          .select()
          .single();

      return CommunityQuestion.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update question: $e');
    }
  }

  // Delete a question
  Future<void> deleteQuestion(String questionId) async {
    try {
      await _supabase.from('community_questions').delete().eq('id', questionId);
    } catch (e) {
      throw Exception('Failed to delete question: $e');
    }
  }

  // Add an answer to a question
  Future<CommunityAnswer> addAnswer(Map<String, dynamic> answerData) async {
    try {
      final response = await _supabase
          .from('community_answers')
          .insert(answerData)
          .select()
          .single();

      // Update the answer count for the question
      await _supabase
          .from('community_questions')
          .update({'answer_count': answerData['answer_count']})
          .eq('id', answerData['question_id']);

      return CommunityAnswer.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add answer: $e');
    }
  }

  // Update an answer
  Future<CommunityAnswer> updateAnswer(
    String answerId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _supabase
          .from('community_answers')
          .update(updates)
          .eq('id', answerId)
          .select()
          .single();

      return CommunityAnswer.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update answer: $e');
    }
  }

  // Delete an answer
  Future<void> deleteAnswer(String answerId) async {
    try {
      await _supabase.from('community_answers').delete().eq('id', answerId);
    } catch (e) {
      throw Exception('Failed to delete answer: $e');
    }
  }

  // Vote on a question with proper user tracking
  Future<void> voteQuestion(String questionId, bool isUpvote) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final voteType = isUpvote ? 'upvote' : 'downvote';

      // Check if user has already voted
      final existingVote = await _supabase
          .from('user_votes')
          .select()
          .eq('user_id', userId)
          .eq('target_type', 'question')
          .eq('target_id', questionId)
          .maybeSingle();

      if (existingVote != null) {
        // User has already voted
        if (existingVote['vote_type'] == voteType) {
          // Same vote type - remove vote (toggle off)
          await _supabase
              .from('user_votes')
              .delete()
              .eq('id', existingVote['id']);
        } else {
          // Different vote type - update vote
          await _supabase
              .from('user_votes')
              .update({'vote_type': voteType})
              .eq('id', existingVote['id']);
        }
      } else {
        // New vote
        await _supabase.from('user_votes').insert({
          'user_id': userId,
          'target_type': 'question',
          'target_id': questionId,
          'vote_type': voteType,
        });
      }
    } catch (e) {
      throw Exception('Failed to vote on question: $e');
    }
  }

  // Vote on an answer with proper user tracking
  Future<void> voteAnswer(String answerId, bool isUpvote) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final voteType = isUpvote ? 'upvote' : 'downvote';

      // Check if user has already voted
      final existingVote = await _supabase
          .from('user_votes')
          .select()
          .eq('user_id', userId)
          .eq('target_type', 'answer')
          .eq('target_id', answerId)
          .maybeSingle();

      if (existingVote != null) {
        // User has already voted
        if (existingVote['vote_type'] == voteType) {
          // Same vote type - remove vote (toggle off)
          await _supabase
              .from('user_votes')
              .delete()
              .eq('id', existingVote['id']);
        } else {
          // Different vote type - update vote
          await _supabase
              .from('user_votes')
              .update({'vote_type': voteType})
              .eq('id', existingVote['id']);
        }
      } else {
        // New vote
        await _supabase.from('user_votes').insert({
          'user_id': userId,
          'target_type': 'answer',
          'target_id': answerId,
          'vote_type': voteType,
        });
      }
    } catch (e) {
      throw Exception('Failed to vote on answer: $e');
    }
  }

  // Accept an answer
  Future<void> acceptAnswer(String answerId, String questionId) async {
    try {
      // First, unaccept all other answers for this question
      await _supabase
          .from('community_answers')
          .update({'is_accepted': false})
          .eq('question_id', questionId);

      // Then accept the selected answer
      await _supabase
          .from('community_answers')
          .update({'is_accepted': true})
          .eq('id', answerId);

      // Mark the question as answered
      await _supabase
          .from('community_questions')
          .update({'is_answered': true})
          .eq('id', questionId);
    } catch (e) {
      throw Exception('Failed to accept answer: $e');
    }
  }

  // Search questions by title or content
  Future<List<CommunityQuestion>> searchQuestions(String query) async {
    try {
      final response = await _supabase
          .from('community_questions')
          .select('''
            *,
            user_profiles!community_questions_author_id_fkey(
              full_name,
              profile_image_url
            )
          ''')
          .or('title.ilike.%$query%,content.ilike.%$query%')
          .order('created_at', ascending: false);

      return response.map((json) {
        final userProfile = json['user_profiles'] as Map<String, dynamic>?;
        return CommunityQuestion.fromJson({
          ...json,
          'authorName': userProfile?['full_name'] ?? 'Anonymous User',
          'authorAvatar': userProfile?['profile_image_url'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to search questions: $e');
    }
  }

  // Get questions by tags
  Future<List<CommunityQuestion>> getQuestionsByTags(List<String> tags) async {
    try {
      final response = await _supabase
          .from('community_questions')
          .select('''
            *,
            user_profiles!community_questions_author_id_fkey(
              full_name,
              profile_image_url
            )
          ''')
          .overlaps('tags', tags)
          .order('created_at', ascending: false);

      return response.map((json) {
        final userProfile = json['user_profiles'] as Map<String, dynamic>?;
        return CommunityQuestion.fromJson({
          ...json,
          'authorName': userProfile?['full_name'] ?? 'Anonymous User',
          'authorAvatar': userProfile?['profile_image_url'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch questions by tags: $e');
    }
  }

  // Get featured questions
  Future<List<CommunityQuestion>> getFeaturedQuestions() async {
    try {
      final response = await _supabase
          .from('community_questions')
          .select('''
            *,
            user_profiles!community_questions_author_id_fkey(
              full_name,
              profile_image_url
            )
          ''')
          .eq('is_featured', true)
          .order('created_at', ascending: false);

      return response.map((json) {
        final userProfile = json['user_profiles'] as Map<String, dynamic>?;
        return CommunityQuestion.fromJson({
          ...json,
          'authorName': userProfile?['full_name'] ?? 'Anonymous User',
          'authorAvatar': userProfile?['profile_image_url'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch featured questions: $e');
    }
  }

  // Get questions by business type
  Future<List<CommunityQuestion>> getQuestionsByBusinessType(
    String businessType,
  ) async {
    try {
      final response = await _supabase
          .from('community_questions')
          .select('''
            *,
            user_profiles!community_questions_author_id_fkey(
              full_name,
              profile_image_url
            )
          ''')
          .contains('business_type_filter', [businessType])
          .order('created_at', ascending: false);

      return response.map((json) {
        final userProfile = json['user_profiles'] as Map<String, dynamic>?;
        return CommunityQuestion.fromJson({
          ...json,
          'authorName': userProfile?['full_name'] ?? 'Anonymous User',
          'authorAvatar': userProfile?['profile_image_url'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch questions by business type: $e');
    }
  }

  // Get user's questions
  Future<List<CommunityQuestion>> getUserQuestions(String userId) async {
    try {
      final response = await _supabase
          .from('community_questions')
          .select('''
            *,
            user_profiles!community_questions_author_id_fkey(
              full_name,
              profile_image_url
            )
          ''')
          .eq('author_id', userId)
          .order('created_at', ascending: false);

      return response.map((json) {
        final userProfile = json['user_profiles'] as Map<String, dynamic>?;
        return CommunityQuestion.fromJson({
          ...json,
          'authorName': userProfile?['full_name'] ?? 'Anonymous User',
          'authorAvatar': userProfile?['profile_image_url'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch user questions: $e');
    }
  }

  // Get user's answers
  Future<List<CommunityAnswer>> getUserAnswers(String userId) async {
    try {
      final response = await _supabase
          .from('community_answers')
          .select('''
            *,
            user_profiles!community_answers_author_id_fkey(
              full_name,
              profile_image_url
            )
          ''')
          .eq('author_id', userId)
          .order('created_at', ascending: false);

      return response.map((json) {
        final userProfile = json['user_profiles'] as Map<String, dynamic>?;
        return CommunityAnswer.fromJson({
          ...json,
          'authorName': userProfile?['full_name'] ?? 'Anonymous User',
          'authorAvatar': userProfile?['profile_image_url'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch user answers: $e');
    }
  }

  // Get user's current vote on a question or answer
  Future<String?> getUserVote(String targetId, String targetType) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('user_votes')
          .select('vote_type')
          .eq('user_id', userId)
          .eq('target_type', targetType)
          .eq('target_id', targetId)
          .maybeSingle();

      return response?['vote_type'];
    } catch (e) {
      return null; // Return null if no vote found or error
    }
  }

  // Report inappropriate content
  Future<void> reportContent({
    required String targetId,
    required String targetType,
    required String reason,
    String? description,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase.from('community_reports').insert({
        'reporter_id': userId,
        'target_type': targetType,
        'target_id': targetId,
        'reason': reason,
        'description': description,
      });
    } catch (e) {
      throw Exception('Failed to report content: $e');
    }
  }

  // Check if user has reported content
  Future<bool> hasUserReported(String targetId, String targetType) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('community_reports')
          .select('id')
          .eq('reporter_id', userId)
          .eq('target_type', targetType)
          .eq('target_id', targetId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Get all reports (admin only)
  Future<List<Map<String, dynamic>>> getReports({String? status}) async {
    try {
      var query = _supabase.from('community_reports').select('''
            *,
            user_profiles!community_reports_reporter_id_fkey(
              full_name,
              email
            )
          ''');

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch reports: $e');
    }
  }

  // Update report status (admin only)
  Future<void> updateReportStatus({
    required String reportId,
    required String status,
    String? resolutionNotes,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{
        'status': status,
        'reviewed_by': userId,
        'reviewed_at': DateTime.now().toIso8601String(),
      };

      if (resolutionNotes != null) {
        updates['resolution_notes'] = resolutionNotes;
      }

      await _supabase
          .from('community_reports')
          .update(updates)
          .eq('id', reportId);
    } catch (e) {
      throw Exception('Failed to update report status: $e');
    }
  }
}
