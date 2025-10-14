import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'star_watch_history_service.dart';

/// ファン向け：スターの視聴履歴表示画面
class FanWatchHistoryView extends ConsumerStatefulWidget {
  final String starId;
  final String starName;
  
  const FanWatchHistoryView({
    super.key,
    required this.starId,
    required this.starName,
  });

  @override
  ConsumerState<FanWatchHistoryView> createState() => _FanWatchHistoryViewState();
}

class _FanWatchHistoryViewState extends ConsumerState<FanWatchHistoryView> {
  List<WatchHistoryItem> sharedHistory = [];
  bool isLoading = true;
  String? errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadSharedHistory();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📺 ${widget.starName}の視聴履歴'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSharedHistory,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// メインコンテンツ
  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('視聴履歴を読み込み中...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSharedHistory,
              child: const Text('再試行'),
            ),
          ],
        ),
      );
    }

    if (sharedHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.video_library_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '${widget.starName}はまだ視聴履歴を\n共有していません',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'しばらく後にもう一度確認してみてください',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSharedHistory,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 概要カード
            _buildOverviewCard(),
            const SizedBox(height: 20),
            
            // 視聴履歴リスト
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  /// 概要カード
  Widget _buildOverviewCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '${widget.starName}の視聴履歴',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.starName}が最近視聴した動画 (${sharedHistory.length}件)',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '🎬 同じ動画を見てスターとの共通点を見つけよう！',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// 視聴履歴リスト
  Widget _buildHistoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📋 共有された視聴履歴',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        
        ...sharedHistory.map((item) => _buildHistoryItem(item)),
      ],
    );
  }

  /// 視聴履歴アイテム
  Widget _buildHistoryItem(WatchHistoryItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openVideo(item.videoUrl),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // サムネイル
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.thumbnailUrl,
                  width: 120,
                  height: 68,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 68,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.play_arrow, size: 30),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              
              // 動画情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.channelName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '👁️ ${widget.starName}が視聴: ${_formatDate(item.watchedAt)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 再生ボタン
              Column(
                children: [
                  Icon(
                    Icons.play_circle_fill,
                    color: Colors.red.shade600,
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'YouTube',
                    style: TextStyle(fontSize: 8, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 共有された視聴履歴を読み込み
  Future<void> _loadSharedHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final history = await StarWatchHistoryService.getSharedWatchHistory(widget.starId);
      setState(() {
        sharedHistory = history;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = '視聴履歴の読み込みに失敗しました: $e';
        isLoading = false;
      });
    }
  }

  /// 動画を開く
  Future<void> _openVideo(String videoUrl) async {
    try {
      final uri = Uri.parse(videoUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackBar('動画を開けませんでした');
      }
    } catch (e) {
      _showErrorSnackBar('動画を開く際にエラーが発生しました: $e');
    }
  }

  /// 日付をフォーマット
  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}分前';
      } else {
        return '${difference.inHours}時間前';
      }
    } else if (difference.inDays < 30) {
      return '${difference.inDays}日前';
    } else {
      return '${dateTime.year}/${dateTime.month}/${dateTime.day}';
    }
  }

  /// エラーメッセージ表示
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}