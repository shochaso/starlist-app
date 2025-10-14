import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/netflix_models.dart';

/// Netflix視聴履歴カードウィジェット
class NetflixViewingCard extends StatelessWidget {
  final NetflixViewingHistory viewingHistory;
  final VoidCallback? onTap;

  const NetflixViewingCard({
    super.key,
    required this.viewingHistory,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Row(
              children: [
                // コンテンツ画像プレースホルダー
                Container(
                  width: 80,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: viewingHistory.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            viewingHistory.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                          ),
                        )
                      : _buildImagePlaceholder(),
                ),
                const SizedBox(width: 16),
                
                // コンテンツ情報
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // タイトル
                      Text(
                        viewingHistory.fullTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // 公開年とコンテンツタイプ
                      Row(
                        children: [
                          if (viewingHistory.releaseYear != null) ...[
                            Text(
                              '${viewingHistory.releaseYear}年',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE50914).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              viewingHistory.contentTypeDisplayName,
                              style: const TextStyle(
                                color: Color(0xFFE50914),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // 視聴日と視聴状態
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('yyyy/MM/dd').format(viewingHistory.watchedAt),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            _getWatchStatusIcon(viewingHistory.watchStatus),
                            size: 14,
                            color: _getWatchStatusColor(viewingHistory.watchStatus),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            viewingHistory.watchStatusDisplayName,
                            style: TextStyle(
                              color: _getWatchStatusColor(viewingHistory.watchStatus),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // 視聴時間と進捗
                      if (viewingHistory.watchDuration != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              viewingHistory.watchDurationString,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            if (viewingHistory.calculatedProgress > 0) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: viewingHistory.calculatedProgress,
                                  backgroundColor: const Color(0xFF333333),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
                                  minHeight: 3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(viewingHistory.calculatedProgress * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Color(0xFFE50914),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      
                      // ジャンルとレーティング
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ジャンル（最大2つまで表示）
                          if (viewingHistory.genres.isNotEmpty)
                            Expanded(
                              child: Wrap(
                                spacing: 4,
                                children: viewingHistory.genres.take(2).map((genre) => 
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF333333),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      genre,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                ).toList(),
                              ),
                            ),
                          
                          // レーティング
                          if (viewingHistory.rating != null) ...[
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...List.generate(5, (index) {
                                  return Icon(
                                    index < viewingHistory.rating!
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 14,
                                    color: const Color(0xFFE50914),
                                  );
                                }),
                                const SizedBox(width: 4),
                                Text(
                                  '${viewingHistory.rating}',
                                  style: const TextStyle(
                                    color: Color(0xFFE50914),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 矢印アイコン
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 画像プレースホルダー
  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getContentTypeIcon(viewingHistory.contentType),
              color: const Color(0xFFE50914),
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              viewingHistory.contentTypeDisplayName,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 8,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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

  /// 視聴状態アイコン取得
  IconData _getWatchStatusIcon(NetflixWatchStatus watchStatus) {
    switch (watchStatus) {
      case NetflixWatchStatus.completed:
        return Icons.check_circle;
      case NetflixWatchStatus.inProgress:
        return Icons.play_circle;
      case NetflixWatchStatus.watchlist:
        return Icons.bookmark;
      case NetflixWatchStatus.stopped:
        return Icons.pause_circle;
    }
  }

  /// 視聴状態色取得
  Color _getWatchStatusColor(NetflixWatchStatus watchStatus) {
    switch (watchStatus) {
      case NetflixWatchStatus.completed:
        return Colors.green;
      case NetflixWatchStatus.inProgress:
        return const Color(0xFFE50914);
      case NetflixWatchStatus.watchlist:
        return Colors.orange;
      case NetflixWatchStatus.stopped:
        return Colors.grey;
    }
  }
}