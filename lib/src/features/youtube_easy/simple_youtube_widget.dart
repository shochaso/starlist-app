import 'package:flutter/material.dart';
import 'simple_youtube_service.dart';
import 'simple_youtube_setup.dart';
import 'package:url_launcher/url_launcher.dart';

/// 中学生でも簡単に使えるYouTube表示画面
class SimpleYouTubeWidget extends StatefulWidget {
  const SimpleYouTubeWidget({Key? key}) : super(key: key);

  @override
  State<SimpleYouTubeWidget> createState() => _SimpleYouTubeWidgetState();
}

class _SimpleYouTubeWidgetState extends State<SimpleYouTubeWidget> {
  YouTubeChannel? currentChannel;
  List<YouTubeVideo> videos = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // APIキーを設定
    SimpleYouTubeService.apiKey = SimpleYouTubeSetup.myApiKey;
    // 設定チェック
    SimpleYouTubeSetup.printSetupStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📺 YouTube連携テスト'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ステップ1: 設定確認
            _buildSetupSection(),
            const SizedBox(height: 20),
            
            // ステップ2: YouTuber選択
            _buildYouTuberSelection(),
            const SizedBox(height: 20),
            
            // ステップ3: チャンネル情報表示
            if (currentChannel != null) _buildChannelInfo(),
            const SizedBox(height: 20),
            
            // ステップ4: 動画リスト表示
            _buildVideosList(),
            
            // エラーメッセージ表示
            if (errorMessage != null) _buildErrorMessage(),
          ],
        ),
      ),
    );
  }

  /// 設定確認セクション
  Widget _buildSetupSection() {
    final isSetup = SimpleYouTubeSetup.isSetupComplete();
    
    return Card(
      color: isSetup ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSetup ? Icons.check_circle : Icons.error,
                  color: isSetup ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  isSetup ? '✅ 設定完了！' : '❌ 設定が必要です',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSetup ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
            if (!isSetup) ...[
              const SizedBox(height: 8),
              const Text(
                '1. Google Cloud ConsoleでAPIキーを取得\n'
                '2. simple_youtube_setup.dartのmyApiKeyに設定\n'
                '3. アプリを再起動',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// YouTuber選択セクション
  Widget _buildYouTuberSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📱 YouTuberを選んでね',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SimpleYouTubeSetup.popularYouTubers.entries.map((entry) {
                return ElevatedButton(
                  onPressed: () => _loadYouTuberData(entry.key, entry.value),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(entry.key),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// チャンネル情報表示
  Widget _buildChannelInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // チャンネルアイコン
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.network(
                    currentChannel!.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey,
                        child: const Icon(Icons.person, color: Colors.white),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                
                // チャンネル情報
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentChannel!.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '👥 ${currentChannel!.subscriberCountText} • 📹 ${currentChannel!.videoCount}本',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (currentChannel!.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                currentChannel!.description,
                style: const TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 動画リスト表示
  Widget _buildVideosList() {
    if (isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('動画を読み込み中...'),
              ],
            ),
          ),
        ),
      );
    }

    if (videos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎬 最新動画 (${videos.length}本)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            ...videos.map((video) => _buildVideoItem(video)),
          ],
        ),
      ),
    );
  }

  /// 動画アイテム表示
  Widget _buildVideoItem(YouTubeVideo video) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openYouTubeVideo(video.youtubeUrl),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // サムネイル
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  video.imageUrl,
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
                      video.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '👀 ${video.viewCountText} • 📅 ${video.publishedText}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (video.likeCount > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '👍 ${video.likeCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // 再生ボタン
              const Icon(
                Icons.play_arrow,
                color: Colors.red,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// エラーメッセージ表示
  Widget _buildErrorMessage() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                errorMessage!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// YouTuberのデータを読み込み
  Future<void> _loadYouTuberData(String name, String channelId) async {
    if (!SimpleYouTubeSetup.isSetupComplete()) {
      setState(() {
        errorMessage = 'APIキーが設定されていません。設定を完了してください。';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      currentChannel = null;
      videos = [];
    });

    try {
      // 1. チャンネル情報を取得
      print('$nameのチャンネル情報を取得中...');
      final channel = await SimpleYouTubeService.getChannel(channelId);
      
      if (channel == null) {
        setState(() {
          errorMessage = 'チャンネル情報を取得できませんでした';
          isLoading = false;
        });
        return;
      }

      setState(() {
        currentChannel = channel;
      });

      // 2. 動画リストを取得
      print('$nameの動画リストを取得中...');
      final videoList = await SimpleYouTubeService.getChannelVideos(channelId);

      setState(() {
        videos = videoList;
        isLoading = false;
      });

      print('✅ $nameのデータ取得完了: ${videos.length}本の動画');

    } catch (e) {
      print('❌ エラー: $e');
      setState(() {
        errorMessage = 'データ取得エラー: $e';
        isLoading = false;
      });
    }
  }

  /// YouTube動画を開く
  Future<void> _openYouTubeVideo(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        setState(() {
          errorMessage = '動画を開けませんでした';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '動画を開く際にエラーが発生しました: $e';
      });
    }
  }
}