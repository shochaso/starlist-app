import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../src/providers/theme_provider_enhanced.dart';

// プロバイダー
final selectedTabProvider = StateProvider<int>((ref) => 0);

class MylistScreen extends ConsumerStatefulWidget {
  const MylistScreen({super.key});

  @override
  ConsumerState<MylistScreen> createState() => _MylistScreenState();
}

class _MylistScreenState extends ConsumerState<MylistScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  // ダミーデータ - フォロー中のスター
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

  // お気に入りのスター
  final List<Map<String, dynamic>> _favoriteStars = [
    {
      'id': '1',
      'name': 'テックレビューアー田中',
      'category': 'テクノロジー',
      'followers': 15420,
      'avatar': null,
      'verified': true,
      'addedDate': '2024-01-15',
      'lastViewed': '2時間前',
    },
    {
      'id': '2',
      'name': '料理研究家佐藤',
      'category': '料理・グルメ',
      'followers': 8930,
      'avatar': null,
      'verified': false,
      'addedDate': '2024-01-10',
      'lastViewed': '1日前',
    },
  ];

  // 最近の活動データ
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

  final List<Map<String, dynamic>> _favoriteContents = [
    {
      'id': '1',
      'title': 'iPhone 15 Pro レビュー',
      'star': 'テックレビューアー田中',
      'category': 'テクノロジー',
      'likes': 234,
      'views': 1520,
      'addedDate': '2024-01-20',
      'duration': '15:30',
      'type': 'video',
    },
    {
      'id': '2',
      'title': '簡単パスタレシピ集',
      'star': '料理研究家佐藤',
      'category': '料理・グルメ',
      'likes': 156,
      'views': 890,
      'addedDate': '2024-01-18',
      'duration': '8:45',
      'type': 'recipe',
    },
    {
      'id': '3',
      'title': 'Flutter開発のコツ',
      'star': 'テックレビューアー田中',
      'category': 'テクノロジー',
      'likes': 89,
      'views': 456,
      'addedDate': '2024-01-16',
      'duration': '12:20',
      'type': 'tutorial',
    },
  ];

  final List<Map<String, dynamic>> _playlists = [
    {
      'id': '1',
      'name': 'お気に入りレシピ',
      'description': '作ってみたい料理レシピ集',
      'itemCount': 12,
      'createdDate': '2024-01-01',
      'thumbnail': null,
      'isPublic': false,
    },
    {
      'id': '2',
      'name': 'プログラミング学習',
      'description': 'Flutter・Dart関連の動画',
      'itemCount': 8,
      'createdDate': '2024-01-05',
      'thumbnail': null,
      'isPublic': true,
    },
  ];

  String _sortBy = 'recent';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_selectedTabIndex != _tabController.index) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
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
              margin: const EdgeInsets.all(4), // MP適用
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
                labelPadding: EdgeInsets.zero,
                isScrollable: true,
                tabs: const [
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'フォロー中',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'お気に入り',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'コンテンツ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'プレイリスト',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '最近の活動',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // タブコンテンツ
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFollowingTab(),
                  _buildStarsTab(),
                  _buildContentsTab(),
                  _buildPlaylistsTab(),
                  _buildActivitiesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildStarsTab() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'お気に入りのスター',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () => _showAllStars(),
                child: const Text(
                  'すべて見る',
                  style: TextStyle(color: Color(0xFF4ECDC4)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._favoriteStars.map((star) => _buildStarCard(star)).toList(),
        ],
      ),
    );
  }

  Widget _buildContentsTab() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'お気に入りコンテンツ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              DropdownButton<String>(
                value: _sortBy,
                dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                underline: Container(),
                items: const [
                  DropdownMenuItem(value: 'recent', child: Text('最近追加')),
                  DropdownMenuItem(value: 'popular', child: Text('人気順')),
                  DropdownMenuItem(value: 'name', child: Text('名前順')),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._favoriteContents.map((content) => _buildContentCard(content)).toList(),
        ],
      ),
    );
  }

  Widget _buildPlaylistsTab() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'プレイリスト',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showCreatePlaylistDialog(),
                icon: const Icon(Icons.add, color: Color(0xFF4ECDC4), size: 16),
                label: const Text(
                  '新規作成',
                  style: TextStyle(color: Color(0xFF4ECDC4)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._playlists.map((playlist) => _buildPlaylistCard(playlist)).toList(),
        ],
      ),
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
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        star['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    if (star['verified'])
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF4ECDC4),
                        size: 16,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  star['category'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${star['followers']}人のフォロワー',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.black38,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '追加日: ${star['addedDate']} • 最終視聴: ${star['lastViewed']}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[600] : Colors.black26,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.grey[400] : Colors.black54,
            ),
            onPressed: () => _showStarOptions(star),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(Map<String, dynamic> content) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content['title'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFF4ECDC4),
                child: Text(
                  content['star'][0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  content['star'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.black54,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  content['category'],
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF4ECDC4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.favorite_outline,
                color: isDark ? Colors.grey[500] : Colors.black38,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${content['likes']}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.black38,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.visibility_outlined,
                color: isDark ? Colors.grey[500] : Colors.black38,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${content['views']}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.black38,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                color: isDark ? Colors.grey[500] : Colors.black38,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                content['duration'],
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.black38,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: isDark ? Colors.grey[400] : Colors.black54,
                  size: 16,
                ),
                onPressed: () => _showContentOptions(content),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistCard(Map<String, dynamic> playlist) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.playlist_play,
              color: Colors.white,
              size: 28,
            ),
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
                        playlist['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    if (playlist['isPublic'])
                      Icon(
                        Icons.public,
                        color: isDark ? Colors.grey[400] : Colors.black54,
                        size: 16,
                      )
                    else
                      Icon(
                        Icons.lock,
                        color: isDark ? Colors.grey[400] : Colors.black54,
                        size: 16,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  playlist['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${playlist['itemCount']}個のアイテム • 作成日: ${playlist['createdDate']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.grey[400] : Colors.black54,
            ),
            onPressed: () => _showPlaylistOptions(playlist),
          ),
        ],
      ),
    );
  }

  void _searchMylist() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('マイリスト検索機能'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'sort':
        _showSortOptions();
        break;
      case 'export':
        _exportMylist();
        break;
      case 'settings':
        _showMylistSettings();
        break;
    }
  }

  void _showSortOptions() {
    final themeState = ref.read(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '並び替え',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.access_time, color: Color(0xFF4ECDC4)),
              title: Text(
                '最近追加順',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha, color: Color(0xFF4ECDC4)),
              title: Text(
                '名前順',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.category, color: Color(0xFF4ECDC4)),
              title: Text(
                'カテゴリー順',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptions() {
    final themeState = ref.read(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '追加',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.star, color: Color(0xFF4ECDC4)),
              title: Text(
                'スターをお気に入りに追加',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              onTap: () {
                Navigator.pop(context);
                _addStar();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark, color: Color(0xFF4ECDC4)),
              title: Text(
                'コンテンツをお気に入りに追加',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              onTap: () {
                Navigator.pop(context);
                _addContent();
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add, color: Color(0xFF4ECDC4)),
              title: Text(
                '新しいプレイリストを作成',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              onTap: () {
                Navigator.pop(context);
                _createPlaylist();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAllStars() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('すべてのお気に入りスターを表示'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _exportMylist() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('マイリストをエクスポートしました'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _showMylistSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('マイリスト設定'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _addStar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('スターをお気に入りに追加'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _addContent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('コンテンツをお気に入りに追加'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _createPlaylist() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('プレイリストが作成されました'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _showStarOptions(Map<String, dynamic> star) {
    // Implement the logic to show star options
  }

  void _showContentOptions(Map<String, dynamic> content) {
    // Implement the logic to show content options
  }

  void _showPlaylistOptions(Map<String, dynamic> playlist) {
    // Implement the logic to show playlist options
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
          ..._followingStars.map((star) => _buildFollowingStarCard(star)).toList(),
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

  Widget _buildFollowingStarCard(Map<String, dynamic> star) {
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
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                        width: 2,
                      ),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    if (star['verified'])
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF4ECDC4),
                        size: 16,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  star['category'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '最終投稿: ${star['lastPost']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.black38,
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
                            color: Colors.white,
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
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.grey[400] : Colors.black54,
            ),
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            onSelected: (value) => _handleFollowingStarAction(value, star),
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
              PopupMenuItem(
                value: 'favorite',
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: isDark ? Colors.white : Colors.black87, size: 20),
                    const SizedBox(width: 8),
                    Text('お気に入りに追加', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
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
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
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

  void _handleFollowingStarAction(String action, Map<String, dynamic> star) {
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
      case 'favorite':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${star['name']}をお気に入りに追加'),
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
    final themeState = ref.read(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        title: Text(
          'フォロー解除',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Text(
          '${star['name']}のフォローを解除しますか？',
          style: TextStyle(color: isDark ? const Color(0xFF888888) : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'キャンセル',
              style: TextStyle(color: isDark ? const Color(0xFF888888) : Colors.black54),
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

  void _showCreatePlaylistDialog() {
    final themeState = ref.read(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        title: Text(
          'プレイリストを作成',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'プレイリストの名前',
                labelStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.black54,
                ),
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.black38,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF333333) : const Color(0xFFF8FAFC),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF444444) : const Color(0xFFE5E7EB),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF444444) : const Color(0xFFE5E7EB),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              maxLines: 3,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'プレイリストの説明（任意）',
                alignLabelWithHint: true,
                labelStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.black54,
                ),
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.black38,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF333333) : const Color(0xFFF8FAFC),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF444444) : const Color(0xFFE5E7EB),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF444444) : const Color(0xFFE5E7EB),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark ? Colors.grey[600]! : Colors.black26,
                        ),
                      ),
                    ),
                    child: Text(
                      'キャンセル',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _createPlaylist();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ECDC4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '作成',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 