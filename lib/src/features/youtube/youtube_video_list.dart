import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../features/data_integration/models/youtube_video.dart';
import 'youtube_video_card.dart';

/// YouTube動画のリストを表示するウィジェット
class YouTubeVideoList extends ConsumerWidget {
  final List<YouTubeVideo> videos;
  final bool isLoading;
  final String? emptyMessage;
  final Function(YouTubeVideo)? onVideoTap;
  final ScrollController? scrollController;

  const YouTubeVideoList({
    Key? key,
    required this.videos,
    this.isLoading = false,
    this.emptyMessage,
    this.onVideoTap,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ローディング中の場合はスケルトンローダーを表示
    if (isLoading) {
      return _buildSkeletonLoader();
    }

    // 動画がない場合はメッセージを表示
    if (videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.videocam_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage ?? '動画がありません',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // 動画リストを表示
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: YouTubeVideoCard(
            video: video,
            onTap: onVideoTap != null ? () => onVideoTap!(video) : null,
          ),
        );
      },
    );
  }

  /// ローディング中に表示するスケルトンローダー
  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: 5, // スケルトンアイテムの数
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildSkeletonItem(),
        );
      },
    );
  }

  /// スケルトンアイテム（ローディングプレースホルダー）
  Widget _buildSkeletonItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // サムネイルプレースホルダー
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.white,
              ),
            ),
            // 情報プレースホルダー
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // タイトルプレースホルダー
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 200,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  // チャンネル名プレースホルダー
                  Container(
                    width: 150,
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  // 視聴回数と日付プレースホルダー
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 60,
                        height: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
