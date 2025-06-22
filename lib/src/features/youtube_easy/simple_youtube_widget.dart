import 'package:flutter/material.dart';
import 'simple_youtube_service.dart';
import 'simple_youtube_setup.dart';
import 'package:url_launcher/url_launcher.dart';

/// スター専用：視聴履歴インポート画面
class SimpleYouTubeWidget extends StatefulWidget {
  final String starId;
  
  const SimpleYouTubeWidget({
    Key? key,
    required this.starId,
  }) : super(key: key);

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
        title: const Text('📺 視聴履歴インポート'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // スター向け説明
            _buildStarExplanation(),
            const SizedBox(height: 20),
            
            // 視聴履歴インポート方法選択
            _buildImportMethodSelection(),
            const SizedBox(height: 20),
            
            // インポート結果表示
            if (currentChannel != null) _buildImportResult(),
            const SizedBox(height: 20),
            
            // インポートした視聴履歴リスト
            _buildImportedHistoryList(),
            
            // エラーメッセージ表示
            if (errorMessage != null) _buildErrorMessage(),
          ],
        ),
      ),
    );
  }

  /// スター向け説明セクション
  Widget _buildStarExplanation() {
    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  '⭐ スター専用：視聴履歴共有',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'あなたのYouTube視聴履歴をファンと共有できます。\n\n'
              '✅ ファンがあなたと同じ動画を発見\n'
              '✅ 興味のあるコンテンツをシェア\n'
              '✅ ファンとのつながりを深める\n'
              '✅ プライベート設定で公開範囲を調整',
              style: TextStyle(fontSize: 14),
            ),
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

  /// インポート方法選択セクション
  Widget _buildImportMethodSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📥 視聴履歴をインポート',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showChannelIdDialog(),
              icon: const Icon(Icons.upload),
              label: const Text('チャンネルIDを入力'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            ),
          ],
        ),
      ),
    );
  }

  /// インポート結果表示
  Widget _buildImportResult() {
    if (currentChannel == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✅ インポート完了',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 8),
            Text('チャンネル: ${currentChannel!.name}'),
            Text('動画数: ${videos.length}件'),
          ],
        ),
      ),
    );
  }

  /// インポートした履歴リスト
  Widget _buildImportedHistoryList() {
    if (videos.isEmpty) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📋 視聴履歴',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...videos.take(5).map((video) => ListTile(
              title: Text(video.title),
              subtitle: Text(video.description),
              onTap: () => _launchVideo(video.id),
            )).toList(),
            if (videos.length > 5)
              TextButton(
                onPressed: () => _showAllVideos(),
                child: Text('他${videos.length - 5}件を表示'),
              ),
          ],
        ),
      ),
    );
  }

  /// チャンネルID入力ダイアログ
  void _showChannelIdDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('チャンネルIDを入力'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'UCxxxxxxxxxxxxxxxxxxxx',
            labelText: 'チャンネルID',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _importFromChannelId(controller.text);
            },
            child: const Text('インポート'),
          ),
        ],
      ),
    );
  }

  /// チャンネルIDからインポート
  Future<void> _importFromChannelId(String channelId) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final channel = await SimpleYouTubeService.getChannel(channelId);
      if (channel != null) {
        final channelVideos = await SimpleYouTubeService.getChannelVideos(channelId);
        setState(() {
          currentChannel = channel;
          videos = channelVideos;
        });
      } else {
        setState(() {
          errorMessage = 'チャンネルが見つかりませんでした';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'エラーが発生しました: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// 動画を開く
  Future<void> _launchVideo(String videoId) async {
    final url = 'https://www.youtube.com/watch?v=$videoId';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  /// 全動画表示
  void _showAllVideos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('全動画リスト'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return ListTile(
                title: Text(video.title),
                subtitle: Text(video.description),
                onTap: () => _launchVideo(video.id),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}