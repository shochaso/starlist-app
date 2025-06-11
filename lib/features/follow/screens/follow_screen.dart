import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FollowScreen extends StatefulWidget {
  const FollowScreen({super.key});

  @override
  State<FollowScreen> createState() => _FollowScreenState();
}

class _FollowScreenState extends State<FollowScreen>
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
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'フォロー中',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => _searchFollowing(),
          ),
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            onPressed: () => _showSortOptions(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4ECDC4),
          labelColor: const Color(0xFF4ECDC4),
          unselectedLabelColor: const Color(0xFF888888),
          tabs: const [
            Tab(text: 'フォロー中'),
            Tab(text: '最近の活動'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFollowingTab(),
          _buildActivitiesTab(),
        ],
      ),
    );
  }

  Widget _buildFollowingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFollowingStats(),
          const SizedBox(height: 24),
          _buildOnlineStars(),
          const SizedBox(height: 24),
          const Text(
            'フォロー中のスター',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
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
    final onlineStars = _followingStars.where((star) => star['isOnline']).length;
    final totalNewPosts = _followingStars.fold<int>(0, (sum, star) => sum + (star['newPosts'] as int));

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
                child: _buildStatItem('オンライン', '$onlineStars人', Icons.circle, Colors.green),
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

  Widget _buildOnlineStars() {
    final onlineStars = _followingStars.where((star) => star['isOnline']).toList();
    
    if (onlineStars.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'オンライン中',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: onlineStars.length,
            itemBuilder: (context, index) {
              final star = onlineStars[index];
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: const Color(0xFF4ECDC4),
                          child: Text(
                            star['name'][0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF1A1A1A), width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 60,
                      child: Text(
                        star['name'].split(' ')[0],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStarCard(Map<String, dynamic> star) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        children: [
          Stack(
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
              if (star['isOnline'])
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2A2A2A), width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        star['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (star['verified'])
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF4ECDC4),
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  star['category'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '最終投稿: ${star['lastPost']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
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
            icon: const Icon(Icons.more_vert, color: Color(0xFF888888)),
            color: const Color(0xFF2A2A2A),
            onSelected: (value) => _handleStarAction(value, star),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('プロフィールを見る', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'notification',
                child: Row(
                  children: [
                    Icon(Icons.notifications, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('通知設定', style: TextStyle(color: Colors.white)),
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
              color: typeColor.withOpacity(0.2),
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
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['content'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  activity['time'],
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFF888888), size: 16),
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