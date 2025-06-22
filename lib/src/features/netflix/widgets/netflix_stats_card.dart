import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/netflix_models.dart';

/// Netflix統計カードウィジェット
class NetflixStatsCard extends StatelessWidget {
  final NetflixViewingStats stats;

  const NetflixStatsCard({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE50914),
            Color(0xFFB00710),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE50914).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 期間表示
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.date_range,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${DateFormat('yyyy/MM/dd').format(stats.periodStart)} - ${DateFormat('yyyy/MM/dd').format(stats.periodEnd)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 総視聴時間
          Column(
            children: [
              const Text(
                '総視聴時間',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stats.totalWatchTimeString,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 統計グリッド
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Icons.movie,
                label: '視聴作品',
                value: '${stats.totalItems}作品',
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white24,
              ),
              _buildStatItem(
                icon: Icons.star,
                label: '平均評価',
                value: stats.totalRatings > 0 
                    ? '${stats.averageRating.toStringAsFixed(1)}★'
                    : '-',
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 最も視聴しているコンテンツタイプ
          if (stats.itemsByType.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    '最も視聴しているタイプ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getContentTypeIcon(_getTopContentType()),
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getTopContentTypeDisplayName(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_getTopContentTypeCount()}作品',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // トップジャンル
          if (stats.topGenres.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    '好きなジャンル',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: stats.topGenres.take(3).map((genre) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        genre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 統計項目ウィジェット
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 最も多いコンテンツタイプを取得
  NetflixContentType _getTopContentType() {
    if (stats.itemsByType.isEmpty) return NetflixContentType.movie;
    
    return stats.itemsByType.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// 最も多いコンテンツタイプの表示名を取得
  String _getTopContentTypeDisplayName() {
    final topType = _getTopContentType();
    switch (topType) {
      case NetflixContentType.movie:
        return '映画';
      case NetflixContentType.series:
        return 'シリーズ';
      case NetflixContentType.documentary:
        return 'ドキュメンタリー';
      case NetflixContentType.anime:
        return 'アニメ';
      case NetflixContentType.standup:
        return 'スタンダップコメディ';
      case NetflixContentType.kids:
        return 'キッズ';
      case NetflixContentType.reality:
        return 'リアリティ番組';
      case NetflixContentType.other:
        return 'その他';
    }
  }

  /// 最も多いコンテンツタイプの件数を取得
  int _getTopContentTypeCount() {
    if (stats.itemsByType.isEmpty) return 0;
    
    return stats.itemsByType.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .value;
  }

  /// コンテンツタイプアイコン取得
  IconData _getContentTypeIcon(NetflixContentType contentType) {
    switch (contentType) {
      case NetflixContentType.movie:
        return Icons.movie;
      case NetflixContentType.series:
        return Icons.tv;
      case NetflixContentType.documentary:
        return Icons.video_library;
      case NetflixContentType.anime:
        return Icons.animation;
      case NetflixContentType.standup:
        return Icons.mic;
      case NetflixContentType.kids:
        return Icons.child_care;
      case NetflixContentType.reality:
        return Icons.camera_alt;
      case NetflixContentType.other:
        return Icons.play_circle;
    }
  }
}