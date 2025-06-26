import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../src/providers/theme_provider_enhanced.dart';

class FollowScreen extends ConsumerStatefulWidget {
  const FollowScreen({super.key});

  @override
  ConsumerState<FollowScreen> createState() => _FollowScreenState();
}

class _FollowScreenState extends ConsumerState<FollowScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // ダミーデータ
  final List<Map<String, dynamic>> _followingStars = [
    {
      'id': '1',
      'name': 'テックレビューアー田中',
      'category': 'テクノロジー',
      'followers': 15420,
      'avatar': null,
      'verified': true,
      'lastPost': '2時間前',
      'isOnline': true,
      'newPosts': 3,
    },
    {
      'id': '2',
      'name': '料理研究家佐藤',
      'category': '料理・グルメ',
      'followers': 8930,
      'avatar': null,
      'verified': false,
      'lastPost': '1日前',
      'isOnline': false,
      'newPosts': 1,
    },
    {
      'id': '3',
      'name': 'ゲーム実況者山田',
      'category': 'ゲーム',
      'followers': 23450,
      'avatar': null,
      'verified': true,
      'lastPost': '30分前',
      'isOnline': true,
      'newPosts': 5,
    },
  ];

  final List<Map<String, dynamic>> _recentActivities = [
    {
      'star': 'テックレビューアー田中',
      'action': '新しい動画を投稿しました',
      'content': 'iPhone 15 Pro Max 詳細レビュー',
      'time': '2時間前',
      'type': 'video',
    },
    {
      'star': 'ゲーム実況者山田',
      'action': 'ライブ配信を開始しました',
      'content': 'Apex Legends ランクマッチ',
      'time': '30分前',
      'type': 'live',
    },
    {
      'star': '料理研究家佐藤',
      'action': '新しいレシピを投稿しました',
      'content': '簡単チキンカレーの作り方',
      'time': '1日前',
      'type': 'recipe',
    },
  ];

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
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // タブバー
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFF4ECDC4),
                  borderRadius: BorderRadius.circular(8),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: isDark ? const Color(0xFF888888) : Colors.grey.shade600,
                labelPadding: EdgeInsets.zero,
                tabs: const [
                  Tab(
                    child: Text(
                      'フォロー中',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      '最近の活動',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // タブビュー
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFollowingTab(),
                  _buildActivitiesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowingTab() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFollowingStats(),
          const SizedBox(height: 24),
          Text(
            'フォロー中のスター',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ..._followingStars.map((star) => _buildStarCard(star)).toList(),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _recentActivities.length,
      itemBuilder: (context, index) {
        final activity = _recentActivities[index];
        return _buildActivityCard(activity);
      },
    );
  }

  Widget _buildFollowingStats() {
    final totalFollowing = _followingStars.length;
    final totalNewPosts = _followingStars.fold<int>(0, (sum, star) => sum + (star['newPosts'] as int));
    // 認証済みカウントを削除

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'フォロー状況',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('フォロー中', '$totalFollowing人', Icons.people),
              ),
              Expanded(
                child: _buildStatItem('新着投稿', '$totalNewPosts件', Icons.fiber_new),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, [Color? iconColor]) {
    return Column(
      children: [
        Icon(
          icon,
          color: iconColor ?? Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }


  Widget _buildStarCard(Map<String, dynamic> star) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : Colors.grey.shade200,
        ),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF4ECDC4),
            child: Text(
              star['name'][0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  star['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  star['category'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFF888888) : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '最終投稿: ${star['lastPost']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF888888) : Colors.black38,
                      ),
                    ),
                    if (star['newPosts'] > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4ECDC4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${star['newPosts']}件の新着',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: isDark ? const Color(0xFF888888) : Colors.black54),
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            onSelected: (value) => _handleStarAction(value, star),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.person, color: isDark ? Colors.white : Colors.black87, size: 20),
                    const SizedBox(width: 8),
                    Text('プロフィールを見る', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'notification',
                child: Row(
                  children: [
                    Icon(Icons.notifications, color: isDark ? Colors.white : Colors.black87, size: 20),
                    const SizedBox(width: 8),
                    Text('通知設定', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'unfollow',
                child: Row(
                  children: [
                    Icon(Icons.person_remove, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('フォロー解除', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    IconData typeIcon;
    Color typeColor;
    
    switch (activity['type']) {
      case 'video':
        typeIcon = Icons.play_circle_outline;
        typeColor = const Color(0xFF4ECDC4);
        break;
      case 'live':
        typeIcon = Icons.live_tv;
        typeColor = Colors.red;
        break;
      case 'recipe':
        typeIcon = Icons.restaurant;
        typeColor = const Color(0xFFFFE66D);
        break;
      default:
        typeIcon = Icons.article;
        typeColor = const Color(0xFF888888);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(typeIcon, color: typeColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['star'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4ECDC4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['action'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['content'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF888888) : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  activity['time'],
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? const Color(0xFF888888) : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: isDark ? const Color(0xFF888888) : Colors.black54, size: 16),
            onPressed: () => _viewActivity(activity),
          ),
        ],
      ),
    );
  }

  void _searchFollowing() {
    showSearch(
      context: context,
      delegate: FollowingSearchDelegate(_followingStars),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '並び替え',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.access_time, color: Color(0xFF4ECDC4)),
              title: const Text('最新の投稿順', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Color(0xFF4ECDC4)),
              title: const Text('フォロワー数順', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha, color: Color(0xFF4ECDC4)),
              title: const Text('名前順', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _handleStarAction(String action, Map<String, dynamic> star) {
    switch (action) {
      case 'view':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${star['name']}のプロフィールを表示'),
            backgroundColor: const Color(0xFF4ECDC4),
          ),
        );
        break;
      case 'notification':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${star['name']}の通知設定を変更'),
            backgroundColor: const Color(0xFF4ECDC4),
          ),
        );
        break;
      case 'unfollow':
        _showUnfollowDialog(star);
        break;
    }
  }

  void _showUnfollowDialog(Map<String, dynamic> star) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'フォロー解除',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '${star['name']}のフォローを解除しますか？',
          style: const TextStyle(color: Color(0xFF888888)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'キャンセル',
              style: TextStyle(color: Color(0xFF888888)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _followingStars.removeWhere((s) => s['id'] == star['id']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${star['name']}のフォローを解除しました'),
                  backgroundColor: const Color(0xFF4ECDC4),
                ),
              );
            },
            child: const Text(
              'フォロー解除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _viewActivity(Map<String, dynamic> activity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${activity['content']}を表示'),
        backgroundColor: const Color(0xFF4ECDC4),
      ),
    );
  }
}

class FollowingSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> followingStars;

  FollowingSearchDelegate(this.followingStars);

  @override
  String get searchFieldLabel => 'フォロー中のスターを検索...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Color(0xFF888888)),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredStars = followingStars
        .where((star) => star['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Container(
      color: const Color(0xFF1A1A1A),
      child: ListView.builder(
        itemCount: filteredStars.length,
        itemBuilder: (context, index) {
          final star = filteredStars[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF4ECDC4),
              child: Text(
                star['name'][0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              star['name'],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              star['category'],
              style: const TextStyle(color: Color(0xFF888888)),
            ),
            onTap: () {
              close(context, star['name']);
            },
          );
        },
      ),
    );
  }
}

 