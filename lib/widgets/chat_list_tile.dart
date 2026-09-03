import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import '../core/constants/app_typography.dart';
import '../core/utils/date_formatter.dart';
import '../models/conversation_model.dart';
import 'custom_avatar.dart';

/// Conversation item in the chat list.
class ChatListTile extends StatefulWidget {
  final ConversationModel conversation;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ChatListTile({
    super.key,
    required this.conversation,
    this.isSelected = false,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<ChatListTile> createState() => _ChatListTileState();
}

class _ChatListTileState extends State<ChatListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final conv = widget.conversation;
    final participant = conv.participant;
    final hasUnread = conv.unreadCount > 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primaryDark.withValues(alpha: 0.25)
                : _isHovered
                    ? AppColors.surfaceHighlight.withValues(alpha: 0.4)
                    : AppColors.surface.withValues(alpha: 0.6),
            borderRadius: AppRadius.roundedL,
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primaryCyan.withValues(alpha: 0.6)
                  : _isHovered
                      ? AppColors.surfaceBorder.withValues(alpha: 0.7)
                      : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              CustomAvatar(
                name: participant.name,
                radius: 26,
                isOnline: participant.isOnline,
                showOnlineIndicator: true,
                gradientIndex: participant.avatarGradientIndex,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  participant.name,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (conv.isPinned) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.push_pin_rounded,
                                  size: 14,
                                  color: AppColors.primaryCyan,
                                ),
                              ],
                              if (conv.isMuted) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.volume_off_rounded,
                                  size: 14,
                                  color: AppColors.textTertiary,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          DateFormatter.formatChatListTimestamp(conv.updatedAt),
                          style: AppTypography.bodySmall.copyWith(
                            color: hasUnread ? AppColors.primaryCyan : AppColors.textTertiary,
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: conv.isTyping
                              ? Text(
                                  'typing...',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.primaryCyan,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : Text(
                                  conv.lastMessage?.text ?? 'No messages yet',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: hasUnread ? AppColors.textPrimary : AppColors.textSecondary,
                                    fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryCyan,
                              borderRadius: AppRadius.roundedFull,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryCyan.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Text(
                              conv.unreadCount > 99 ? '99+' : '${conv.unreadCount}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
