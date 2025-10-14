import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/birthday_models.dart';

/// 近日誕生日ウィジェット
class UpcomingBirthdayWidget extends ConsumerWidget {
  final BirthdayStar star;
  final VoidCallback? onTap;

  const UpcomingBirthdayWidget({
    super.key,
    required this.star,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysUntil = star.daysUntilBirthday ?? 0;
    final age = star.age ?? 0;
    
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
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF333333),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // カウントダウン表示
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _getGradientColors(daysUntil),
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$daysUntil',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '日後',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // スター情報
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        star.starName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.cake_outlined,
                            color: Color(0xFF4ECDC4),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            star.birthday != null
                                ? DateFormat('M月d日', 'ja_JP').format(star.birthday!)
                                : '未設定',
                            style: const TextStyle(
                              color: Color(0xFF4ECDC4),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$age歳に',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 設定ボタン
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF4ECDC4),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 日数に応じたグラデーション色を取得
  List<Color> _getGradientColors(int daysUntil) {
    if (daysUntil <= 3) {
      // 3日以内: 赤系
      return [const Color(0xFFFF6B6B), const Color(0xFFEE5A24)];
    } else if (daysUntil <= 7) {
      // 7日以内: オレンジ系
      return [const Color(0xFFFFE66D), const Color(0xFFFF9F43)];
    } else if (daysUntil <= 14) {
      // 14日以内: 黄色系
      return [const Color(0xFF4ECDC4), const Color(0xFF44A08D)];
    } else {
      // それ以外: グレー系
      return [const Color(0xFF6C7B7F), const Color(0xFF57727A)];
    }
  }
}