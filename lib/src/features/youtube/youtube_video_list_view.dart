import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/components/layouts/item_list_view.dart';
import '../../core/components/cards/item_card.dart';
import '../data_integration/models/youtube_video.dart';
import '../data_integration/services/youtube_api_service.dart';

/// YouTubeビデオプロバイダー
final youtubeVideosProvider = FutureProvider.autoDispose.family<List<YouTubeVideo>, String>((ref, query) async {
  final youtubeService = YouTubeApiService(
    apiKey: const String.fromEnvironment('YOUTUBE_API_KEY'),
  );
  return youtubeService.searchVideos(query);
});

/// 人気のYouTubeビデオプロバイダー
final popularYoutubeVideosProvider = FutureProvider.autoDispose<List<YouTubeVideo>>((ref) async {
  final youtubeService = YouTubeApiService(
    apiKey: const String.fromEnvironment('YOUTUBE_API_KEY'),
  );
  return youtubeService.getPopularVideos();
});

/// YouTubeビデオリストビュー
class YouTubeVideoListView extends ConsumerWidget {
  /// 検索クエリ
  final String searchQuery;
  
  /// スクロール方向
  final Axis scrollDirection;
  
  /// リストビューの余白
  final EdgeInsetsGeometry padding;
  
  /// リストアイテム間のスペース
  final double itemSpacing;
  
  /// アイテムがタップされたときのコールバック
  final Function(YouTubeVideo video)? onVideoTap;

  const YouTubeVideoListView({
    Key? key,
    required this.searchQuery,
    this.scrollDirection = Axis.vertical,
    this.padding = const EdgeInsets.all(8.0),
    this.itemSpacing = 8.0,
    this.onVideoTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(youtubeVideosProvider(searchQuery));
    
    return videosAsync.when(
      data: (videos) {
        return ItemListView<YouTubeVideo>(
          items: videos,
          scrollDirection: scrollDirection,
          padding: padding,
          itemSpacing: itemSpacing,
          onRefresh: () async {
            ref.refresh(youtubeVideosProvider(searchQuery));
          },
          itemBuilder: (context, video, index) {
            return _buildVideoCard(context, video);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        return ItemListView<YouTubeVideo>(
          items: const [],
          scrollDirection: scrollDirection,
          padding: padding,
          itemSpacing: itemSpacing,
          hasError: true,
          errorMessage: 'YouTubeビデオの読み込みに失敗しました: $error',
          onRefresh: () async {
            ref.refresh(youtubeVideosProvider(searchQuery));
          },
          itemBuilder: (_, __, ___) => const SizedBox.shrink(), // エラー時は使用されない
        );
      },
    );
  }

  /// ビデオカードを構築
  Widget _buildVideoCard(BuildContext context, YouTubeVideo video) {
    return ItemCard(
      title: video.title,
      subtitle: video.channelTitle,
      description: _formatVideoStats(video),
      imageUrl: video.thumbnailUrl,
      onTap: () {
        if (onVideoTap != null) {
          onVideoTap!(video);
        }
      },
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatDuration(video.duration),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// ビデオの統計情報をフォーマット
  String _formatVideoStats(YouTubeVideo video) {
    final viewCount = _formatCount(video.viewCount);
    return '$viewCount 回視聴 • ${_formatDate(video.publishedAt)}';
  }

  /// 数値をフォーマット（例: 1000 -> 1K）
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  /// 日付をフォーマット
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}ヶ月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return '今すぐ';
    }
  }

  /// 動画の長さをフォーマット
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds';
    }
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
}

/// 人気のYouTubeビデオセクション
class PopularYouTubeVideosSection extends ConsumerWidget {
  /// セクションのタイトル
  final String title;
  
  /// セクションのサブタイトル
  final String? subtitle;
  
  /// すべて表示ボタンをクリックしたときのコールバック
  final VoidCallback? onViewAll;
  
  /// 水平スクロールかどうか
  final bool isHorizontal;
  
  /// 最大表示数
  final int? maxItems;
  
  /// アイテムがタップされたときのコールバック
  final Function(YouTubeVideo video)? onVideoTap;

  const PopularYouTubeVideosSection({
    Key? key,
    required this.title,
    this.subtitle,
    this.onViewAll,
    this.isHorizontal = true,
    this.maxItems,
    this.onVideoTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(popularYoutubeVideosProvider);
    
    return videosAsync.when(
      data: (videos) {
        return ItemListSection<YouTubeVideo>(
          title: title,
          subtitle: subtitle,
          items: videos,
          isHorizontal: isHorizontal,
          maxItems: maxItems,
          onViewAll: onViewAll,
          itemBuilder: (context, video, index) {
            return _buildVideoCard(context, video);
          },
        );
      },
      loading: () => ItemListSection<YouTubeVideo>(
        title: title,
        subtitle: subtitle,
        items: const [],
        isHorizontal: isHorizontal,
        isLoading: true,
        onViewAll: onViewAll,
        itemBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
      error: (error, stackTrace) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16.0),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48.0),
                    const SizedBox(height: 8.0),
                    Text('データの読み込みに失敗しました: $error'),
                    const SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: () => ref.refresh(popularYoutubeVideosProvider),
                      child: const Text('再読み込み'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ビデオカードを構築
  Widget _buildVideoCard(BuildContext context, YouTubeVideo video) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          if (onVideoTap != null) {
            onVideoTap!(video);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // サムネイル
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 動画の長さ
                Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 2.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    _formatDuration(video.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            // 動画情報
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    video.channelTitle,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '${_formatCount(video.viewCount)} 回視聴',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 数値をフォーマット（例: 1000 -> 1K）
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  /// 動画の長さをフォーマット
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds';
    }
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
} 