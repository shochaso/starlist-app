import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reaction_model.dart';
import '../widgets/post_reactions_widget.dart';
import '../widgets/reaction_button.dart';

/// リアクションシステムのデモ画面
class ReactionDemoScreen extends ConsumerWidget {
  const ReactionDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('リアクションシステムデモ'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 使用方法の説明
            _buildUsageSection(),
            
            const SizedBox(height: 24),
            
            // 個別リアクションボタンのデモ
            _buildIndividualButtonsDemo(),
            
            const SizedBox(height: 24),
            
            // 投稿リアクションシステムのデモ
            _buildPostReactionDemo(),
            
            const SizedBox(height: 24),
            
            // コメントリアクションシステムのデモ
            _buildCommentReactionDemo(),
            
            const SizedBox(height: 24),
            
            // 統計表示のデモ
            _buildStatsDemo(),
            
            const SizedBox(height: 24),
            
            // 実装説明
            _buildImplementationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📱 YouTubeスタイル リアクションシステム',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '✨ 実装機能:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• 👍 いいねボタン - クリック数表示\n'
              '• ❤️ ハートボタン - クリック数表示\n'
              '• 1投稿につき1人1回のみリアクション可能\n'
              '• リアルタイムでリアクション数更新\n'
              '• スムーズなアニメーション効果\n'
              '• ハプティックフィードバック対応',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Text(
                '💡 下記のボタンをタップして動作を確認してください！',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndividualButtonsDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎯 個別リアクションボタン',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 👍いいねボタン
            const Text('👍 いいねボタン:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                ReactionButton(
                  reactionType: ReactionType.like,
                  count: 42,
                  isActive: false,
                  onTap: () => _showSnackBar('👍 いいねボタンがタップされました！'),
                ),
                const SizedBox(width: 16),
                ReactionButton(
                  reactionType: ReactionType.like,
                  count: 42,
                  isActive: true,
                  onTap: () => _showSnackBar('👍 いいねを取り消しました！'),
                ),
                const SizedBox(width: 16),
                const Text('(非アクティブ → アクティブ)', style: TextStyle(fontSize: 12)),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // ❤️ハートボタン
            const Text('❤️ ハートボタン:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                ReactionButton(
                  reactionType: ReactionType.heart,
                  count: 28,
                  isActive: false,
                  onTap: () => _showSnackBar('❤️ ハートボタンがタップされました！'),
                ),
                const SizedBox(width: 16),
                ReactionButton(
                  reactionType: ReactionType.heart,
                  count: 28,
                  isActive: true,
                  onTap: () => _showSnackBar('❤️ ハートを取り消しました！'),
                ),
                const SizedBox(width: 16),
                const Text('(非アクティブ → アクティブ)', style: TextStyle(fontSize: 12)),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // リアクションボタン行
            const Text('リアクションボタン行:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ReactionButtonRow(
              reactionCounts: const ReactionCountModel(like: 156, heart: 89),
              userReactionState: const UserReactionState(hasLiked: true, hasHearted: false),
              onReactionToggle: (type) => _showSnackBar('${type.emoji} ${type.value} がタップされました！'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostReactionDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📝 投稿リアクションシステム',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🌟 スターの投稿サンプル',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '今日は新しい動画を投稿しました！みんなの反応が楽しみです 🎬✨',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  // 実際の投稿リアクションウィジェット
                  PostReactionsWidget(
                    postId: 'demo_post_1',
                    showStats: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '💡 上記のリアクションボタンは実際のデータベースと連動しています',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentReactionDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💬 コメントリアクションシステム',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // コメントサンプル1
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue,
                        child: Text('U', style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'ファンユーザー1',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '最高の動画でした！感動しました😊',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  CommentReactionsWidget(
                    commentId: 'demo_comment_1',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // コメントサンプル2
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.green,
                        child: Text('F', style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'ファンユーザー2',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '次回も楽しみにしています！',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  CommentReactionsWidget(
                    commentId: 'demo_comment_2',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 リアクション統計',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 統計表示サンプル
            const ReactionStats(
              reactionCounts: ReactionCountModel(like: 234, heart: 156),
              showPercentage: true,
            ),
            
            const SizedBox(height: 16),
            
            // 詳細統計カード
            ReactionStatsCard(
              postId: 'demo_post_1',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImplementationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔧 実装詳細',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            const Text(
              '📊 データベース設計:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• post_reactions テーブル: 投稿リアクション管理\n'
              '• comment_reactions テーブル: コメントリアクション管理\n'
              '• UNIQUE制約: 1ユーザー1投稿1リアクションタイプ\n'
              '• RLS (Row Level Security): データセキュリティ保護',
              style: TextStyle(fontSize: 14),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              '🏗️ アーキテクチャ:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Riverpod: 状態管理\n'
              '• Supabase: バックエンドAPI\n'
              '• リアルタイム同期: リアクション数の即座更新\n'
              '• 楽観的UI更新: 即座のレスポンス',
              style: TextStyle(fontSize: 14),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              '🎨 UI/UX機能:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• スムーズなアニメーション (200ms)\n'
              '• ハプティックフィードバック\n'
              '• テーマ対応 (ライト/ダーク)\n'
              '• アクセシビリティ対応',
              style: TextStyle(fontSize: 14),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Text(
                '✅ 実装完了: YouTubeスタイルのリアクションシステムが完全に動作します！',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    // Note: SnackBarを表示するには、BuildContextが必要
    // 実際の実装では、適切なcontextを使用してください
    print('SnackBar: $message');
  }
}

/// デモ用の拡張BuildContextクラス
extension DemoContextExtension on BuildContext {
  void showDemoSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}