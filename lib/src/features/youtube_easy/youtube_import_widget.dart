import 'package:flutter/material.dart';
import 'youtube_history_importer.dart';
import 'simple_youtube_setup.dart';

/// YouTuber履歴インポート画面（中学生向け）
class YouTubeImportWidget extends StatefulWidget {
  const YouTubeImportWidget({Key? key}) : super(key: key);

  @override
  State<YouTubeImportWidget> createState() => _YouTubeImportWidgetState();
}

class _YouTubeImportWidgetState extends State<YouTubeImportWidget> {
  bool isImporting = false;
  ImportResult? importResult;
  BatchImportResult? batchResult;
  String? currentImportingChannel;
  
  // インポート対象のYouTuber（例）
  final Map<String, String> exampleYouTubers = {
    'hikakin_star': 'UCZf__ehlCEBPop-_sldpBUQ',    // ヒカキン
    'hajime_star': 'UCgMPP6RRjktV7krOfyUewqw',    // はじめしゃちょー
    'fischer_star': 'UCibEhpu5HP45-w7Bq1ZIulw',   // フィッシャーズ
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📥 YouTube履歴インポート'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 説明セクション
            _buildExplanationSection(),
            const SizedBox(height: 20),
            
            // 個別インポートセクション
            _buildIndividualImportSection(),
            const SizedBox(height: 20),
            
            // 一括インポートセクション
            _buildBatchImportSection(),
            const SizedBox(height: 20),
            
            // 結果表示セクション
            if (importResult != null) _buildImportResultSection(),
            if (batchResult != null) _buildBatchResultSection(),
          ],
        ),
      ),
    );
  }

  /// 説明セクション
  Widget _buildExplanationSection() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  '📚 YouTube履歴インポートとは？',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'YouTuberの動画履歴をStarlistの「毎日ピック」機能に簡単にインポートできます。\n\n'
              '✅ 動画のタイトル・サムネイル・再生回数\n'
              '✅ 公開日・いいね数・チャンネル情報\n'
              '✅ 自動でタグ付けして整理\n'
              '✅ 毎日ピックコンテンツとして活用可能',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// 個別インポートセクション
  Widget _buildIndividualImportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '👤 個別インポート',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '好きなYouTuberを1人ずつインポートできます',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            ...SimpleYouTubeSetup.popularYouTubers.entries.map((entry) {
              final youtuberName = entry.key;
              final channelId = entry.value;
              final isCurrentlyImporting = currentImportingChannel == youtuberName;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isImporting ? null : () => _importSingleYouTuber(youtuberName, channelId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentlyImporting ? Colors.orange : Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: isCurrentlyImporting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('$youtuberName インポート中...'),
                            ],
                          )
                        : Text('📺 $youtuberName の履歴をインポート'),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 一括インポートセクション
  Widget _buildBatchImportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🚀 一括インポート',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '登録済みYouTuberの履歴をまとめてインポートします',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isImporting ? null : _batchImportYouTubers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: isImporting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('一括インポート実行中...'),
                        ],
                      )
                    : Text('🎬 全YouTuber履歴を一括インポート (${exampleYouTubers.length}チャンネル)'),
              ),
            ),
            
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '注意: 一括インポートは時間がかかる場合があります',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// インポート結果表示セクション
  Widget _buildImportResultSection() {
    final result = importResult!;
    
    return Card(
      color: result.success ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.success ? Icons.check_circle : Icons.error,
                  color: result.success ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  result.success ? '✅ インポート完了' : '❌ インポート失敗',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: result.success ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(result.message),
            
            if (result.success && result.channelInfo != null) ...[
              const SizedBox(height: 12),
              _buildChannelSummary(result.channelInfo!),
              
              if (result.importedItems?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                _buildImportedItemsSummary(result.importedItems!),
              ],
            ],
          ],
        ),
      ),
    );
  }

  /// 一括インポート結果表示セクション
  Widget _buildBatchResultSection() {
    final result = batchResult!;
    
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.batch_prediction, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  '🎉 一括インポート完了',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 統計情報
            _buildBatchStatistics(result),
            
            const SizedBox(height: 12),
            
            // 詳細結果
            ...result.results.entries.map((entry) {
              final starId = entry.key;
              final importResult = entry.value;
              
              return _buildBatchItemResult(starId, importResult);
            }),
          ],
        ),
      ),
    );
  }

  /// チャンネル概要表示
  Widget _buildChannelSummary(YouTubeChannel channel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              channel.imageUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 40,
                  height: 40,
                  color: Colors.grey,
                  child: const Icon(Icons.person, color: Colors.white),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  channel.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${channel.subscriberCountText} • ${channel.videoCount}本の動画',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// インポートアイテム概要表示
  Widget _buildImportedItemsSummary(List<dynamic> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 インポート詳細',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text('🎬 ${items.length}本の動画をインポート'),
          Text('📅 最新動画から順番に取得'),
          Text('🏷️ 自動タグ付けで整理'),
        ],
      ),
    );
  }

  /// 一括インポート統計表示
  Widget _buildBatchStatistics(BatchImportResult result) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('📺', '${result.results.length}', 'チャンネル'),
          _buildStatItem('✅', '${result.totalSuccess}', '成功'),
          _buildStatItem('❌', '${result.totalErrors}', 'エラー'),
          _buildStatItem('📊', '${(result.successRate * 100).toInt()}%', '成功率'),
        ],
      ),
    );
  }

  /// 統計アイテム表示
  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  /// 一括インポート個別結果表示
  Widget _buildBatchItemResult(String starId, ImportResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: result.success ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            result.success ? Icons.check : Icons.error,
            color: result.success ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$starId: ${result.message}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// 個別YouTuberインポート実行
  Future<void> _importSingleYouTuber(String youtuberName, String channelId) async {
    if (!SimpleYouTubeSetup.isSetupComplete()) {
      _showErrorSnackBar('APIキーが設定されていません');
      return;
    }

    setState(() {
      isImporting = true;
      currentImportingChannel = youtuberName;
      importResult = null;
    });

    try {
      print('📺 $youtuberName の履歴インポート開始');
      
      final result = await YouTubeHistoryImporter.importYouTuberHistory(
        starId: '${youtuberName.toLowerCase()}_star',
        channelId: channelId,
        maxVideos: 30,
      );

      setState(() {
        importResult = result;
      });

      if (result.success) {
        _showSuccessSnackBar('$youtuberName の履歴インポートが完了しました！');
      } else {
        _showErrorSnackBar(result.message);
      }

    } catch (e) {
      setState(() {
        importResult = ImportResult.error('エラーが発生しました: $e');
      });
      _showErrorSnackBar('インポート中にエラーが発生しました');
    } finally {
      setState(() {
        isImporting = false;
        currentImportingChannel = null;
      });
    }
  }

  /// 一括インポート実行
  Future<void> _batchImportYouTubers() async {
    if (!SimpleYouTubeSetup.isSetupComplete()) {
      _showErrorSnackBar('APIキーが設定されていません');
      return;
    }

    setState(() {
      isImporting = true;
      batchResult = null;
    });

    try {
      print('🚀 一括インポート開始');
      
      final result = await YouTubeHistoryImporter.batchImportYouTubers(exampleYouTubers);

      setState(() {
        batchResult = result;
      });

      _showSuccessSnackBar('一括インポートが完了しました！');

    } catch (e) {
      _showErrorSnackBar('一括インポート中にエラーが発生しました: $e');
    } finally {
      setState(() {
        isImporting = false;
      });
    }
  }

  /// 成功メッセージ表示
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
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