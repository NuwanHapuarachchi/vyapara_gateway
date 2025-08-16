import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/routing/app_router.dart';

/// Mentor Chat Screen for one-on-one mentorship
class MentorChatScreen extends ConsumerStatefulWidget {
  final String mentorId;

  const MentorChatScreen({super.key, required this.mentorId});

  @override
  ConsumerState<MentorChatScreen> createState() => _MentorChatScreenState();
}

class _MentorChatScreenState extends ConsumerState<MentorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  String? _sessionId;
  UserRole? _otherRole;
  String? _otherName;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    // Fetch other participant profile first so header/back work even if session fails
    final profile = await SupabaseService.getUserProfile(widget.mentorId);
    if (profile != null) {
      if (mounted) {
        setState(() {
          _otherRole = profile.role;
          _otherName = profile.fullName;
        });
      }
    }

    final session = await SupabaseService.getOrCreateDirectChatSession(
      widget.mentorId,
      sessionTitle: 'Mentorship Chat',
    );
    if (!mounted) return;
    if (session == null) {
      // Session not available (e.g., schema not updated). Keep header populated and return gracefully.
      return;
    }
    setState(() => _sessionId = session['id'] as String);

    final rows = await SupabaseService.getSessionMessages(_sessionId!);
    if (!mounted) return;
    setState(() {
      _messages
        ..clear()
        ..addAll(
          rows.map((m) {
            final metadata = m['metadata'] as Map<String, dynamic>?;
            final isFromMentor =
                (metadata?['sender_id'] ?? '') == widget.mentorId;
            return ChatMessage(
              text: (m['content'] as String?) ?? '',
              isFromMentor: isFromMentor,
              timestamp:
                  DateTime.tryParse((m['created_at'] as String?) ?? '') ??
                  DateTime.now(),
            );
          }),
        );
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isFromMentor: false, timestamp: DateTime.now()),
      );
    });

    _messageController.clear();
    _scrollToBottom();
    if (_sessionId != null) {
      await SupabaseService.sendSessionMessage(
        sessionId: _sessionId!,
        content: text,
      );
    }
  }

  // Removed mock responder; real messages are persisted via Supabase

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _navigateBack();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateBack,
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Text(
                  (_otherName != null && _otherName!.isNotEmpty)
                      ? _otherName![0]
                      : '?',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _otherName ?? 'Chat',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    if (_otherRole != null)
                      Text(
                        _otherRole == UserRole.lawyer ? 'Lawyer' : 'Mentor',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.success,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.videocam_outlined),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Video call feature coming soon!'),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.phone_outlined),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Voice call feature coming soon!'),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Mentor Session Info
            _buildSessionInfo(),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),

            // Message Input
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, color: AppColors.accent, size: 20),
          const SizedBox(width: 8),
          Text(
            'Session time remaining: 45 minutes',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session extension feature coming soon!'),
                ),
              );
            },
            child: const Text('Extend'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isFromMentor
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isFromMentor) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isFromMentor
                    ? (isDark ? AppColors.cardDark : const Color(0xFFF5F5F5))
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: message.isFromMentor
                          ? (isDark
                                ? AppColors.textPrimary
                                : AppColors.textPrimaryLight)
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: message.isFromMentor
                          ? (isDark
                                ? AppColors.textTertiary
                                : AppColors.textTertiaryLight)
                          : AppColors.textPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!message.isFromMentor) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.secondary.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                color: AppColors.secondary,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderLight : AppColors.borderLightTheme,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.attach_file,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('File attachment coming soon!')),
              );
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.cardDark
                    : const Color(0xFFF4F4F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(
                Icons.send_rounded,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _navigateBack() {
    if (_otherRole == UserRole.lawyer) {
      AppNavigation.toLawyers(context);
    } else {
      AppNavigation.toMentors(context);
    }
  }
}

/// Chat message model
class ChatMessage {
  final String text;
  final bool isFromMentor;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isFromMentor,
    required this.timestamp,
  });
}
