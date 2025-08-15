import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../models/community_question.dart';
import '../models/community_answer.dart';
import '../services/community_service.dart';
import 'question_detail_screen.dart';

/// Community Feed Screen for Q&A and discussions
class CommunityFeedScreen extends ConsumerStatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  ConsumerState<CommunityFeedScreen> createState() =>
      _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends ConsumerState<CommunityFeedScreen> {
  final TextEditingController _questionController = TextEditingController();
  final CommunityService _communityService = CommunityService();

  List<CommunityQuestion> _questions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedBusinessType = 'all';
  Map<String, String?> _userVotes =
      {}; // Cache user votes {questionId: voteType}

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() => _isLoading = true);
      final questions = await _communityService.getQuestions();

      // Load user votes for all questions
      await _loadUserVotes(questions);

      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading questions: $e')));
      }
    }
  }

  Future<void> _loadUserVotes(List<CommunityQuestion> questions) async {
    final votes = <String, String?>{};

    for (final question in questions) {
      try {
        final vote = await _communityService.getUserVote(
          question.id,
          'question',
        );
        votes[question.id] = vote;
      } catch (e) {
        votes[question.id] = null;
      }
    }

    setState(() {
      _userVotes = votes;
    });
  }

  Future<void> _searchQuestions(String query) async {
    if (query.isEmpty) {
      await _loadQuestions();
      return;
    }

    try {
      setState(() => _isLoading = true);
      final questions = await _communityService.searchQuestions(query);
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching questions: $e')),
        );
      }
    }
  }

  Future<void> _filterByBusinessType(String businessType) async {
    if (businessType == 'all') {
      await _loadQuestions();
      return;
    }

    try {
      setState(() => _isLoading = true);
      final questions = await _communityService.getQuestionsByBusinessType(
        businessType,
      );
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error filtering questions: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Navigate back to dashboard instead of exiting
          context.go('/dashboard');
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: null,
        body: RefreshIndicator(
          onRefresh: _loadQuestions,
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              _buildSearchAndFilterSection(),
              if (_isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (_questions.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildPostCard(_questions[index]),
                      childCount: _questions.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 10),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2B804).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.groups_outlined,
                color: Color(0xFFF2B804),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Community',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: AppColors.primary),
          onPressed: _showAskQuestionBottomSheet,
        ),
      ],
    );
  }

  Widget _buildPostCard(CommunityQuestion question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    (question.authorName ?? 'Anonymous')[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.authorName ?? 'Anonymous User',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        question.formattedCreatedAt,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (question.isFeatured)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Featured',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Question Title
            Text(
              question.title,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),

            if (question.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                question.displayContent,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Tags
            if (question.displayTags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                children: question.displayTags
                    .map(
                      (tag) => Chip(
                        label: Text(
                          '#$tag',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Stats and Actions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Upvote button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _userVotes[question.id] == 'upvote'
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        size: 20,
                        color: _userVotes[question.id] == 'upvote'
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      onPressed: () => _voteQuestion(question.id, true),
                    ),
                    Text(
                      '${question.upvotes}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                // Downvote button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _userVotes[question.id] == 'downvote'
                            ? Icons.thumb_down
                            : Icons.thumb_down_outlined,
                        size: 20,
                        color: _userVotes[question.id] == 'downvote'
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                      onPressed: () => _voteQuestion(question.id, false),
                    ),
                    Text(
                      '${question.downvotes}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                // Reply count
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => _navigateToQuestionDetail(question),
                    ),
                    Text(
                      '${question.answerCount}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                // Status and action buttons
                if (question.isAnswered)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Answered',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () => _navigateToQuestionDetail(question),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View Replies',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
                if (value.isNotEmpty) {
                  _searchQuestions(value);
                } else {
                  _loadQuestions();
                }
              },
              decoration: InputDecoration(
                hintText: 'Search questions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Filter Dropdown
            Row(
              children: [
                Text(
                  'Filter by business type:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedBusinessType,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Types')),
                      DropdownMenuItem(
                        value: 'sole_proprietorship',
                        child: Text('Sole Proprietorship'),
                      ),
                      DropdownMenuItem(
                        value: 'partnership',
                        child: Text('Partnership'),
                      ),
                      DropdownMenuItem(
                        value: 'private_limited',
                        child: Text('Private Limited'),
                      ),
                      DropdownMenuItem(
                        value: 'public_limited',
                        child: Text('Public Limited'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedBusinessType = value!);
                      _filterByBusinessType(value!);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_outlined,
            size: 64,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textSecondary
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No questions found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to ask a question to the community!',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAskQuestionBottomSheet,
            icon: const Icon(Icons.add),
            label: const Text('Ask a Question'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _voteQuestion(String questionId, bool isUpvote) async {
    final voteType = isUpvote ? 'upvote' : 'downvote';
    final currentVote = _userVotes[questionId];

    try {
      // Update local state immediately for better UX
      setState(() {
        if (currentVote == voteType) {
          // Remove vote if clicking same button
          _userVotes[questionId] = null;
        } else {
          // Set new vote
          _userVotes[questionId] = voteType;
        }
      });

      // Send to server
      await _communityService.voteQuestion(questionId, isUpvote);

      // Refresh questions to get updated counts
      await _loadQuestions();
    } catch (e) {
      // Revert local state on error
      setState(() {
        _userVotes[questionId] = currentVote;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error voting: $e')));
      }
    }
  }

  Future<void> _voteAnswer(String answerId, bool isUpvote) async {
    try {
      await _communityService.voteAnswer(answerId, isUpvote);
      // You could refresh the specific question or just show a success message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vote recorded!')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error voting: $e')));
      }
    }
  }

  Widget _buildReplyItem(CommunityAnswer reply) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.secondary,
            child: Text(
              (reply.authorName ?? 'Anonymous')[0].toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.surfaceDark
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        reply.authorName ?? 'Anonymous User',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        reply.formattedCreatedAt,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      if (reply.isAccepted) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Accepted',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reply.content,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              reply.upvotes > 0
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_outlined,
                              size: 16,
                              color: reply.upvotes > 0
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            onPressed: () => _voteAnswer(reply.id, true),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${reply.totalVotes}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAskQuestionBottomSheet() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final tagsController = TextEditingController();
    bool isPosting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ask a Question',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Question Title *',
                  hintText: 'What is your question about?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Question Details',
                  hintText: 'Provide more details about your question...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (optional)',
                  hintText: 'e.g., business, registration, tax',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isPosting
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isPosting
                          ? null
                          : () async {
                              if (titleController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter a question title',
                                    ),
                                  ),
                                );
                                return;
                              }

                              setModalState(() => isPosting = true);

                              try {
                                final user =
                                    Supabase.instance.client.auth.currentUser;
                                if (user == null) {
                                  throw Exception('User not authenticated');
                                }

                                final tags = tagsController.text.trim().isEmpty
                                    ? <String>[]
                                    : tagsController.text
                                          .split(',')
                                          .map((tag) => tag.trim())
                                          .toList();

                                final questionData = {
                                  'author_id': user.id,
                                  'title': titleController.text.trim(),
                                  'content': contentController.text.trim(),
                                  'tags': tags,
                                };

                                await _communityService.createQuestion(
                                  questionData,
                                );
                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Question posted successfully!',
                                    ),
                                  ),
                                );

                                // Refresh the questions list
                                _loadQuestions();
                              } catch (e) {
                                setModalState(() => isPosting = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error posting question: $e'),
                                  ),
                                );
                              }
                            },
                      child: isPosting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Post'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigate to question detail screen
  Future<void> _navigateToQuestionDetail(CommunityQuestion question) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionDetailScreen(question: question),
        ),
      );

      // Refresh questions if needed
      if (result == true) {
        _loadQuestions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening question details: $e')),
        );
      }
    }
  }

  // Show report dialog
  void _showReportDialog(String targetId, String targetType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Content'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Why are you reporting this $targetType?'),
            const SizedBox(height: 16),
            // Report reasons
            ...[
              'spam',
              'inappropriate',
              'harassment',
              'false_information',
              'other',
            ].map(
              (reason) => ListTile(
                title: Text(reason.replaceAll('_', ' ').toUpperCase()),
                onTap: () => _reportContent(targetId, targetType, reason),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Report content
  Future<void> _reportContent(
    String targetId,
    String targetType,
    String reason,
  ) async {
    try {
      Navigator.pop(context); // Close dialog
      await _communityService.reportContent(
        targetId: targetId,
        targetType: targetType,
        reason: reason,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content reported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error reporting content: $e')));
      }
    }
  }

  void _showRepliesBottomSheet(CommunityQuestion question) async {
    try {
      final questionWithAnswers = await _communityService
          .getQuestionWithAnswers(question.id);

      if (questionWithAnswers?.answers == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No answers found')));
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Answers (${questionWithAnswers!.answers!.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  questionWithAnswers.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: questionWithAnswers.answers!.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 48,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.textSecondary
                                    : AppColors.textSecondaryLight,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No answers yet',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.textSecondary
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Be the first to answer this question!',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.textSecondary
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: questionWithAnswers.answers!.length,
                          itemBuilder: (context, index) {
                            return _buildReplyItem(
                              questionWithAnswers.answers![index],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading answers: $e')));
    }
  }
}
