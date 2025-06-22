import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'star_watch_history_service.dart';

/// スター専用：視聴履歴管理画面
class StarWatchHistoryWidget extends ConsumerStatefulWidget {
  final String starId;
  
  const StarWatchHistoryWidget({
    Key? key,
    required this.starId,
  }) : super(key: key);

  @override
  ConsumerState<StarWatchHistoryWidget> createState() => _StarWatchHistoryWidgetState();
}

class _StarWatchHistoryWidgetState extends ConsumerState<StarWatchHistoryWidget> {
  List<WatchHistoryItem> importedHistory = [];
  List<WatchHistoryItem> sharedHistory = [];
  bool isLoading = false;
  String? errorMessage;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📺 視聴履歴管理'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // スター向け説明
            _buildStarExplanation(),
            const SizedBox(height: 20),
            
            // インポート方法選択
            _buildImportMethodSelection(),
            const SizedBox(height: 20),
            
            // インポートした履歴表示
            _buildImportedHistorySection(),
            const SizedBox(height: 20),
            
            // 共有設定セクション
            _buildSharingConfigSection(),
            
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
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  '⭐ スター専用：視聴履歴共有',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
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
            const Text(
              '以下の方法でYouTube視聴履歴をインポートできます',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            // ファイルインポート
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _importFromFile,
                icon: const Icon(Icons.file_upload),
                label: const Text('📄 YouTubeデータファイルから'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // URL入力
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _importFromUrl,
                icon: const Icon(Icons.link),
                label: const Text('🔗 YouTube URLから'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // 手動入力
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _manualInput,
                icon: const Icon(Icons.edit),
                label: const Text('✏️ 手動で動画を追加'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// インポートした履歴セクション
  Widget _buildImportedHistorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📋 インポートした履歴 (${importedHistory.length}件)',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (importedHistory.isNotEmpty)
                  TextButton(
                    onPressed: _clearImportedHistory,
                    child: const Text('🗑️ クリア'),
                  ),
              ],
            ),
            
            if (importedHistory.isEmpty) ...[
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'まだ履歴がインポートされていません\n上のボタンから視聴履歴をインポートしてください',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              ...importedHistory.take(5).map((item) => _buildHistoryItem(item, false)),
              if (importedHistory.length > 5) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: _showAllHistory,
                    child: Text('他${importedHistory.length - 5}件を表示'),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  /// 共有設定セクション
  Widget _buildSharingConfigSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🔗 ファンと共有中 (${sharedHistory.length}件)',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: importedHistory.isEmpty ? null : _configureSharing,
                  child: const Text('⚙️ 設定'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (sharedHistory.isEmpty) ...[
              const Text(
                'まだ共有されている履歴がありません\n履歴をインポート後、共有設定を行ってください',
                style: TextStyle(color: Colors.grey),
              ),
            ] else ...[
              ...sharedHistory.take(3).map((item) => _buildHistoryItem(item, true)),
              if (sharedHistory.length > 3) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: _showSharedHistory,
                    child: Text('共有中の履歴をすべて表示'),
                  ),
                ),
              ],
            ],
            
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ファンはあなたのプロフィールページで共有された視聴履歴を見ることができます',
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

  /// 履歴アイテム表示
  Widget _buildHistoryItem(WatchHistoryItem item, bool isShared) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item.thumbnailUrl,
            width: 80,
            height: 45,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 80,
                height: 45,
                color: Colors.grey.shade300,
                child: const Icon(Icons.video_library),
              );
            },
          ),
        ),
        title: Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14),
        ),
        subtitle: Text(
          '${item.channelName} • ${item.watchedAt.toString().split(' ')[0]}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: isShared 
          ? const Icon(Icons.share, color: Colors.green, size: 16)
          : const Icon(Icons.visibility_off, color: Colors.grey, size: 16),
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

  /// ファイルからインポート
  Future<void> _importFromFile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // TODO: ファイル選択とパース処理を実装
      await Future.delayed(const Duration(seconds: 2)); // 仮の処理
      
      // 仮のデータを追加
      setState(() {
        importedHistory.addAll([
          WatchHistoryItem(
            id: 'sample1',
            title: 'サンプル動画1',
            channelName: 'サンプルチャンネル',
            thumbnailUrl: 'https://example.com/thumb1.jpg',
            videoUrl: 'https://youtube.com/watch?v=sample1',
            watchedAt: DateTime.now(),
          ),
        ]);
      });
      
      _showSuccessSnackBar('視聴履歴をインポートしました');
    } catch (e) {
      setState(() {
        errorMessage = 'ファイルのインポートに失敗しました: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// URLからインポート
  Future<void> _importFromUrl() async {
    // TODO: URL入力ダイアログとインポート処理を実装
    _showInfoSnackBar('URL入力機能は開発中です');
  }

  /// 手動入力
  Future<void> _manualInput() async {
    // TODO: 手動入力ダイアログを実装
    _showInfoSnackBar('手動入力機能は開発中です');
  }

  /// インポート履歴をクリア
  void _clearImportedHistory() {
    setState(() {
      importedHistory.clear();
      sharedHistory.clear();
    });
    _showInfoSnackBar('履歴をクリアしました');
  }

  /// 共有設定
  void _configureSharing() {
    // TODO: 共有設定ダイアログを実装
    _showInfoSnackBar('共有設定機能は開発中です');
  }

  /// 全履歴表示
  void _showAllHistory() {
    // TODO: 全履歴表示画面への遷移を実装
    _showInfoSnackBar('全履歴表示機能は開発中です');
  }

  /// 共有履歴表示
  void _showSharedHistory() {
    // TODO: 共有履歴表示画面への遷移を実装
    _showInfoSnackBar('共有履歴表示機能は開発中です');
  }

  /// ヘルプダイアログ表示
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📚 視聴履歴共有について'),
        content: const Text(
          'YouTubeの視聴履歴をファンと共有することで、あなたの興味や趣味をファンにアピールできます。\n\n'
          '• データはプライベートに管理されます\n'
          '• 共有する履歴を選択できます\n'
          '• いつでも共有を停止できます\n\n'
          '安全にファンとのつながりを深めましょう！'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
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

  /// 情報メッセージ表示
  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}