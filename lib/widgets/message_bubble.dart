import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import '../core/constants/app_typography.dart';
import '../core/theme/glass_effects.dart';
import '../core/utils/date_formatter.dart';
import '../models/message_model.dart';

/// Message bubble widget supporting incoming (dark glass) and outgoing (cyan gradient) styling.
class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool showAvatar;
  final void Function(String emoji)? onReactionSelected;

  const MessageBubble({
    super.key,
    required this.message,
    this.showAvatar = false,
    this.onReactionSelected,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showReactionMenu(BuildContext context) {
    HapticFeedback.lightImpact();
    final emojis = ['❤️', '👍', '🔥', '😂', '😮', '✨'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: AppRadius.roundedXl,
            border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: emojis.map((emoji) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onReactionSelected?.call(emoji);
                },
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildStatusTicks(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.textTertiary),
          ),
        );
      case MessageStatus.sent:
        return const Icon(Icons.check_rounded, size: 14, color: AppColors.textTertiary);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all_rounded, size: 14, color: AppColors.textTertiary);
      case MessageStatus.read:
        return const Icon(Icons.done_all_rounded, size: 14, color: AppColors.primaryCyan);
    }
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.message;
    final isOutgoing = msg.isOutgoing;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
            child: GestureDetector(
              onLongPress: () => _showReactionMenu(context),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.76,
                ),
                child: Column(
                  crossAxisAlignment: isOutgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: isOutgoing
                          ? GlassEffects.outgoingBubbleDecoration()
                          : GlassEffects.incomingBubbleDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (msg.attachmentType != AttachmentType.none) ...[
                            _buildAttachmentPreview(msg),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            msg.text,
                            style: AppTypography.bodyLarge.copyWith(
                              color: isOutgoing ? AppColors.textOnPrimary : AppColors.textPrimary,
                              fontWeight: isOutgoing ? FontWeight.w500 : FontWeight.w400,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                DateFormatter.formatMessageTime(msg.timestamp),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: isOutgoing
                                      ? AppColors.textOnPrimary.withValues(alpha: 0.65)
                                      : AppColors.textTertiary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (isOutgoing) ...[
                                const SizedBox(width: 4),
                                _buildStatusTicks(msg.status),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (msg.reactions.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 4,
                        children: msg.reactions.map((emoji) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: AppRadius.roundedFull,
                              border: Border.all(color: AppColors.surfaceBorder, width: 1),
                            ),
                            child: Text(emoji, style: const TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentPreview(MessageModel msg) {
    if (msg.attachmentType == AttachmentType.document) {
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.insert_drive_file_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msg.attachmentData ?? 'NexaTalk_Design.pdf',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '2.4 MB • PDF',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (msg.attachmentType == AttachmentType.image) {
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        width: 230,
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF133446), Color(0xFF0D2533)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.surfaceBorder, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Styled stylized vector mountain preview if image fails or local
            CustomPaint(
              painter: _MountainPreviewPainter(),
            ),
            if (msg.attachmentData != null && msg.attachmentData!.startsWith('http'))
              Image.network(
                msg.attachmentData!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => CustomPaint(painter: _MountainPreviewPainter()),
              ),
          ],
        ),
      );
    }

    if (msg.attachmentType == AttachmentType.voiceNote) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: AppRadius.roundedM,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_arrow_rounded, size: 20, color: AppColors.textPrimary),
            const SizedBox(width: 8),
            Container(
              width: 80,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppRadius.roundedFull,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              msg.attachmentData ?? '0:18',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _MountainPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky
    final sky = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0F3246), Color(0xFF1E526D), Color(0xFF38768C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), sky);

    // Distant mountain
    final m1 = Path()
      ..moveTo(0, h * 0.75)
      ..lineTo(w * 0.35, h * 0.25)
      ..lineTo(w * 0.65, h * 0.65)
      ..lineTo(w, h * 0.40)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(m1, Paint()..color = const Color(0xFF153342));

    // Foreground mountain
    final m2 = Path()
      ..moveTo(0, h * 0.60)
      ..lineTo(w * 0.22, h * 0.35)
      ..lineTo(w * 0.50, h * 0.70)
      ..lineTo(w * 0.78, h * 0.30)
      ..lineTo(w, h * 0.70)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(m2, Paint()..color = const Color(0xFF0A1F29));

    // Water lake
    final lake = Path()
      ..moveTo(0, h * 0.68)
      ..lineTo(w, h * 0.68)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      lake,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF09222E), Color(0xFF06151D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, h * 0.68, w, h * 0.32)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
