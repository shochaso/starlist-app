import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reaction_model.dart';
import '../providers/reaction_provider.dart';
import 'reaction_button.dart';

/// 投稿リアクションウィジェット
/// 投稿カードのフッターに表示される👍と❤️のリアクションボタン
class PostReactionsWidget extends ConsumerStatefulWidget {
  const PostReactionsWidget({
    Key? key,
    required this.postId,
    this.showStats = false,
    this.compact = false,
  }) : super(key: key);

  final String postId;
  final bool showStats;
  final bool compact;

  @override
  ConsumerState<PostReactionsWidget> createState() => _PostReactionsWidgetState();
}

class _PostReactionsWidgetState extends ConsumerState<PostReactionsWidget> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReactions();
  }

  void _loadReactions() {
    final userId = ref.read(currentUserIdProvider);
    ref.read(postReactionProvider(widget.postId).notifier)
        .loadPostReactions(widget.postId, userId);
  }

  Future<void> _handleReactionToggle(ReactionType reactionType) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      // ログインが必要
      _showLoginRequiredSnackBar();
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(postReactionProvider(widget.postId).notifier)
          .togglePostReaction(widget.postId, userId, reactionType);
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showLoginRequiredSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('リアクションするにはログインが必要です'),
        action: SnackBarAction(
          label: 'ログイン',
          onPressed: () {
            // ログイン画面に遷移
            Navigator.of(context).pushNamed('/login');
          },
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('エラーが発生しました: $message'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reactionState = ref.watch(postReactionProvider(widget.postId));

    return reactionState.when(
      loading: () => _buildLoadingWidget(),
      error: (error, stackTrace) => _buildErrorWidget(error),
      data: (data) => _buildReactionWidget(data),
    );
  }

  Widget _buildLoadingWidget() {
    return widget.compact
        ? const SizedBox(
            height: 24,
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        : const SizedBox(
            height: 40,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }

  Widget _buildErrorWidget(Object error) {
    return Container(
      height: widget.compact ? 24 : 40,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 4),
          Text(
            'エラー',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _loadReactions,
            child: const Text('再試行'),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionWidget(Map<String, dynamic> data) {
    final reactionCounts = data['counts'] as ReactionCountModel;
    final userReactionState = data['userState'] as UserReactionState;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // メインリアクションボタン
        ReactionButtonRow(
          reactionCounts: reactionCounts,
          userReactionState: userReactionState,
          onReactionToggle: _handleReactionToggle,
          isLoading: _isLoading,
          size: widget.compact ? 16 : 20,
        ),
        
        // 統計情報（オプション）
        if (widget.showStats && reactionCounts.hasReactions) ...[
          const SizedBox(height: 8),
          ReactionStats(
            reactionCounts: reactionCounts,
            showPercentage: true,
          ),
        ],
      ],
    );
  }
}

/// コメントリアクションウィジェット
/// コメントの下に表示される👍と❤️のリアクションボタン
class CommentReactionsWidget extends ConsumerStatefulWidget {
  const CommentReactionsWidget({
    Key? key,
    required this.commentId,
    this.compact = true,
  }) : super(key: key);

  final String commentId;
  final bool compact;

  @override
  ConsumerState<CommentReactionsWidget> createState() => _CommentReactionsWidgetState();
}

class _CommentReactionsWidgetState extends ConsumerState<CommentReactionsWidget> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReactions();
  }

  void _loadReactions() {
    final userId = ref.read(currentUserIdProvider);
    ref.read(commentReactionProvider(widget.commentId).notifier)
        .loadCommentReactions(widget.commentId, userId);
  }

  Future<void> _handleReactionToggle(ReactionType reactionType) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      _showLoginRequiredSnackBar();
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(commentReactionProvider(widget.commentId).notifier)
          .toggleCommentReaction(widget.commentId, userId, reactionType);
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showLoginRequiredSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('リアクションするにはログインが必要です'),
        action: SnackBarAction(
          label: 'ログイン',
          onPressed: () {
            Navigator.of(context).pushNamed('/login');
          },
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('エラーが発生しました: $message'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reactionState = ref.watch(commentReactionProvider(widget.commentId));

    return reactionState.when(
      loading: () => _buildLoadingWidget(),
      error: (error, stackTrace) => _buildErrorWidget(error),
      data: (data) => _buildReactionWidget(data),
    );
  }

  Widget _buildLoadingWidget() {
    return const SizedBox(
      height: 24,
      child: Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Container(
      height: 24,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 14,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 4),
          Text(
            'エラー',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: _loadReactions,
            child: const Text(
              '再試行',
              style: TextStyle(
                fontSize: 10,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionWidget(Map<String, dynamic> data) {
    final reactionCounts = data['counts'] as ReactionCountModel;
    final userReactionState = data['userState'] as UserReactionState;

    return ReactionButtonRow(
      reactionCounts: reactionCounts,
      userReactionState: userReactionState,
      onReactionToggle: _handleReactionToggle,
      isLoading: _isLoading,
      size: widget.compact ? 14 : 16,
    );
  }
}

/// リアクション詳細ダイアログ
/// リアクションした人の一覧を表示
class ReactionDetailDialog extends ConsumerWidget {
  const ReactionDetailDialog({
    Key? key,
    required this.postId,
    required this.reactionType,
  }) : super(key: key);

  final String postId;
  final ReactionType reactionType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topReactionsAsync = ref.watch(topPostReactionsProvider({
      'postId': postId,
      'reactionType': reactionType,
      'limit': 50,
    }));

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ヘッダー
            Row(
              children: [
                Text(
                  reactionType.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  reactionType == ReactionType.like ? 'いいね' : 'ハート',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            
            // リアクションしたユーザーリスト
            Expanded(
              child: topReactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text('エラーが発生しました: $error'),
                ),
                data: (reactions) {
                  if (reactions.isEmpty) {
                    return const Center(
                      child: Text('まだリアクションがありません'),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: reactions.length,
                    itemBuilder: (context, index) {
                      final reaction = reactions[index];
                      final profile = reaction['profiles'] as Map<String, dynamic>;
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: profile['avatar_url'] != null
                              ? NetworkImage(profile['avatar_url'])
                              : null,
                          child: profile['avatar_url'] == null
                              ? Text(
                                  profile['full_name']?[0] ?? 'U',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        title: Text(
                          profile['full_name'] ?? profile['username'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '@${profile['username'] ?? 'unknown'}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: Text(
                          _formatTime(DateTime.parse(reaction['created_at'])),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }
}

/// リアクション統計カード
/// 投稿の詳細画面などで使用
class ReactionStatsCard extends ConsumerWidget {
  const ReactionStatsCard({
    Key? key,
    required this.postId,
  }) : super(key: key);

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(reactionStatsProvider(postId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'リアクション統計',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Text('エラー: $error'),
              data: (stats) {
                final counts = stats['counts'] as ReactionCountModel;
                final likePercentage = stats['likePercentage'] as double;
                final heartPercentage = stats['heartPercentage'] as double;
                
                if (counts.total == 0) {
                  return const Text('まだリアクションがありません');
                }
                
                return Column(
                  children: [
                    // 総リアクション数
                    Row(
                      children: [
                        const Icon(Icons.analytics_outlined),
                        const SizedBox(width: 8),
                        Text(
                          '合計 ${counts.total} リアクション',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 👍統計
                    if (counts.like > 0) ...[
                      Row(
                        children: [
                          const Text('👍', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text('${counts.like}'),
                          const SizedBox(width: 8),
                          Text('(${likePercentage.toStringAsFixed(1)}%)'),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _showReactionDetail(context, ReactionType.like),
                            child: const Text(
                              '詳細',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    // ❤️統計
                    if (counts.heart > 0) ...[
                      Row(
                        children: [
                          const Text('❤️', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text('${counts.heart}'),
                          const SizedBox(width: 8),
                          Text('(${heartPercentage.toStringAsFixed(1)}%)'),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _showReactionDetail(context, ReactionType.heart),
                            child: const Text(
                              '詳細',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReactionDetail(BuildContext context, ReactionType reactionType) {
    showDialog(
      context: context,
      builder: (context) => ReactionDetailDialog(
        postId: postId,
        reactionType: reactionType,
      ),
    );
  }
}