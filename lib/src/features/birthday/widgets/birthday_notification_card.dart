import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/birthday_models.dart';

/// 誕生日通知カードウィジェット
class BirthdayNotificationCard extends ConsumerWidget {
  final BirthdayNotification notification;
  final VoidCallback? onTap;

  const BirthdayNotificationCard({
    Key? key,
    required this.notification,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: notification.isRead 
                  ? const Color(0xFF2A2A2A) 
                  : const Color(0xFF2A2A2A).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: notification.isRead 
                    ? const Color(0xFF333333) 
                    : const Color(0xFF4ECDC4),
                width: notification.isRead ? 1 : 2,
              ),
            ),
            child: Row(
              children: [
                // 通知アイコン
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getNotificationColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    _getNotificationIcon(),
                    color: _getNotificationColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // 通知内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getNotificationTitle(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: notification.isRead 
                                    ? FontWeight.normal 
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4ECDC4),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: notification.isRead 
                              ? Colors.grey 
                              : Colors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.grey,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateTime(notification.sentAt),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.cake,
                            color: Colors.grey,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('M/d', 'ja_JP').format(notification.birthdayDate),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 通知タイプに応じた色を取得
  Color _getNotificationColor() {
    switch (notification.notificationType) {
      case BirthdayNotificationType.birthdayToday:
        return const Color(0xFF4ECDC4);
      case BirthdayNotificationType.birthdayUpcoming:
        return const Color(0xFFFFE66D);
      case BirthdayNotificationType.custom:
        return const Color(0xFFFF6B6B);
    }
  }

  /// 通知タイプに応じたアイコンを取得
  IconData _getNotificationIcon() {
    switch (notification.notificationType) {
      case BirthdayNotificationType.birthdayToday:
        return Icons.celebration;
      case BirthdayNotificationType.birthdayUpcoming:
        return Icons.schedule;
      case BirthdayNotificationType.custom:
        return Icons.message;
    }
  }

  /// 通知タイプに応じたタイトルを取得
  String _getNotificationTitle() {
    switch (notification.notificationType) {
      case BirthdayNotificationType.birthdayToday:
        return '🎂 誕生日おめでとう！';
      case BirthdayNotificationType.birthdayUpcoming:
        return '🎈 誕生日が近づいています';
      case BirthdayNotificationType.custom:
        return '📩 カスタム通知';
    }
  }

  /// 日時をフォーマット
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }
}