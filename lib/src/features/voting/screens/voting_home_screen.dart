import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/voting_providers.dart';
import '../widgets/voting_post_card.dart';
import '../widgets/star_point_balance_widget.dart';
import 'create_voting_post_screen.dart';
import '../../../features/auth/providers/user_provider.dart';

/// 投票システムのホーム画面
class VotingHomeScreen extends ConsumerStatefulWidget {
  const VotingHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VotingHomeScreen> createState() => _VotingHomeScreenState();
}

class _VotingHomeScreenState extends ConsumerState<VotingHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    
    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text('ログインが必要です'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('投票'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            actions: [
              StarPointBalanceWidget(
                onTap: () => StarPointBalanceDialog.show(context),
              ),
              const SizedBox(width: 8),
              if (user.isStar) ...[
                IconButton(
                  onPressed: () => _navigateToCreatePost(),
                  icon: const Icon(Icons.add),
                  tooltip: '投票投稿を作成',
                ),
              ],
              IconButton(
                onPressed: () => _showInfoDialog(),
                icon: const Icon(Icons.info_outline),
                tooltip: '投票システムについて',
              ),
              const SizedBox(width: 8),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(text: 'すべて'),
                Tab(text: 'フォロー中'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildAllVotingPostsTab(),
              _buildFollowingVotingPostsTab(user.id),
            ],
          ),
          floatingActionButton: user.isStar ? FloatingActionButton(
            onPressed: () => _navigateToCreatePost(),
            tooltip: '投票投稿を作成',
            child: const Icon(Icons.add),
          ) : null,
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
    );
  }

  Widget _buildAllVotingPostsTab() {
    final votingPostsAsync = ref.watch(activeVotingPostsProvider);
    
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(activeVotingPostsProvider);
      },
      child: votingPostsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.how_to_vote,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'まだ投票できる投稿がありません',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'スターが新しい投票を作成するまでお待ちください',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return VotingPostCard(
                post: post,
                onVoteCompleted: () {
                  // 投票完了後にリストを更新
                  ref.invalidate(activeVotingPostsProvider);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'データの読み込みに失敗しました',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(activeVotingPostsProvider);
                },
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowingVotingPostsTab(String userId) {
    // TODO: フォローしているスターの投票投稿のみを表示
    // 今回はすべての投稿を表示（後で実装予定）
    return _buildAllVotingPostsTab();
  }

  void _navigateToCreatePost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateVotingPostScreen(),
      ),
    ).then((_) {
      // 投稿作成後にリストを更新
      ref.invalidate(activeVotingPostsProvider);
    });
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('投票システムについて'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'スターPとは',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('・投票に使用する専用ポイントです'),
              Text('・日次ログインで毎日10SP獲得できます'),
              Text('・投票1回につき1SP以上が必要です'),
              SizedBox(height: 16),
              Text(
                '投票について',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('・スターが作成した2択の質問に投票できます'),
              Text('・1つの投稿につき1回のみ投票可能です'),
              Text('・投票後は結果を確認できます'),
              Text('・期限のある投票もあります'),
              SizedBox(height: 16),
              Text(
                'スターの方へ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('・ファンとの交流を深める投票を作成できます'),
              Text('・投票コストや期限を設定できます'),
              Text('・投票結果をリアルタイムで確認できます'),
            ],
          ),
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
}

/// スターP残高詳細ダイアログの表示用拡張
extension StarPointBalanceDialogExtension on StarPointBalanceWidget {
  static void show(BuildContext context) {
    StarPointBalanceDialog.show(context);
  }
}