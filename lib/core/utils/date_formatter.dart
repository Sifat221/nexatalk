import 'package:intl/intl.dart';

/// Date and time formatting helpers for messages and conversations.
class DateFormatter {
  DateFormatter._();

  /// Format timestamp for chat list items (e.g. "10:42 AM", "Yesterday", "Mon", "Oct 12").
  static String formatChatListTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0 && now.day == dateTime.day) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (difference.inDays < 7 && now.weekday != dateTime.weekday) {
      return DateFormat('EEE').format(dateTime);
    } else if (now.year == dateTime.year) {
      return DateFormat('MMM d').format(dateTime);
    } else {
      return DateFormat('MM/dd/yy').format(dateTime);
    }
  }

  /// Format timestamp inside message bubbles (e.g. "10:42 AM").
  static String formatMessageTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Format message header grouping dates (e.g. "Today", "Yesterday", "October 14, 2026").
  static String formatMessageGroupDate(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
      return 'Today';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return 'Yesterday';
    }

    if (dateTime.year == now.year) {
      return DateFormat('MMMM d').format(dateTime);
    }

    return DateFormat('MMMM d, yyyy').format(dateTime);
  }

  /// Format contact's last seen time.
  static String formatLastSeen(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 2) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24 && now.day == dateTime.day) {
      return 'Today at ${DateFormat('h:mm a').format(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat('h:mm a').format(dateTime)}';
    } else {
      return DateFormat('MMM d at h:mm a').format(dateTime);
    }
  }
}
