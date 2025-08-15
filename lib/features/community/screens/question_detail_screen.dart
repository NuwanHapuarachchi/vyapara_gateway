import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/community_question.dart';
import '../models/community_answer.dart';
import '../services/community_service.dart';

class QuestionDetailScreen extends StatefulWidget {
  final CommunityQuestion question;

  const QuestionDetailScreen({super.key, required this.question});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final CommunityService _communityService = CommunityService();
  final TextEditingController _answerController = TextEditingController();

  CommunityQuestion? _question;
  List<CommunityAnswer> _answers = [];
  bool _isLoading = true;
  bool _isSubmittingAnswer = false;

  @override
  void initState() {
    super.initState();
    _question = widget.question;
    _loadQuestionWithAnswers();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestionWithAnswers() async {
    try {
      setState(() => _isLoading = true);
      final questionWithAnswers = await _communityService
          .getQuestionWithAnswers(_question!.id);

      if (questionWithAnswers != null) {
        setState(() {
          _question = questionWithAnswers;
          _answers = questionWithAnswers.answers ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading question: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildQuestionCard(),
                        const SizedBox(height: 24),
                        _buildAnswersSection(),
                      ],
                    ),
                  ),
                ),
                _buildAnswerInput(),
              ],
            ),
    );
  }

  Widget _buildQuestionCard() {
    if (_question == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    (_question!.authorName ?? 'Anonymous')[0].toUpperCase(),
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
                        _question!.authorName ?? 'Anonymous User',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _question!.formattedCreatedAt,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_question!.isFeatured)
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

            // Question title
            Text(
              _question!.title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            // Question content
            if (_question!.content.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_question!.content, style: GoogleFonts.inter(fontSize: 14)),
            ],

            // Tags
            if (_question!.displayTags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: _question!.displayTags
                    .map(
                      (tag) => Chip(
                        label: Text(
                          tag,
                          style: GoogleFonts.inter(fontSize: 12),
                        ),
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],

            const SizedBox(height: 16),

            // Vote section
            Row(
              children: [
                FutureBuilder<String?>(
                  future: _communityService.getUserVote(
                    _question!.id,
                    'question',
                  ),
                  builder: (context, snapshot) {
                    final userVote = snapshot.data;
                    return Row(
                      children: [
                        // Upvote
                        IconButton(
                          icon: Icon(
                            userVote == 'upvote'
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined,
                            color: userVote == 'upvote'
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          onPressed: () => _voteOnQuestion(true),
                        ),
                        Text('${_question!.upvotes}'),
                        const SizedBox(width: 16),
                        // Downvote
                        IconButton(
                          icon: Icon(
                            userVote == 'downvote'
                                ? Icons.thumb_down
                                : Icons.thumb_down_outlined,
                            color: userVote == 'downvote'
                                ? AppColors.error
                                : AppColors.textSecondary,
                          ),
                          onPressed: () => _voteOnQuestion(false),
                        ),
                        Text('${_question!.downvotes}'),
                      ],
                    );
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.flag_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => _showReportDialog(_question!.id, 'question'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Answers (${_answers.length})',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        if (_answers.isEmpty)
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No answers yet',
                  style: GoogleFonts.inter(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to answer this question!',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ...(_answers.map((answer) => _buildAnswerCard(answer))),
      ],
    );
  }

  Widget _buildAnswerCard(CommunityAnswer answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.secondary,
                  child: Text(
                    (answer.authorName ?? 'Anonymous')[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        answer.authorName ?? 'Anonymous User',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        answer.formattedCreatedAt,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (answer.isAccepted)
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
            ),
            const SizedBox(height: 12),

            // Answer content
            Text(answer.content, style: GoogleFonts.inter(fontSize: 14)),

            const SizedBox(height: 12),

            // Vote section
            Row(
              children: [
                FutureBuilder<String?>(
                  future: _communityService.getUserVote(answer.id, 'answer'),
                  builder: (context, snapshot) {
                    final userVote = snapshot.data;
                    return Row(
                      children: [
                        // Upvote
                        IconButton(
                          icon: Icon(
                            userVote == 'upvote'
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined,
                            size: 18,
                            color: userVote == 'upvote'
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          onPressed: () => _voteOnAnswer(answer.id, true),
                        ),
                        Text(
                          '${answer.upvotes}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        // Downvote
                        IconButton(
                          icon: Icon(
                            userVote == 'downvote'
                                ? Icons.thumb_down
                                : Icons.thumb_down_outlined,
                            size: 18,
                            color: userVote == 'downvote'
                                ? AppColors.error
                                : AppColors.textSecondary,
                          ),
                          onPressed: () => _voteOnAnswer(answer.id, false),
                        ),
                        Text(
                          '${answer.downvotes}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    );
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.flag_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => _showReportDialog(answer.id, 'answer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _answerController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Write your answer...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: _isSubmittingAnswer
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            onPressed: _isSubmittingAnswer ? null : _submitAnswer,
          ),
        ],
      ),
    );
  }

  Future<void> _voteOnQuestion(bool isUpvote) async {
    try {
      await _communityService.voteQuestion(_question!.id, isUpvote);
      await _loadQuestionWithAnswers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error voting: $e')));
      }
    }
  }

  Future<void> _voteOnAnswer(String answerId, bool isUpvote) async {
    try {
      await _communityService.voteAnswer(answerId, isUpvote);
      await _loadQuestionWithAnswers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error voting: $e')));
      }
    }
  }

  Future<void> _submitAnswer() async {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter an answer')));
      return;
    }

    try {
      setState(() => _isSubmittingAnswer = true);

      await _communityService.addAnswer({
        'question_id': _question!.id,
        'author_id': _communityService.currentUserId,
        'content': _answerController.text.trim(),
      });

      _answerController.clear();
      await _loadQuestionWithAnswers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Answer submitted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error submitting answer: $e')));
      }
    } finally {
      setState(() => _isSubmittingAnswer = false);
    }
  }

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
}
