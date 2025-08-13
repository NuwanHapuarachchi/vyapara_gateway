import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

/// Community Feed Screen for Q&A and discussions
class CommunityFeedScreen extends ConsumerStatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  ConsumerState<CommunityFeedScreen> createState() =>
      _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends ConsumerState<CommunityFeedScreen> {
  final TextEditingController _questionController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mock community posts
    final posts = _getMockPosts();

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
        appBar: AppBar(
          title: Text(
            'Community',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: null,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.primary),
              onPressed: _showAskQuestionBottomSheet,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            // TODO: Implement refresh functionality
            await Future.delayed(const Duration(seconds: 1));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length + 1, // +1 for header
            itemBuilder: (context, index) {
              if (index == 0) {
                // Topic Header
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Community Discussions',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFA9A9A9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ask questions, share insights, and connect with other business owners',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return _buildPostCard(posts[index - 1]); // -1 because of header
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(CommunityPost post) {
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
                    post.userName[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: null,
                        ),
                      ),
                      Text(
                        _formatTimeAgo(post.createdAt),
                        style: GoogleFonts.inter(fontSize: 12, color: null),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Question
            Text(
              post.question,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: null,
                fontWeight: FontWeight.w500,
              ),
            ),

            if (post.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                post.description,
                style: GoogleFonts.inter(fontSize: 14, color: null),
              ),
            ],

            const SizedBox(height: 12),

            // Hashtags
            if (post.hashtags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                children: post.hashtags
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

            // Actions
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.thumb_up_outlined, size: 18),
                  label: Text('${post.likes}'),
                ),
                TextButton.icon(
                  onPressed: () {
                    _showRepliesBottomSheet(post);
                  },
                  icon: const Icon(Icons.comment_outlined, size: 18),
                  label: Text('${post.replies.length} replies'),
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('Share')),
              ],
            ),

            // Recent Replies
            if (post.replies.isNotEmpty) ...[
              const Divider(),
              ...post.replies.take(2).map((reply) => _buildReplyItem(reply)),
              if (post.replies.length > 2) ...[
                TextButton(
                  onPressed: () {
                    _showRepliesBottomSheet(post);
                  },
                  child: Text('View all ${post.replies.length} replies'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReplyItem(Reply reply) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.secondary,
            child: Text(
              reply.userName[0].toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        reply.userName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTimeAgo(reply.createdAt),
                        style: GoogleFonts.inter(fontSize: 11, color: null),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reply.content,
                    style: GoogleFonts.inter(fontSize: 13, color: null),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
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
                color: null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _questionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'What would you like to ask the community?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement post question functionality
                      Navigator.pop(context);
                      _questionController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Question posted successfully!'),
                        ),
                      );
                    },
                    child: const Text('Post'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRepliesBottomSheet(CommunityPost post) {
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
                'Replies',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: null,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: post.replies.length,
                  itemBuilder: (context, index) {
                    return _buildReplyItem(post.replies[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

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

  List<CommunityPost> _getMockPosts() {
    return [
      CommunityPost(
        id: '1',
        userName: 'Priya Silva',
        question: 'How long does business registration usually take?',
        description:
            'I submitted my application 2 weeks ago and haven\'t heard back yet. Is this normal?',
        hashtags: ['business', 'registration', 'timeline'],
        likes: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        replies: [
          Reply(
            userName: 'Mentor John',
            content:
                'Typically takes 10-15 business days. You should receive an update soon!',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          Reply(
            userName: 'Saman Perera',
            content: 'Mine took exactly 12 days. Don\'t worry, it\'s normal.',
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ],
      ),
      CommunityPost(
        id: '2',
        userName: 'Kasun Fernando',
        question: 'What documents are required for VAT registration?',
        description: '',
        hashtags: ['vat', 'documents', 'tax'],
        likes: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        replies: [
          Reply(
            userName: 'Tax Expert Maya',
            content:
                'You\'ll need business registration certificate, bank statements, and projected income details.',
            createdAt: DateTime.now().subtract(const Duration(hours: 12)),
          ),
        ],
      ),
    ];
  }
}

/// Community post model
class CommunityPost {
  final String id;
  final String userName;
  final String question;
  final String description;
  final List<String> hashtags;
  final int likes;
  final DateTime createdAt;
  final List<Reply> replies;

  CommunityPost({
    required this.id,
    required this.userName,
    required this.question,
    required this.description,
    required this.hashtags,
    required this.likes,
    required this.createdAt,
    required this.replies,
  });
}

/// Reply model
class Reply {
  final String userName;
  final String content;
  final DateTime createdAt;

  Reply({
    required this.userName,
    required this.content,
    required this.createdAt,
  });
}
