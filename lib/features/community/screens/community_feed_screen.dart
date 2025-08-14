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
        appBar: null,
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
          },
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildPostCard(posts[index]),
                    childCount: posts.length,
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
                        post.userName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        _formatTimeAgo(post.createdAt),
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
              ],
            ),

            const SizedBox(height: 16),

            // Question
            Text(
              post.question,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),

            if (post.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                post.description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
                ),
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
                        reply.userName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTimeAgo(reply.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight,
                        ),
                      ),
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
                color: Theme.of(context).colorScheme.onSurface,
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
                  color: Theme.of(context).colorScheme.onSurface,
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
