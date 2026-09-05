import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../controllers/chat_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/conversation_model.dart';
import '../../models/message_model.dart';
import '../../widgets/custom_avatar.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/responsive_shell.dart';
import '../../widgets/typing_indicator.dart';

/// Screen 9 — Chat Conversation Screen with real-time simulated replies.
class ChatScreen extends StatefulWidget {
  final ConversationModel conversation;
  final bool isEmbedded;

  const ChatScreen({
    super.key,
    required this.conversation,
    this.isEmbedded = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;
  bool _showQuickEmojis = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatCtrl = context.read<ChatController>();
      chatCtrl.selectConversation(widget.conversation);
      _scrollToBottom(animate: false);
      chatCtrl.markAsRead(widget.conversation.id);
    });
  }

  @override
  void dispose() {
    context.read<ChatController>().setTyping(false);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;
    if (animate) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent + 80);
    }
  }

  void _handleSend([AttachmentType attachmentType = AttachmentType.none, String? attachmentData]) {
    final text = _textController.text.trim();
    if (text.isEmpty && attachmentType == AttachmentType.none) return;

    HapticFeedback.lightImpact();
    final chatCtrl = context.read<ChatController>();

    chatCtrl.sendMessage(
      text.isEmpty ? '📎 Attachment' : text,
      attachmentType: attachmentType,
      attachmentData: attachmentData,
    );
    chatCtrl.setTyping(false);

    _textController.clear();
    setState(() {
      _isComposing = false;
      _showQuickEmojis = false;
    });

    Future.delayed(const Duration(milliseconds: 100), () => _scrollToBottom());
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedXl),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Share Attachment',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAttachmentOption(
                      Icons.image_rounded,
                      'Photo & Video',
                      AppColors.primaryCyan,
                      () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Media upload requires Firebase Storage (Blaze plan). Text chat is fully working on the Spark plan! 💬'),
                            duration: Duration(seconds: 4),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    _buildAttachmentOption(
                      Icons.description_rounded,
                      'Document',
                      AppColors.accentBlue,
                      () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Document upload requires Firebase Storage (Blaze plan). Text chat is fully working on the Spark plan! 💬'),
                            duration: Duration(seconds: 4),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    _buildAttachmentOption(
                      Icons.mic_rounded,
                      'Voice Note',
                      AppColors.accentPurple,
                      () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Voice upload requires Firebase Storage (Blaze plan). Text chat is fully working on the Spark plan! 💬'),
                            duration: Duration(seconds: 4),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    _buildAttachmentOption(
                      Icons.location_on_rounded,
                      'Location',
                      AppColors.online,
                      () {
                        Navigator.pop(ctx);
                        _textController.text = '📍 Shared current location';
                        _handleSend();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDemoCallDialog(String callType) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedXl),
        title: Row(
          children: [
            Icon(
              callType == 'Video' ? Icons.videocam_rounded : Icons.call_rounded,
              color: AppColors.primaryCyan,
            ),
            const SizedBox(width: 10),
            Text('$callType Call', style: AppTypography.titleLarge),
          ],
        ),
        content: Text(
          'Connecting to ${widget.conversation.participant.name}...',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('End Call', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatCtrl = context.watch<ChatController>();
    final participant = widget.conversation.participant;
    final messages = chatCtrl.activeMessages;
    final isTyping = widget.conversation.isTyping;

    // Trigger auto-scroll on incoming message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollToBottom(animate: true);
      }
    });

    Widget content = Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leadingWidth: widget.isEmbedded ? 0 : 40,
        leading: widget.isEmbedded
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              ),
        title: Row(
          children: [
            CustomAvatar(
              name: participant.name,
              radius: 19,
              isOnline: participant.isOnline,
              showOnlineIndicator: true,
              gradientIndex: participant.avatarGradientIndex,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participant.name,
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    participant.isOnline ? AppStrings.online : 'Last seen ${DateFormatter.formatLastSeen(participant.lastSeen)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: participant.isOnline ? AppColors.online : AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined, size: 22),
            onPressed: () => _showDemoCallDialog('Audio'),
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, size: 24),
            onPressed: () => _showDemoCallDialog('Video'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 22),
            color: AppColors.surfaceElevated,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedL),
            onSelected: (val) {
              if (val == 'clear') {
                chatCtrl.deleteConversation(widget.conversation.id);
                if (!widget.isEmbedded) Navigator.of(context).pop();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mute',
                child: Text('Mute notifications'),
              ),
              const PopupMenuItem(
                value: 'search',
                child: Text('Search in chat'),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Delete conversation', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Message Stream Area
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        'Send a message to start chatting with ${participant.name} 👋',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final showDateHeader = index == 0 ||
                            !_isSameDay(messages[index - 1].timestamp, msg.timestamp);

                        return Column(
                          children: [
                            if (showDateHeader) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated.withValues(alpha: 0.8),
                                    borderRadius: AppRadius.roundedFull,
                                    border: Border.all(
                                      color: AppColors.surfaceBorder.withValues(alpha: 0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    DateFormatter.formatMessageGroupDate(msg.timestamp),
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            MessageBubble(
                              message: msg,
                              onReactionSelected: (emoji) {
                                chatCtrl.toggleReaction(msg.id, emoji);
                              },
                            ),
                          ],
                        );
                      },
                    ),
            ),

            // Live Typing Indicator
            if (isTyping) TypingIndicator(contactName: participant.name),

            // Quick Emoji Strip (Optional toggle)
            if (_showQuickEmojis) _buildQuickEmojiStrip(),

            // Message Composer Input Box
            _buildComposer(),
          ],
        ),
      ),
    );

    if (widget.isEmbedded) {
      return content;
    }

    return ResponsiveShell(child: content);
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  Widget _buildQuickEmojiStrip() {
    final emojis = ['❤️', '🔥', '😂', '👍', '🎉', '🚀', '✨', '👋', '💯'];

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: emojis.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _textController.text += emojis[index];
              setState(() => _isComposing = true);
            },
            child: Center(
              child: Text(emojis[index], style: const TextStyle(fontSize: 22)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.surfaceBorder.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 24, color: AppColors.primaryCyan),
            onPressed: _showAttachmentSheet,
          ),
          IconButton(
            icon: Icon(
              _showQuickEmojis ? Icons.keyboard_rounded : Icons.emoji_emotions_outlined,
              size: 22,
              color: AppColors.textTertiary,
            ),
            onPressed: () => setState(() => _showQuickEmojis = !_showQuickEmojis),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: AppRadius.roundedXl,
                border: Border.all(
                  color: AppColors.surfaceBorder.withValues(alpha: 0.6),
                  width: 1.0,
                ),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 4,
                minLines: 1,
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                cursorColor: AppColors.primaryCyan,
                decoration: const InputDecoration(
                  hintText: AppStrings.typeMessage,
                  hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (text) {
                  setState(() => _isComposing = text.trim().isNotEmpty);
                  context.read<ChatController>().setTyping(text.trim().isNotEmpty);
                },
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: _isComposing ? () => _handleSend() : () => _handleSend(AttachmentType.voiceNote, '0:15'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _isComposing ? AppColors.primaryGradient : null,
                color: _isComposing ? null : AppColors.surfaceElevated,
                boxShadow: _isComposing
                    ? [
                        BoxShadow(
                          color: AppColors.primaryCyan.withValues(alpha: 0.4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                _isComposing ? Icons.send_rounded : Icons.mic_rounded,
                size: 20,
                color: _isComposing ? AppColors.textOnPrimary : AppColors.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
