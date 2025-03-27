import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/data_integration/models/youtube_video.dart';
import '../features/data_integration/repositories/youtube_repository.dart';
import 'youtube_video_list.dart';

/// 消費習慣データを表示するウィジェット
class ConsumptionDataWidget extends ConsumerStatefulWidget {
  final String userId;
  final String? title;
  final bool showHeader;

  const ConsumptionDataWidget({
    Key? key,
    required this.userId,
    this.title,
    this.showHeader = true,
  }) : super(key: key);

  @override
  ConsumerState<ConsumptionDataWidget> createState() => _ConsumptionDataWidgetState();
}

class _ConsumptionDataWidgetState extends ConsumerState<ConsumptionDataWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ヘッダー（オプション）
        if (widget.showHeader) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              widget.title ?? '消費習慣データ',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        
        // タブバー
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: '動画'),
            Tab(text: '音楽'),
            Tab(text: '購入'),
          ],
        ),
        
        // タブコンテンツ
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // 動画タブ
              _buildVideoTab(),
              
              // 音楽タブ
              _buildMusicTab(),
              
              // 購入タブ
              _buildPurchaseTab(),
            ],
          ),
        ),
      ],
    );
  }

  /// 動画タブのコンテンツを構築
  Widget _buildVideoTab() {
    // YouTubeリポジトリからユーザーの視聴履歴を取得する例
    // 実際のアプリでは、ユーザーIDに基づいてデータを取得する必要があります
    final asyncVideos = ref.watch(userWatchHistoryProvider(widget.userId));
    
    return asyncVideos.when(
      data: (videos) => YouTubeVideoList(
        videos: videos,
        emptyMessage: '視聴履歴がありません',
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('エラーが発生しました: $error'),
      ),
    );
  }

  /// 音楽タブのコンテンツを構築
  Widget _buildMusicTab() {
    // 音楽データの表示（実装例）
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '音楽データはまだ実装されていません',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 購入タブのコンテンツを構築
  Widget _buildPurchaseTab() {
    // 購入データの表示（実装例）
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '購入データはまだ実装されていません',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// ユーザーの視聴履歴を提供するプロバイダー
final userWatchHistoryProvider = FutureProvider.family<List<YouTubeVideo>, String>((ref, userId) async {
  // 実際のアプリでは、ユーザーIDに基づいてデータを取得する必要があります
  // ここではモックデータを返す例を示します
  await Future.delayed(const Duration(seconds: 1)); // ローディング状態をシミュレート
  
  // モックデータ
  return [
    YouTubeVideo(
      id: 'dQw4w9WgXcQ',
      title: 'Rick Astley - Never Gonna Give You Up (Official Music Video)',
      channelId: 'UCuAXFkgsw1L7xaCfnd5JJOw',
      channelTitle: 'Rick Astley',
      thumbnailUrl: 'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
      description: 'The official music video for "Never Gonna Give You Up" by Rick Astley',
      publishedAt: DateTime(2009, 10, 25),
      viewCount: 1234567890,
      likeCount: 12345678,
      duration: const Duration(minutes: 3, seconds: 33),
    ),
    YouTubeVideo(
      id: '9bZkp7q19f0',
      title: 'PSY - GANGNAM STYLE(강남스타일) M/V',
      channelId: 'UCrDkAvwZum-UTjHmzDI2iIw',
      channelTitle: 'officialpsy',
      thumbnailUrl: 'https://i.ytimg.com/vi/9bZkp7q19f0/hqdefault.jpg',
      description: 'PSY - GANGNAM STYLE(강남스타일) M/V',
      publishedAt: DateTime(2012, 7, 15),
      viewCount: 4567890123,
      likeCount: 23456789,
      duration: const Duration(minutes: 4, seconds: 13),
    ),
  ];
});
